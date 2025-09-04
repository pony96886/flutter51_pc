# chaguaner2023

# 项目须知

1. flutter版本3.7.10，使用fvm确保自己的版本OK
2. 基于chrome调试，由于chrome最小字号是12像素，可能会有一定的显示偏差，如果是要看准确效果，可以build之后，使用http-server生成本地静态站点用safari访问。
3. App端没有 dart:html,只有web端才有，所以在用到 html 的地方需使用 universal_html 兼容。
运行调试命令：fvm flutter run -d chrome --web-renderer html --web-port=9999
 fvm flutter run -d chrome --web-browser-flag  "--disable-web-security"
真机调试 ip要改成你本机的ip
fvm flutter run -d chrome --web-hostname 192.168.1.116 --web-port 8080 --web-browser-flag  "--disable-web-security"
构建release命令：fvm flutter build web --web-renderer html --release（输出路径在build/web目录下面）
fvm flutter build web --web-renderer canvaskit --release
http-server --cors -p 8888 -o

fvm flutter build apk --target-platform  android-arm --split-per-abi --no-tree-shake-icons --obfuscate --split-debug-info=./symbols 打包安卓
fvm flutter build ios-framework --output=build/framework --no-tree-shake-icons --no-debug --no-profile --obfuscate --split-debug-info=./symbols 打包iOSSDK
fvm flutter build apk --obfuscate --split-debug-info=HLQ_Struggle

# 值得一提的第三方库

shelf iOS端用于架设代理服务器访问视频资源，从而实现加解密的处理
flutter_screenutil 屏幕尺寸适配组件
visibility_detector 判定元素是否进入视口的库，后期用于实现图片懒加载
（另外第三方库不一定适用web端，有的虽然写了支持web但实际运行不支持，需要调试做兼容处理）

# Web打包

fvm flutter build web --web-renderer html --release
dart add_version.dart
