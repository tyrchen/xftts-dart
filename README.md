# xftts

Xun Fei TTS dart implementation based on: https://www.xfyun.cn/doc/tts/online_tts/API.html.

## Usage

A simple usage example:

```dart
import 'package:xftts/xftts.dart';

main() async {
  // retrieve appId/apiKey/apiSecret
  final env = Platform.environment;
  final app = env["APP"] ?? '1';
  final appId = env['XF_TTS_ID$app'];
  final apiKey = env['XF_TTS_KEY$app'];
  final apiSecret = env['XF_TTS_SECRET$app'];
  
  // initiate the class
  final tts = TTS(appId, apiKey, apiSecret);

  // generate mp3
  text = '''
  君不见黄河之水天上来，奔流到海不复回。
　君不见高堂明镜悲白发，朝如青丝暮成雪。
　人生得意须尽欢，莫使金樽空对月。
　天生我材必有用，千金散尽还复来。
  '''

  await tts.generateMp3ForText(text, '/tmp/test.mp3');
}
```


