import 'dart:io';
import 'dart:math';

import 'package:xftts/xftts.dart';
import 'package:test/test.dart';

void main() {
  group('test utility functions', () {
    test('split text works', () {
      final result = splitText('hello world this is super good', 12, regex: r'\s+').toList();
      expect(result.length, 3);
      expect(result[0], 'hello\nworld');
      expect(result[1], 'this\nis');
      expect(result[2], 'super\ngood');
    });
  });
}
