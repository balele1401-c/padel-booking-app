import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/court_model.dart';

class CourtService {
  final FirebaseFirestore _firestore;

  CourtService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _courtsCollection => _firestore.collection('courts');

  /// Stream of all active courts with debug logging
  Stream<List<CourtModel>> getActiveCourtsStream() {
    debugPrint('🔥 DEBUG [CourtService]: Subscribing to "courts" collection stream...');
    return _courtsCollection.snapshots().map((snapshot) {
      debugPrint('🔥 DEBUG [CourtService]: Received snapshot with ${snapshot.docs.length} documents.');
      
      final list = <CourtModel>[];
      for (var doc in snapshot.docs) {
        try {
          final rawData = doc.data();
          debugPrint('🔥 DEBUG [CourtService]: Parsing Doc ID [${doc.id}] -> Data: $rawData');
          final court = CourtModel.fromFirestore(doc);
          debugPrint('🔥 DEBUG [CourtService]: Parsed successfully -> name: "${court.name}", price: ${court.pricePerHour}, isActive: ${court.isActive}');
          
          if (court.isActive) {
            list.add(court);
          }
        } catch (e, stack) {
          debugPrint('❌ ERROR [CourtService]: Error parsing Doc ID [${doc.id}]: $e\n$stack');
        }
      }
      
      debugPrint('🔥 DEBUG [CourtService]: Total active courts ready for UI: ${list.length}');
      return list;
    });
  }

  /// Stream of all courts (for Admin)
  Stream<List<CourtModel>> getAllCourtsStream() {
    return _courtsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => CourtModel.fromFirestore(doc)).toList();
    });
  }

  /// Get single court by ID
  Future<CourtModel?> getCourtById(String courtId) async {
    final doc = await _courtsCollection.doc(courtId).get();
    if (!doc.exists) return null;
    return CourtModel.fromFirestore(doc);
  }

  /// Add new court (Admin)
  Future<String> addCourt(CourtModel court) async {
    final docRef = await _courtsCollection.add(court.toFirestore());
    return docRef.id;
  }

  /// Update existing court (Admin)
  Future<void> updateCourt(CourtModel court) async {
    await _courtsCollection.doc(court.id).update(court.toFirestore());
  }

  /// Delete court (Admin)
  Future<void> deleteCourt(String courtId) async {
    await _courtsCollection.doc(courtId).delete();
  }
}
