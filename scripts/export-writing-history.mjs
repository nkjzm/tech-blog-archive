import { execFileSync } from 'node:child_process';
import { createHash } from 'node:crypto';
import { mkdirSync, writeFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
function git(args, encoding = 'utf8') {
  return execFileSync('git', args, { cwd: root, encoding, maxBuffer: 128 * 1024 * 1024 });
}
if (git(['rev-parse', '--is-shallow-repository']).trim() === 'true') {
  throw new Error('履歴が不足しています。shallow cloneを解除してから再実行してください。');
}
const commits = git(['rev-list', '--all', '--topo-order', '--reverse']).trim().split('\n').filter(Boolean);
const trees = new Map();
const ancestors = new Map();
const articles = new Map();
const versions = new Map();
const articleCommits = [];
function readTree(commit) {
  if (!commit) return new Map();
  if (!trees.has(commit)) {
    const tree = new Map();
    for (const row of git(['ls-tree', '-r', '-z', commit, '--', 'articles']).split('\0')) {
      if (!row) continue;
      const tab = row.indexOf('\t');
      const path = row.slice(tab + 1);
      const [mode, type, blob] = row.slice(0, tab).split(' ');
      if (/^articles\/[^/]+\.md$/.test(path) && type === 'blob' && mode !== '120000') tree.set(path, blob);
    }
    trees.set(commit, tree);
  }
  return trees.get(commit);
}
function version(blob) {
  if (!versions.has(blob)) {
    const raw = git(['cat-file', 'blob', blob], null);
    const text = raw.toString('utf8');
    const frontmatter = text.match(/^---\r?\n[\s\S]*?\r?\n---(?:\r?\n|$)/)?.[0] ?? '';
    const body = text.slice(frontmatter.length);
    versions.set(blob, {
      raw,
      bodyHash: createHash('sha256').update(body).digest('hex'),
      frontmatterHash: createHash('sha256').update(frontmatter).digest('hex'),
    });
  }
  return versions.get(blob);
}
for (const commit of commits) {
  const metadata = git(['show', '-s', '--format=%P%x00%aI%x00%cI%x00%an%x00%B', commit]).split('\0');
  const parents = metadata[0].trim().split(' ').filter(Boolean);
  const tree = readTree(commit);
  const priorPaths = new Set(parents.flatMap(parent => [...(ancestors.get(parent) ?? [])]));
  const events = [];
  for (const parent of parents.length ? parents : [null]) {
    const previous = readTree(parent);
    for (const path of [...new Set([...tree.keys(), ...previous.keys()])].sort()) {
      const before = previous.get(path) ?? null;
      const after = tree.get(path) ?? null;
      if (before === after) continue;
      const beforeVersion = before ? version(before) : null;
      const afterVersion = after ? version(after) : null;
      const status = !after ? 'deleted' : before ? 'modified' : priorPaths.has(path) ? 'readded' : 'added';
      const change = !before || !after ? 'lifecycle' : beforeVersion.bodyHash !== afterVersion.bodyHash ? 'body' : beforeVersion.frontmatterHash !== afterVersion.frontmatterHash ? 'frontmatter-only' : 'other';
      const event = { parent, path, status, change, before, after };
      events.push(event);
      if (!articles.has(path)) articles.set(path, { id: path.slice(9, -3), path, snapshots: new Set(), events: [] });
      const article = articles.get(path);
      article.events.push({ commit, ...event });
      for (const blob of [before, after].filter(Boolean)) article.snapshots.add(blob);
    }
  }
  ancestors.set(commit, new Set([...priorPaths, ...tree.keys()]));
  if (!events.length) continue;
  const message = metadata.slice(4).join('\0').trimEnd();
  const aiCoauthors = message.split('\n').filter(line => /^Co-Authored-By:.*(?:claude|anthropic|openai|codex|chatgpt|copilot)/i.test(line));
  const automation = /(?:^|\n)(?:🔄\s*)?auto:|\[bot\]|dependabot|github-actions/i.test(`${metadata[3]}\n${message}`);
  articleCommits.push({
    commit, parents, authoredAt: metadata[1], committedAt: metadata[2],
    author: metadata[3], message,
    attribution: automation ? 'automation' : aiCoauthors.length ? 'ai-assisted' : 'unknown',
    evidence: aiCoauthors.map(line => line.replace(/\s*<[^>]*>/g, '')),
    events,
  });
}
const output = resolve(root, 'writing');
mkdirSync(output, { recursive: true });
const articleRows = [...articles.values()].sort((a, b) => a.path.localeCompare(b.path, 'en'));
for (const article of articleRows) {
  article.snapshots = [...article.snapshots].sort().map(blob => {
    const data = version(blob);
    const path = `snapshots/${article.id}/${blob}.md`;
    mkdirSync(dirname(resolve(output, path)), { recursive: true });
    writeFileSync(resolve(output, path), data.raw);
    return { blob, path, bodyHash: data.bodyHash, frontmatterHash: data.frontmatterHash };
  });
}
const index = {
  schemaVersion: 1,
  scope: { refs: 'all local refs', paths: 'articles/*.md', committedOnly: true, articleChangingCommitsOnly: true, comparison: 'each parent', articleIdentity: 'path' },
  counts: { articleChangingCommits: articleCommits.length, articles: articleRows.length, uniqueBlobs: versions.size },
  commits: articleCommits,
  articles: articleRows,
};
writeFileSync(resolve(output, 'index.json'), `${JSON.stringify(index, null, 2)}\n`);
console.log(`${articleRows.length} articles, ${versions.size} unique blobs, ${articleCommits.length} article-changing commits exported`);
