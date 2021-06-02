class Dictionary {
  List<String> _words;
  Dictionary(this._words);

  bool exists(String word) {
    return _words.indexOf(word.toLowerCase()) > -1;
  }
}
