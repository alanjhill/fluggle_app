class Dictionary {
  final List<String> _words;
  const Dictionary(this._words);

  bool exists(String word) {
    return _words.contains(word.toLowerCase());
  }
}
