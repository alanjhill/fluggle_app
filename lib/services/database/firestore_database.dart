import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluggle_app/models/game/game.dart';
import 'package:fluggle_app/models/game/player.dart';
import 'package:fluggle_app/models/user/app_user.dart';
import 'package:fluggle_app/models/user/friend.dart';
import 'package:fluggle_app/services/firestore/firestore_path.dart';
import 'package:fluggle_app/services/firestore/firestore_service.dart';

String documentIdFromCurrentDate() => DateTime.now().toIso8601String();

class FirestoreDatabase {
  final String uid;

  FirestoreDatabase({required this.uid}) : assert(uid != null);

  final _service = FirestoreService.instance;

  /// Get all friends for a uid
  Stream<List<Friend>> friendsStream() => _service.collectionStream<Friend>(
        path: FirestorePath.userFriends(uid),
        builder: (data, documentId) => Friend.fromMap(data!, documentId),
      );

  /// Get user from uid
  Stream<List<AppUser>> userStream(String uid) => _service.collectionStream<AppUser>(
        path: FirestorePath.user(uid),
        builder: (data, documentId) => AppUser.fromMap(data!, documentId),
      );

  /// Get all users
  Stream<List<AppUser>> usersStream() => _service.collectionStream<AppUser>(
        path: FirestorePath.users(),
        builder: (data, documentId) => AppUser.fromMap(data!, documentId),
      );

  /// Search users
  Stream<List<AppUser>> findUsersByEmailStream({required String email}) => _service.collectionStream<AppUser>(
        path: FirestorePath.users(),
        builder: (data, documentId) => AppUser.fromMap(data!, documentId),
        queryBuilder: (query) => query.where('email', isEqualTo: email),
      );

  /// Get Game from gameId
  Stream<Game> gameStream({required String gameId}) => _service.documentStream(
        path: FirestorePath.game(gameId),
        builder: (data, documentId) => Game.fromMap(data!, documentId),
      );

  /// Get all Games (although probably not a good idea....need to query too)
  Stream<List<Game>> gamesStream() => _service.collectionStream<Game>(
        path: FirestorePath.games(),
        builder: (data, documentId) => Game.fromMap(data!, documentId),
      );

  Stream<List<Game>> get myPendingGamesStream => _service.collectionStream(
        path: FirestorePath.games(),
        builder: (data, documentId) => Game.fromMap(data, documentId),
        queryBuilder: (query) => query.where('playerUids.${uid}', isEqualTo: PlayerStatus.invited.toString()).where(
              'gameStatus',
              isEqualTo: GameStatus.created.toString(),
            ),
        sort: (Game lhs, Game rhs) => rhs.created.compareTo(lhs.created),
      );

  Stream<List<Game>> get myPreviousGamesStream => _service.collectionStream(
        path: FirestorePath.games(),
        builder: (data, documentId) => Game.fromMap(data, documentId),
        queryBuilder: (query) => query.where('playerUids.${uid}', isEqualTo: PlayerStatus.finished.toString()).where(
              'gameStatus',
              isEqualTo: GameStatus.finished.toString(),
            ),
        sort: (Game lhs, Game rhs) => rhs.created.compareTo(lhs.created),
      );

  doSomething(QuerySnapshot snapshot) async {
    var docs = snapshot.docs;
    for (var doc in docs) {
      print('doc: ${doc}');
    }
  }

