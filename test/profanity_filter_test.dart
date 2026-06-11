import 'package:flutter_test/flutter_test.dart';
import 'package:profanity_filter/profanity_filter.dart';
import 'package:safe_text/safe_text.dart';

void main() {
  setUpAll(() async {
    await SafeTextFilter.init(language: Language.english);
  });

  group('Profanity and SafeText Filter Tests', () {
    test('ProfanityFilter detects bad words', () {
      final filter = ProfanityFilter();
      expect(filter.hasProfanity('hello world'), isFalse);
      expect(filter.hasProfanity('you are an ass'), isTrue);
    });

    test('SafeTextFilter partially masks bad words', () {
      final text = 'this comment is bad and ass';
      final filtered = SafeTextFilter.filterText(
        text: text,
        strategy: MaskStrategy.partial(obscureSymbol: '*'),
      );
      // 'ass' is filtered as a**
      expect(filtered, contains('a**'));
      expect(filtered, isNot(contains('ass')));
    });
  });
}
