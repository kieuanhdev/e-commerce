import 'package:cloud_firestore/cloud_firestore.dart';
  
/// A generic Firestore DataSource for basic CRUD operations.
/// T = Model type that represents the Firestore document.
class FirebaseRemoteDS<T> {
  final String collectionName;
  final T Function(DocumentSnapshot doc) fromFirestore;
  final Map<String, dynamic> Function(T item) toFirestore;

  FirebaseRemoteDS({
    required this.collectionName,
    required this.fromFirestore,
    required this.toFirestore,
  });

  CollectionReference get _collection =>
      FirebaseFirestore.instance.collection(collectionName);

  /// Get all documents in the collection
  Future<List<T>> getAll() async {
    final snapshot = await _collection
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((e) => fromFirestore(e)).toList();
  }

  /// Get a single document by ID
  Future<T?> getById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;
    return fromFirestore(doc);
  }

  /// Add a new document
  Future<String> add(T item) async {
    final docRef = await _collection.add(toFirestore(item));
    return docRef.id;
  }

  /// Update an existing document
  Future<void> update(String id, T item) async {
    await _collection.doc(id).update(toFirestore(item));
  }

  /// Delete a document
  Future<void> delete(String id) async {
    await _collection.doc(id).delete();
  }

  /// Listen to realtime changes in a collection
  Stream<List<T>> watchAll() {
    return _collection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((e) => fromFirestore(e)).toList());
  }
}