  Stream<List<Game>> _myPendingGamesStream() {
    return FirebaseFirestore.instance
        .collection('games')
        .where('playerUids', arrayContains: uid)
        .where('gameStatus', isEqualTo: GameStatus.created.toString())
        .orderBy('created', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((document) {
        Game game = Game.fromMap(document.data(), document.id);
        return game;
      }).toList();
    });
  }

  Stream<List<Player>> playersStream({required String gameId}) => _service.collectionStream<Player>(
        path: FirestorePath.gamePlayers(gameId),
        builder: (data, documentId) => Player.fromMap(data!, documentId),
      );

  Stream<List<Player>> gamePlayerStream({required String gameId, required bool includeSelf}) => _service.collectionStream<Player>(
        path: FirestorePath.gamePlayers(gameId),
        builder: (data, documentId) => Player.fromMap(data!, documentId),
        queryBuilder: !includeSelf ? (query) => query.where('uid', isNotEqualTo: uid) : null,
      );

  Future<Game> getGame({required String gameId}) => _service.getData<Game>(
        path: FirestorePath.game(gameId),
        builder: (data, documentId) => Game.fromMap(data!, documentId),
      );

  Future<void> saveGame({required Game game}) async {
    var gameToMap = game.toMap();
    await _service.setData(
      path: FirestorePath.game(game.gameId),
      data: gameToMap,
      merge: true,
    );
  }

  Future<Friend> _addFriend({required String friendId, FriendStatus friendStatus = FriendStatus.invited}) async {
    Friend friend = Friend(friendId: friendId, friendStatus: friendStatus);
    await _service.setData(
      path: FirestorePath.userFriend(uid, friendId),
      data: friend.toMap(),
      merge: true,
    );

    return friend;
  }

  Future<Friend> addFriend({
    required FriendStatus inviterStatus,
    required Friend friend,
  }) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();

    // Add the friend to this user
    await _service.setDataWithBatch(
      batch: batch,
      path: FirestorePath.userFriend(uid, friend.friendId),
      data: friend.toMap(),
      merge: true,
    );

    // Add this user to the friend
    Friend inviter = Friend(friendId: uid, friendStatus: inviterStatus);
    await _service.setDataWithBatch(
      batch: batch,
      path: FirestorePath.userFriend(friend.friendId, uid),
      data: inviter.toMap(),
      merge: true,
    );

    batch.commit().whenComplete(() {
      print('Complete');
    });

    print('returning invitedFriend...');
    return friend;
  }

  Stream<AppUser> appUserStream({required String uid}) => _service.documentStream<AppUser>(
        path: FirestorePath.user(uid),
        builder: (data, documentId) => AppUser.fromMap(data!, documentId),
      );

  Future<AppUser> getUser({required String uid}) => _service.getData<AppUser>(
        path: FirestorePath.user(uid),
        builder: (data, documentId) => AppUser.fromMap(data!, documentId),
      );

  Future<void> updateUserData({required AppUser user}) async {
    var userToMap = user.toMap();
    await _service.setData(
      path: FirestorePath.user(uid),
      data: userToMap,
      merge: true,
    );
  }

  Future<Player> getGamePlayer({
    required String gameId,
    required String playerUid,
  }) =>
      _service.getData<Player>(
        path: FirestorePath.gamePlayer(gameId, playerUid),
        builder: (data, documentId) => Player.fromMap(data!, documentId),
      );

  Future<void> saveGamePlayer({required Game game, required Player player}) async {
    var playerToMap = player.toMap();
    await _service.setData(
      path: FirestorePath.gamePlayer(game.gameId!, player.uid),
      data: playerToMap,
      merge: true,
    );
  }

  Future<String>? createGame(Game game, List<Player> players) async {
    String? gameId;

    // Create the game and get the game id
    var documentRef = await _service.createData(
      path: FirestorePath.games(),
      data: game.toMap(),
    );

    // Get the gameId
    gameId = documentRef.id;

    // If we have a game id, create the Players...
    if (gameId != null) {
      // Set Players
      players.forEach((Player player) async {
        await _service.createDataWithId(
          path: FirestorePath.addPlayer(gameId!),
          data: player.toMap(),
          id: player.uid,
        );
      });
    }

    return gameId;
  }

  Future<String>? createGameWithTransaction(Game game) async {
    String? gameId;

    WriteBatch batch = FirebaseFirestore.instance.batch();

    // Create the game and get the game id
    var documentRef = _service.createDataWithBatch(
      batch: batch,
      path: FirestorePath.games(),
      data: game.toMap(),
    );

    // Get the gameId
    gameId = documentRef.id;

    // If we have a game id, create the Players...
    if (gameId != null) {
      List<Player>? players = game.players;

      // Set Players
      players!.forEach((Player player) async {
        _service.createDataWithBatchAndId(
          batch: batch,
          path: FirestorePath.addPlayer(gameId!),
          data: player.toMap(),
          id: player.uid,
        );
      });

      batch.commit().whenComplete(() {
        print('Complete');
      });
    }

    return gameId;
  }
}

class CombineStream {
  final Game game;
  final List<Player> players;

  CombineStream(this.game, this.players);
}
