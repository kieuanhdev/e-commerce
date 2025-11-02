import 'dart:async';
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
  /// Note: Returns unsorted data for better performance
  Future<List<T>> getAll() async {
    try {
      final snapshot = await _collection
          .get(const GetOptions(source: Source.serverAndCache))
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw TimeoutException('Firestore query timeout after 30 seconds');
            },
          );
      return snapshot.docs.map((doc) {
        try {
          return fromFirestore(doc);
        } catch (error) {
          print('Error parsing document ${doc.id}: $error');
          rethrow;
        }
      }).toList();
    } on FirebaseException catch (e) {
      print('Firebase error in getAll(): ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Error in getAll(): $e');
      rethrow;
    }
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
  /// Note: Returns unsorted data for better performance
  Stream<List<T>> watchAll() {
    return _collection
        .snapshots()
        .map((snapshot) => snapshot.docs.map((e) => fromFirestore(e)).toList());
  }
}
