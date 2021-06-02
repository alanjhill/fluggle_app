import 'package:fluggle_app/utils/dictionary.dart';

class Language {
  Language._(this.dictionary);

  Dictionary dictionary;

  static String? _languageCode;
  static LanguageLoader? _loader;
  static Language? _currentLanguage;

  /// Registers the [LanguageLoader]
  static void registerLoader(LanguageLoader loader) => _loader = loader;

  /// Returns a Future instance of [Language] for the given language [code].
  static Future<Language> forLanguageCode(String code) async {
    if (_languageCode == code) {
      return _currentLanguage!;
    }
    return _load(code).then((language) {
      _languageCode = code;
      _currentLanguage = language;
      return language;
    });
  }

  static Future<Language> _load(String code) async {
    return Future.wait<String>([
      _loader!.words(code),
    ]).then((List<String> files) {
      return Language._(Dictionary(files[0].split("\n")..sort()));
    }).then((Language language) {
      return language;
    });
  }

  Dictionary get language {
    return dictionary;
  }
}

/// Container for dictionary related elements that need to be loaded
class LanguageLoader {
  /// Creates an instance of [LanguageLoader]
  LanguageLoader({
    required this.words,
  });

  /// All  words
  Resolver words;
}

/// Returns a String for the given [languageCode]
typedef Future<String> Resolver(String languageCode);
