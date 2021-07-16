class GameWord {
  final String word;
  bool? unique;
  int? score;

  GameWord({required this.word, this.unique, this.score = 0});

  factory GameWord.fromMap(Map<String, dynamic> map) {
    return GameWord(
      word: map['word'],
      unique: map['unique'],
      score: map['score'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'word': word,
      'unique': unique,
      'score': score,
    };
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is GameWord && runtimeType == other.runtimeType && word == other.word && unique == other.unique && score == other.score;

  @override
  int get hashCode => word.hashCode ^ unique.hashCode ^ score.hashCode;
}
