import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  FirestoreService._();

  static final instance = FirestoreService._();

  Future<DocumentReference> createData({
    required String path,
    required Map<String, dynamic> data,
    bool merge = false,
  }) async {
    final reference = await FirebaseFirestore.instance.collection(path).add(data);
    return reference;
  }

  DocumentReference createDataWithBatch({
    required WriteBatch batch,
    required String path,
    required Map<String, dynamic> data,
    bool merge = false,
  }) {
    final DocumentReference reference = FirebaseFirestore.instance.collection(path).doc();
    batch.set(reference, (data), SetOptions(merge: merge));
    return reference;
  }

  Future<void> createDataWithId({
    required String path,
    required Map<String, dynamic> data,
    required String id,
    bool merge = false,
  }) async {
    return FirebaseFirestore.instance.collection(path).doc(id).set(data);
  }

  void createDataWithBatchAndId({
    required WriteBatch batch,
    required String path,
    required Map<String, dynamic> data,
    required String id,
    bool merge = false,
  }) {
    final DocumentReference reference = FirebaseFirestore.instance.collection(path).doc(id);
    batch.set(reference, (data), SetOptions(merge: merge));
  }

  Future<DocumentReference> setDataWithBatch({
    required WriteBatch batch,
    required String path,
    required Map<String, dynamic> data,
    bool merge = false,
  }) async {
    final reference = FirebaseFirestore.instance.doc(path);
    batch.set(reference, (data), SetOptions(merge: merge));
    return reference;
  }

  Future<DocumentReference> setData({
    required String path,
    required Map<String, dynamic> data,
    bool merge = false,
  }) async {
    final reference = FirebaseFirestore.instance.doc(path);
    print('$path: $data');
    await reference.set(data, SetOptions(merge: merge));
    return reference;
  }

  Future<DocumentReference> setDataWithTransaction({
    required Transaction transaction,
    required String path,
    required Map<String, dynamic> data,
    bool merge = false,
  }) async {
    final reference = FirebaseFirestore.instance.doc(path);
    print('$path: $data');
    transaction.set(reference, (data), SetOptions(merge: merge));
    return reference;
  }

  Future<void> deleteData({required String path}) async {
    final reference = FirebaseFirestore.instance.doc(path);
    print('delete: $path');
    await reference.delete();
  }

  Stream<List<T>> collectionStream<T>({
    required String path,
    required T builder(
      Map<String, dynamic>? data,
      String documentID,
    ),
    Query Function(Query query)? queryBuilder,
    int Function(T lhs, T rhs)? sort,
  }) {
    Query query = FirebaseFirestore.instance.collection(path);
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }
    final Stream<QuerySnapshot> snapshots = query.snapshots();
    return snapshots.map((snapshot) {
      final result = snapshot.docs.map((snapshot) => builder(snapshot.data() as Map<String, dynamic>, snapshot.id)).where((value) => value != null).toList();
      if (sort != null) {
        result.sort(sort);
      }
      return result;
    });
  }

  Stream<T> documentStream<T>({
    required String path,
    required T builder(Map<String, dynamic>? data, String documentID),
  }) {
    final DocumentReference reference = FirebaseFirestore.instance.doc(path);
    final Stream<DocumentSnapshot> snapshots = reference.snapshots();
    return snapshots.map((snapshot) => builder(snapshot.data() as Map<String, dynamic>, snapshot.id));
  }

  Future<T> getData<T>({
    required String path,
    required T builder(Map<String, dynamic>? data, String documentID),
  }) async {
    final DocumentReference reference = FirebaseFirestore.instance.doc(path);
    final DocumentSnapshot snapshot = await reference.get();
    return builder(snapshot.data() as Map<String, dynamic>, snapshot.id);
  }
}
