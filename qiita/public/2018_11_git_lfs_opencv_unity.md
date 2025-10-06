---
title: 【Git LFS】OpenCV for Unityをpushしようとして怒られた人が見るページ
private: false
tags:
  - Unity
  - ポエム
updated_at: '2018-11-19T18:13:35+09:00'
id: 89ede8aa10fad30937b4
organization_url_name: null
slide: false
---
# はじめに

OpenCV for Unity(https://assetstore.unity.com/packages/tools/integration/opencv-for-unity-21088) をImportしてcommitしてGitHubにpushしようとすると、こういうメッセージが返ってきます。

```sh
$ git push origin master 
Enumerating objects: 3189, done.
Counting objects: 100% (3189/3189), done.
Delta compression using up to 12 threads
Compressing objects: 100% (3179/3179), done.
Writing objects: 100% (3180/3180), 512.99 MiB | 2.70 MiB/s, done.
Total 3180 (delta 1425), reused 0 (delta 0)
remote: Resolving deltas: 100% (1425/1425), completed with 5 local objects.
remote: warning: File Assets/Externals/OpenCVForUnity/Plugins/iOS/libopencvforunity.a is 92.91 MB; this is larger than GitHub's recommended maximum file size of 50.00 MB
remote: warning: File Assets/Externals/OpenCVForUnity/Plugins/WebGL/2018.2/opencvforunity.bc is 68.17 MB; this is larger than GitHub's recommended maximum file size of 50.00 MB
remote: warning: File Assets/Externals/OpenCVForUnity/Plugins/WebGL/5.6/opencvforunity.bc is 68.38 MB; this is larger than GitHub's recommended maximum file size of 50.00 MB
remote: warning: File Assets/Externals/OpenCVForUnity/Plugins/Windows/x86_64/opencvforunity.dll is 51.30 MB; this is larger than GitHub's recommended maximum file size of 50.00 MB
remote: warning: File Assets/Externals/OpenCVForUnity/Extra/exclude_contrib/iOS/libopencvforunity.a is 68.71 MB; this is larger than GitHub's recommended maximum file size of 50.00 MB
remote: error: GH001: Large files detected. You may want to try Git Large File Storage - https://git-lfs.github.com.
remote: error: Trace: 799ba5fd3f46fea5efc9da140112f51c
remote: error: See http://git.io/iEPt8g for more information.
remote: error: File Assets/Externals/OpenCVForUnity/Plugins/iOS/opencv2.framework/opencv2 is 283.23 MB; this exceeds GitHub's file size limit of 100.00 MB
remote: error: File Assets/Externals/OpenCVForUnity/Extra/exclude_contrib/iOS/opencv2.framework/opencv2 is 180.53 MB; this exceeds GitHub's file size limit of 100.00 MB
To github.com:hoge/project.git
 ! [remote rejected] master -> master (pre-receive hook declined)
error: failed to push some refs to 'git@github.com:hoge/project.git'
```

> this is larger than GitHub's recommended maximum file size of 50.00 MB
> this exceeds GitHub's file size limit of 100.00 MB

GitHubでは一つのファイルサイズは50MBまでが推奨、最大でも100MBまでと言われていますね。
OpenCV for Unityには100MBを超えるファイルが入っているので、GitHubに直接pushすることが出来ないようです。

そこでこの記事では、その対処法を説明したいと思います。
いくつか方法があって一短一長なので、一度最後まで読んでから方針を決めると良いかと思います。

# パターン1: Git LFSを使う方法

先程のメッセージをもう一度見てみましょう。

> You may want to try Git Large File Storage - https://git-lfs.github.com.

Git Large File Storage (**Git LFS**)を使ってみてくれって言われています。公式としてはこのGit LFSを推奨しているようですね。まずはこの方法を検討してみましょう。

Git LFSには便利な機能があり、既にcommit済みのファイルであっても**その前からGit LFSを使っていたことにできる**方法がありまして、今回はその方法を紹介していきます。

## 環境

Mac: macOS High Sierra

## 手順

### とりあえず導入

brew(https://brew.sh/index_ja.html) でインストールしていきます

```sh
brew update
brew install git-lfs
```

プロジェクトにGit LFSを紐づけます

```sh
$ cd /path/to/project
$ git lfs install
Updated git hooks.
Git LFS initialized.
```

### 状況を把握する

50MBを超えるものに該当するファイルを調べてみます。

```sh
$ git lfs migrate info --include-ref master --above 50MB
migrate: Sorting commits: ..., done                                                                                                                                                                                                           
migrate: Examining commits: 100% (24/24), done                                                                                                                                                                                                
*.a  	170 MB	  2/2 files(s)	100%
*.bc 	143 MB	  2/2 files(s)	100%
*.dll	54 MB 	1/103 files(s)	  1%
*.so 	52 MB 	 1/80 files(s)	  1%
```

GitHubの制限を超えるものという観点で50MB以上のものを調べていますが、そもそもMB単位のファイルをGitで管理すること自体あまり正しい使い方でない気がするので、もっと小さい値でもいいかもしれないです。

### Git LFSの管理対象を設定する

では該当するファイルをGit LFS管理対象に指定していきましょう。
今回は先程該当していたファイルの種類ごと、`*.`でまとめて指定していきます。

```sh
$ git lfs migrate import --include-ref master --include="*.a,*.bc,*.dll,*.so"
migrate: Sorting commits: ..., done                                                                                                                                                                                                           
migrate: Rewriting commits: 100% (24/24), done                                                                                                                                                                                                
  master	hogehash1 -> hogehash2
migrate: Updating refs: ..., done                                                                                                                                                                                                             
migrate: checkout: ..., done    
```

特定のファイルのみ追加したい場合はフルパスを記載してください。初めのメッセージで100MBを超えていたファイルのみを追加する場合は以下の通りです。

```sh
$ git lfs migrate import --include-ref master --include="Assets/Externals/OpenCVForUnity/Plugins/iOS/opencv2.framework/opencv2,Assets/Externals/OpenCVForUnity/Extra/exclude_contrib/iOS/opencv2.framework/opencv2"
```

ちなみに間違えて意図していないものを管理対象にしてしまった場合、私が調べた限りだとrevertするようなコマンドは用意されていないようです。(`git lfs uninstall`だけでは`migrate`自体の取り消しはできませんでした)

その場合は`git reflog`で実行前の履歴を調べ、`git reset --hard HEAD@{該当の番号}`で状態毎戻してしまうのがよさそうです。

また、実行後に差分ファイルが出てくる場合があるそうですが、`git add .; git reset --hard`などで消してしまって大丈夫だそうです。

### Git LFSの管理状況を確認する

設定が反映されたか確認してみます。ファイルの種類ごとに設定した場合の例です。

```sh
$ git lfs track
Listing tracked patterns
    *.a (.gitattributes)
    *.bc (.gitattributes)
    *.dll (.gitattributes)
    *.so (.gitattributes)
```

先程の設定が反映されていることが分かります。

これはリポジトリルートの`.gitattributes`に書いてある情報が表示されています。
`vi .gitattributes`を直接書き換えることも可能ですが、未来のコミット時にしか適用されないため、過去のコミットも変更対象にした場合は前述の`git lfs migrate import`を使うのが良いと思います。

実際に先程のファイルが管理対象に変更されたか確認してみます。

```sh
$ git lfs ls-files
5b082d7351 - Assets/Externals/OpenCVForUnity/Extra/exclude_contrib/Android/libs/arm64-v8a/libopencvforunity.so
e5d035962e - Assets/Externals/OpenCVForUnity/Extra/exclude_contrib/Android/libs/armeabi-v7a/libopencvforunity.so
728b3e235b - Assets/Externals/OpenCVForUnity/Extra/exclude_contrib/Android/libs/x86/libopencvforunity.so
55dfd998a6 - Assets/Externals/OpenCVForUnity/Extra/exclude_contrib/iOS/libopencvforunity.a
9326b4593f - Assets/Externals/OpenCVForUnity/Plugins/Android/libs/arm64-v8a/libopencvforunity.so
d6254cf5c9 - Assets/Externals/OpenCVForUnity/Plugins/Android/libs/armeabi-v7a/libopencvforunity.so
907350943a - Assets/Externals/OpenCVForUnity/Plugins/Android/libs/x86/libopencvforunity.so
1b1f676b88 - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86/libopencv_aruco_4_0.so
226969e356 - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86/libopencv_bgsegm_4_0.so
16b2150ef5 - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86/libopencv_bioinspired_4_0.so
50026090bf - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86/libopencv_calib3d_4_0.so
025e124da3 - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86/libopencv_ccalib_4_0.so
f51696b538 - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86/libopencv_core_4_0.so
0af9b31996 - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86/libopencv_dnn_4_0.so
6e12f5e17c - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86/libopencv_face_4_0.so
ee111cfae2 - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86/libopencv_features2d_4_0.so
463260db62 - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86/libopencv_flann_4_0.so
06bf8ea6bb - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86/libopencv_fuzzy_4_0.so
e733a62ade - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86/libopencv_highgui_4_0.so
bfe1175eb6 - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86/libopencv_img_hash_4_0.so
82fe710479 - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86/libopencv_imgcodecs_4_0.so
be1699728c - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86/libopencv_imgproc_4_0.so
96457e87ae - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86/libopencv_ml_4_0.so
83653a1c22 - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86/libopencv_objdetect_4_0.so
0c3da681b6 - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86/libopencv_optflow_4_0.so
f4982de4a6 - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86/libopencv_phase_unwrapping_4_0.so
e460e8d0c4 - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86/libopencv_photo_4_0.so
c40c6cfe7e - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86/libopencv_plot_4_0.so
24293ba40f - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86/libopencv_reg_4_0.so
021b7c5fba - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86/libopencv_saliency_4_0.so
4ef26b3a1c - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86/libopencv_shape_4_0.so
95f33438cf - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86/libopencv_stitching_4_0.so
d1b4fcb100 - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86/libopencv_structured_light_4_0.so
5e58762251 - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86/libopencv_superres_4_0.so
d3c012c53e - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86/libopencv_surface_matching_4_0.so
7a2932d617 - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86/libopencv_text_4_0.so
d5cac3a69f - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86/libopencv_tracking_4_0.so
9b04376a89 - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86/libopencv_video_4_0.so
6254b8f3a4 - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86/libopencv_videoio_4_0.so
69c62a49a0 - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86/libopencv_videostab_4_0.so
12b88e8d0f - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86/libopencv_xfeatures2d_4_0.so
df4d66b890 - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86/libopencv_ximgproc_4_0.so
18e4e66926 - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86/libopencv_xphoto_4_0.so
b9f53aeb23 - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86/libopencvforunity.so
7557a3425a - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86_64/libopencv_aruco_4_0.so
2fe8cbf93c - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86_64/libopencv_bgsegm_4_0.so
8d518fed90 - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86_64/libopencv_bioinspired_4_0.so
263bcf6b09 - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86_64/libopencv_calib3d_4_0.so
c08713d28d - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86_64/libopencv_ccalib_4_0.so
499ed1e19f - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86_64/libopencv_core_4_0.so
7bd2d02295 - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86_64/libopencv_dnn_4_0.so
55f1b9b492 - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86_64/libopencv_face_4_0.so
fef0789f90 - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86_64/libopencv_features2d_4_0.so
cbcc3e613f - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86_64/libopencv_flann_4_0.so
956dc2ced4 - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86_64/libopencv_fuzzy_4_0.so
fddd5aa593 - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86_64/libopencv_highgui_4_0.so
0b3a90a89f - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86_64/libopencv_img_hash_4_0.so
fcebbf2c05 - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86_64/libopencv_imgcodecs_4_0.so
ec71a98e4b - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86_64/libopencv_imgproc_4_0.so
6461f0c063 - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86_64/libopencv_ml_4_0.so
f7bddcbf20 - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86_64/libopencv_objdetect_4_0.so
2a5d9f2359 - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86_64/libopencv_optflow_4_0.so
8cc3eaa3ed - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86_64/libopencv_phase_unwrapping_4_0.so
1c64323d54 - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86_64/libopencv_photo_4_0.so
443b49e024 - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86_64/libopencv_plot_4_0.so
d9ca256406 - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86_64/libopencv_reg_4_0.so
25ff671670 - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86_64/libopencv_saliency_4_0.so
5d6e901365 - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86_64/libopencv_shape_4_0.so
d327a6e1ce - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86_64/libopencv_stitching_4_0.so
d41e88cb95 - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86_64/libopencv_structured_light_4_0.so
621785f9c2 - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86_64/libopencv_superres_4_0.so
f1854b9859 - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86_64/libopencv_surface_matching_4_0.so
d7a0bf7d76 - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86_64/libopencv_text_4_0.so
213aff9298 - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86_64/libopencv_tracking_4_0.so
fe8ddcd3a7 - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86_64/libopencv_video_4_0.so
a66fe430e6 - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86_64/libopencv_videoio_4_0.so
b7bcde06db - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86_64/libopencv_videostab_4_0.so
1aa87faf8b - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86_64/libopencv_xfeatures2d_4_0.so
8553d1a235 - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86_64/libopencv_ximgproc_4_0.so
28bbaa3554 - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86_64/libopencv_xphoto_4_0.so
1a2401dbad - Assets/Externals/OpenCVForUnity/Plugins/Linux/x86_64/libopencvforunity.so
7510ac9559 - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/ARM/opencv_aruco400.dll
b44f0d0d70 - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/ARM/opencv_bgsegm400.dll
39a48fd48f - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/ARM/opencv_bioinspired400.dll
b6e2ced12d - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/ARM/opencv_calib3d400.dll
dc1099a6e9 - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/ARM/opencv_ccalib400.dll
c9deb1c275 - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/ARM/opencv_core400.dll
5306f5727c - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/ARM/opencv_face400.dll
db687c5c4a - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/ARM/opencv_features2d400.dll
409a758bd1 - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/ARM/opencv_flann400.dll
5d462f9538 - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/ARM/opencv_fuzzy400.dll
563b5a0bc8 - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/ARM/opencv_highgui400.dll
ac6d17546c - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/ARM/opencv_img_hash400.dll
18bfc0f0fa - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/ARM/opencv_imgcodecs400.dll
576f3b55ec - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/ARM/opencv_imgproc400.dll
d2f685e729 - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/ARM/opencv_ml400.dll
239b3c8bcc - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/ARM/opencv_objdetect400.dll
da066daf7f - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/ARM/opencv_optflow400.dll
03fe2b613b - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/ARM/opencv_phase_unwrapping400.dll
6ecd558fcc - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/ARM/opencv_photo400.dll
f012174c88 - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/ARM/opencv_plot400.dll
4df1e7a5c8 - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/ARM/opencv_reg400.dll
41572e700d - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/ARM/opencv_saliency400.dll
ae48be9764 - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/ARM/opencv_shape400.dll
dfe2692ec4 - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/ARM/opencv_stitching400.dll
44eee384cc - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/ARM/opencv_structured_light400.dll
023c9adc7d - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/ARM/opencv_tracking400.dll
73b1490730 - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/ARM/opencv_video400.dll
8f189fdabb - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/ARM/opencv_videoio400.dll
3a4b5b6f1d - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/ARM/opencv_videostab400.dll
d37a90e8b2 - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/ARM/opencv_xfeatures2d400.dll
12e7203578 - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/ARM/opencv_ximgproc400.dll
db3b456aba - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/ARM/opencv_xphoto400.dll
d534f57973 - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/ARM/opencvforunity.dll
20ef63cf64 - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/x64/opencv_aruco400.dll
4a2eaebf69 - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/x64/opencv_bgsegm400.dll
52053c8189 - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/x64/opencv_bioinspired400.dll
b7bdb0ab6f - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/x64/opencv_calib3d400.dll
740cdf19d9 - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/x64/opencv_ccalib400.dll
8e9a8f31d8 - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/x64/opencv_core400.dll
165204f029 - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/x64/opencv_face400.dll
8c4ce9ac01 - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/x64/opencv_features2d400.dll
231e7393b3 - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/x64/opencv_flann400.dll
3158c5a51d - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/x64/opencv_fuzzy400.dll
87ef9604bd - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/x64/opencv_highgui400.dll
c0e43f900e - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/x64/opencv_img_hash400.dll
f523205fa7 - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/x64/opencv_imgcodecs400.dll
4597bc3227 - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/x64/opencv_imgproc400.dll
d2b2a6ca43 - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/x64/opencv_ml400.dll
1def30dc93 - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/x64/opencv_objdetect400.dll
14204f72c1 - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/x64/opencv_optflow400.dll
24cf1dc6ee - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/x64/opencv_phase_unwrapping400.dll
27724520e1 - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/x64/opencv_photo400.dll
44f17cd4e0 - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/x64/opencv_plot400.dll
a9aeb1e791 - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/x64/opencv_reg400.dll
522489719e - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/x64/opencv_saliency400.dll
ee121df267 - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/x64/opencv_shape400.dll
c191b74766 - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/x64/opencv_stitching400.dll
be18572530 - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/x64/opencv_structured_light400.dll
38ceeb531f - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/x64/opencv_tracking400.dll
2328fa16dd - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/x64/opencv_video400.dll
6f4c122218 - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/x64/opencv_videoio400.dll
f54cae8d33 - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/x64/opencv_videostab400.dll
c4d86e5674 - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/x64/opencv_xfeatures2d400.dll
5555ce2d0f - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/x64/opencv_ximgproc400.dll
d4c6178bf7 - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/x64/opencv_xphoto400.dll
d7f6901e45 - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/x64/opencvforunity.dll
7248281592 - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/x86/opencv_aruco400.dll
5a594e2d9e - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/x86/opencv_bgsegm400.dll
bc9bcc91ed - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/x86/opencv_bioinspired400.dll
1ae13533b3 - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/x86/opencv_calib3d400.dll
099d9e26fc - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/x86/opencv_ccalib400.dll
87dc1afbd5 - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/x86/opencv_core400.dll
3ef4a3a3be - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/x86/opencv_face400.dll
324165de32 - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/x86/opencv_features2d400.dll
71a40cda8a - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/x86/opencv_flann400.dll
80c6d63650 - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/x86/opencv_fuzzy400.dll
830695a9b2 - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/x86/opencv_highgui400.dll
95f4ee7db3 - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/x86/opencv_img_hash400.dll
0bb8aa95b4 - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/x86/opencv_imgcodecs400.dll
0bc5c546f7 - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/x86/opencv_imgproc400.dll
8da09327c7 - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/x86/opencv_ml400.dll
ab9fd98c74 - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/x86/opencv_objdetect400.dll
fd4cfea2ff - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/x86/opencv_optflow400.dll
76baddd986 - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/x86/opencv_phase_unwrapping400.dll
1a0a8a7775 - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/x86/opencv_photo400.dll
022387bd0c - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/x86/opencv_plot400.dll
e0b2d0b253 - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/x86/opencv_reg400.dll
491dedc390 - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/x86/opencv_saliency400.dll
a0d67a70ff - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/x86/opencv_shape400.dll
c53950319a - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/x86/opencv_stitching400.dll
21ac9ae1fd - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/x86/opencv_structured_light400.dll
09594aaa35 - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/x86/opencv_tracking400.dll
a1a1acd41d - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/x86/opencv_video400.dll
e8f0a4a5dd - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/x86/opencv_videoio400.dll
74097fd9b4 - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/x86/opencv_videostab400.dll
7e27c0b250 - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/x86/opencv_xfeatures2d400.dll
8c5a0be5a7 - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/x86/opencv_ximgproc400.dll
1d670e21ae - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/x86/opencv_xphoto400.dll
6486bb04ca - Assets/Externals/OpenCVForUnity/Plugins/WSA/UWP/x86/opencvforunity.dll
f6fcc7400f - Assets/Externals/OpenCVForUnity/Plugins/WebGL/2018.2/opencvforunity.bc
544f9adff6 - Assets/Externals/OpenCVForUnity/Plugins/WebGL/5.6/opencvforunity.bc
4fdc4901bf - Assets/Externals/OpenCVForUnity/Plugins/Windows/x86/opencvforunity.dll
713f8f8382 - Assets/Externals/OpenCVForUnity/Plugins/Windows/x86_64/opencvforunity.dll
2065258496 - Assets/Externals/OpenCVForUnity/Plugins/iOS/libopencvforunity.a
```

50MBを超えるファイル以外もたくさん管理対象になっているようですが、一旦はこのまま進めます。

Git LFSの作業としては以上となります。

## pushする

いよいよpushですが、いくつか問題が発生する場合があります。

pushしてみて問題なかった方はおめでとうございます。
以降の文章は読み飛ばしてしまっても良いかも知れません。

### コンフリクトしている場合

```sh
$ git push origin master 
To github.com:hoge/project.git
 ! [rejected]        master -> master (non-fast-forward)
error: failed to push some refs to 'git@github.com:hoge/project.git'
hint: Updates were rejected because the tip of your current branch is behind
hint: its remote counterpart. Integrate the remote changes (e.g.
hint: 'git pull ...') before pushing again.
hint: See the 'Note about fast-forwards' in 'git push --help' for details.
```

`git lfs migrate import`で過去のコミットが改変されているので、その差分で弾かれてしまいます。

こうなった場合は、チームの空気を読みつつ**「えいっ」**ってやりましょう。

```sh
$ git push --force origin master
```

(事前に`$ git push origin master:test-master`で確認した方が丁寧かもしれません。)

### Git LFSの容量・転送量が不足している場合

```sh
$ git push --force origin master
batch response: This repository is over its data quota. Purchase more data packs to restore access.                                                                                                                                           
batch response: This repository is over its data quota. Purchase more data packs to restore access.
Uploading LFS objects:   0% (0/100), 0 B | 0 B/s, done
error: failed to push some refs to 'git@github.com:hoge/project.git'
```

GitHubのLFSサービスでは、無料プランだと容量が1GB、転送量が月に1GBとされています。そのため、これを超える分をLFSで管理する場合には、追加の月額課金($5〜)もしくは自前でLFSサーバーを立てる必要があります。

1GBという容量は自分(または組織)の全てのリポジトリの合計での容量なので、この制限にかかってしまう場合が多いように思います。

[Git LFSの管理対象を設定する](#git-lfsの管理対象を設定する)ではファイルを種別ごと一括で設定しましたが、容量不足を危惧するのであれば100MBを超えるファイルだけにした方がよいかもしれません。

それでも問題が解消しなかった場合、次のパターンに進んでください。

# パターン2: 大容量ファイルを取り除く

状況を整理してみましょう。
問題になっているのは100MBを超える以下のファイルがコミットできないことです。

- `Assets/Externals/OpenCVForUnity/Plugins/iOS/opencv2.framework/opencv2`
- `Assets/Externals/OpenCVForUnity/Extra/exclude_contrib/iOS/opencv2.framework/opencv2`

お気づきでしょうか？
該当のファイルはどちらも**iOS用**のファイルです。

![Nov-19-2018 17-34-01.gif](https://qiita-image-store.s3.amazonaws.com/0/55365/3c2f2745-fdce-15e9-977c-7152adc4488d.gif)

ということで、私の場合はiOSのディレクトリ毎削除してしまって対応しました。
(コミット履歴に残らないようにするため、コミットし直し or rebaseなどの対応は別途必要です)

# [追記] パターン3

<blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr">僕はgitignoreで対象ファイルを外した</p>&mdash; かいき@XR (@kaikiofkaiki) <a href="https://twitter.com/kaikiofkaiki/status/1064445842050797569?ref_src=twsrc%5Etfw">2018年11月19日</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

メリデメありますが、これも良さそうですね。

# まとめ

GitHubの提供するLFSサービスは無料枠だとライトな使い方しか出来ないようです。
そのため、ある程度以上のプロダクトでは、追加課金か自前サーバーなどで対応する必要がありそうです。

今回はプロトタイプ開発のコードをGit管理したいという要件だったので、場当たり的な方法で対処をしました。
本位ではありませんが、現実的な落とし所ではないでしょうか。

どなたかの参考になれば幸いです。

# 参考

Git LFSの導入方法 - Qiita
https://qiita.com/takish/items/4b397caa5549a39a8194

Unity のプロジェクトで Git LFS を使い始めた記録 - chienote
https://chiepomme.gitbook.io/chienote/git/unity-git-lfs

