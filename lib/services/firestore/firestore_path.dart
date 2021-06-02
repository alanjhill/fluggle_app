class FirestorePath {
  static String users() => 'users';
  static String user(String? uid) => 'users/$uid';
  static String userFriends(String uid) => 'users/$uid/friends';
  static String userFriend(String uid, String friendId) => 'users/$uid/friends/$friendId';

  static String games() => 'games';
  static String game(String? id) => 'games/$id';
  static String players() => 'players';
  static String gamePlayers(String gameId) => 'games/$gameId/players';
  static String gamePlayer(String gameId, String playerId) => 'games/$gameId/players/$playerId';

  static String addPlayer(String gameId) => 'games/$gameId/players';

  static String addPlayerScore(String gameId) => 'games/$gameId/playerScores';
  static String updatePlayerScore(String gameId, String playerId) => 'games/$gameId/playerScores/$playerId';
}
