  import 'dart:convert';

  /// split text by given regular expression and the merge them back for no larger than size
  Iterable<String> splitText(String text, int size, {String regex = r'\n+'}) sync* {
    final paragraphs = text.split(RegExp(regex));
    var i = 0;
    var group = paragraphs[i++];
    while (i < paragraphs.length) {
      final p = paragraphs[i++];
      if (utf8.encode(group).length + utf8.encode(p).length <= size - 1) {
        group += '\n${p}';
      } else {
        yield group;
        group = p;
      }
    }
    yield group;
  }