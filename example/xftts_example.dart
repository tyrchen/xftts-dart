import 'dart:io';

import 'package:xftts/xftts.dart';

void main() async {
  final env = Platform.environment;
  final app = env["APP"] ?? '1';
  final appId = env['XF_TTS_ID$app'];
  final apiKey = env['XF_TTS_KEY$app'];
  final apiSecret = env['XF_TTS_SECRET$app'];
  final vcn = env['XF_TTS_VCN'] ?? 'xiaoyan';
  final speed = env['XF_TTS_SPEED'] ?? 70;
  final volume = env['XF_TTS_VOLUME'] ?? 60;
  final tts = TTS(appId, apiKey, apiSecret, vcn: vcn, speed: speed, volume: volume);
  final text = '''
  ## Dart 介绍

  作为一门面向对象的语言，dart[1] 支持 mixin，泛型等高阶功能。

  ![](assets/dart.jpg)

  dart 采用了 async/await 的并发模型，每个 future 对象可以看做是一个独立的 coroutine。

  ```dart
  // some stupid code
  void main() {
    print('hello world!');
  }
  ```

  dart 虽然是静态类型，但它的类型模式和 TypeScript 很类似，类型声明虽然推荐但不强制。
  
  这几天使用下来，觉得 dart 做服务端开发似乎也不错，至少语言的表达能力要比 nodejs 背后的javascript 强。
  
  当然，目前使用 dart 的程序员几乎都是 flutter 程序员，但不排除未来会有类似 javascript -> nodejs
这样的前端逆袭后端的事情发生。

  <!-- skip_start -->
  毕竟，后端程序员的能力不断地被云服务商压扁，一个后台工程师辛辛苦苦攒的服务端代码，分分钟被
firebase 这样的怪兽逆袭。
  <!-- skip_end -->
  ''';
  await tts.generateMp3ForMarkdown(text, '/tmp/test.mp3', splitAt: 600);
  print('Done!');
}