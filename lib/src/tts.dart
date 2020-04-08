import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:xftts/xftts.dart';

/// Xunfei TTS main class.
/// Usage:
/// 
///   var tts = TTS(appId, apiKey, apiSecret);
///   await tts.generateMp3ForText(text, filename);  
class TTS {
  final String appId;
  final String apiKey;
  final String apiSecret;
  final String vcn;
  final int speed;
  final int volume;

  TTS(
    this.appId,
    this.apiKey,
    this.apiSecret, {
    this.vcn = 'xiaoyan',
    this.speed = 65,
    this.volume = 60,
  })  : assert(appId != null),
        assert(apiKey != null),
        assert(apiSecret != null) {
    print('apiKey=$apiKey, apiSecret=$apiSecret');
  }

  /// generate connect url, based on doc in: https://www.xfyun.cn/doc/tts/online_tts/API.html
  String _getConnUrl() {
    final requestHost = 'tts-api.xfyun.cn';
    final host = 'ws-api.xfyun.cn';
    final url = '/v2/tts';
    final date = HttpDate.format(DateTime.now());
    final signatureOrigin = 'host: $host\ndate: $date\nGET $url HTTP/1.1';

    var hmacSha256 = Hmac(sha256, utf8.encode(apiSecret));
    final hash = hmacSha256.convert(utf8.encode(signatureOrigin));
    final signature = base64.encode(hash.bytes);

    final authOrigin = 'api_key="$apiKey", algorithm="hmac-sha256", '
        'headers="host date request-line", signature="$signature"';
    final authorization = base64.encode(utf8.encode(authOrigin));
    return 'wss://$requestHost$url?authorization=$authorization'
        '&date=${Uri.encodeFull(date)}&host=$host';
  }

  /// generate the request params, based on: generate connect url, based on doc in: https://www.xfyun.cn/doc/tts/online_tts/API.html
  String _genParam(String text) {
    final common = {'app_id': appId};
    final business = {
      'aue': 'lame',
      'sfl': 1,
      'auf': 'audio/L16;rate=16000',
      'vcn': vcn,
      'speed': speed,
      'volume': volume,
      'tte': 'utf8',
    };
    final data = {
      'status': 2,
      'text': base64.encode(utf8.encode(text)),
    };
    return json.encode({
      'common': common,
      'business': business,
      'data': data,
    });
  }

  /// generate mp3 based for the given text (must be smaller than max limit - 8000)
  Future<List<Uint8List>> _generateOne(String text) async {
    final url = _getConnUrl();
    var ws = await WebSocket.connect(url);
    if (ws?.readyState != WebSocket.open) {
      throw ('connection denied');
    }
    ws.add(_genParam(text));
    return ws.map((data) {
      final res = json.decode(data);

      if (res['code'] != 0) {
        throw ('code not zero: $res');
      }
      stdout.write('${res['data']['ced']} ');
      if (res['data']['status'] == 2) {
        stdout.write('\n');
        ws.close();
      }
      return base64.decode(res['data']['audio']);
    }).toList();
  }

  /// generate mp3 based on the text
  FutureOr<List<Uint8List>> generate(String text, {splitAt = 8000}) async {
    final parts = splitText(text, splitAt);
    print('Split to: ${parts.length} parts');
    var result = <Uint8List>[];
    for (final part in parts) {
      final buffers = await _generateOne(part);
      for (final buffer in buffers) {
        result.add(buffer);
      }
    }
    return result;
  }

  /// generate mp3 for pure text and save it to file
  void generateMp3ForText(String text, String filename, {splitAt = 8000}) async {
    final buffers = await generate(text, splitAt: splitAt);

    var file = File(filename);
    for (var i = 0; i < buffers.length; i++) {
      final buffer = buffers[i];
      await file.writeAsBytes(buffer,
          mode: i == 0 ? FileMode.write : FileMode.append);
    }
  }

  /// generate mp3 for filtered markdown text, and save it to file
  void generateMp3ForMarkdown(String text, String filename, {splitAt = 8000}) async {
    final content = text
      .replaceAll(RegExp(r'#+'), '') // remove headlines
      .replaceAll(RegExp(r'^\s*\*\s', multiLine: true), '') // remove unordered list
      .replaceAll(RegExp(r'!\[[^\]]*\]\([^\)]+\)'), '') // remove image tag
      .replaceAll(RegExp(r'(\d+)\s*'), '') // remove space between digits and words (may not good for english)
      .replaceAll(RegExp(r'\[\d+\]'), '') // remove [1], [2], ...
      .replaceAll(RegExp(r'```[^`]*```'), '') // remove code block
      .replaceAll(RegExp(r'__|\*\*'), '') // remove strengthen
      .replaceAll(RegExp(r'\<!--\s*skip_start\s*--\>[^]*?\<!--\s*skip_end\s*--\>'), '') // remove skipped content
      .replaceAll(RegExp(r'\<!--[^]*--\>'), ''); // remove html comments
    generateMp3ForText(content, filename, splitAt: splitAt);
  }
}
