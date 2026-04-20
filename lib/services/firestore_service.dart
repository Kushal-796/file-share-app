import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transfer_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream of incoming transfers for a specific user code
  Stream<List<TransferModel>> getIncomingTransfers(String userCode) {
    return _firestore
        .collection('transfers')
        .where('receiverCode', isEqualTo: userCode.toUpperCase())
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => TransferModel.fromMap(doc.data()))
              .toList();
        });
  }

  // Create a new transfer record
  Future<void> createTransfer(TransferModel transfer) async {
    await _firestore
        .collection('transfers')
        .doc(transfer.transferId)
        .set(transfer.toMap());
  }

  // Update transfer status
  Future<void> updateTransferStatus(String transferId, TransferStatus status, {String? fileUrl}) async {
    final Map<String, dynamic> data = {'status': status.name};
    if (fileUrl != null) {
      data['fileUrl'] = fileUrl;
    }
    await _firestore.collection('transfers').doc(transferId).update(data);
  }

  // Check if a user exists with this short code
  Future<bool> userExists(String shortCode) async {
    final query = await _firestore
        .collection('users')
        .where('shortCode', isEqualTo: shortCode.toUpperCase())
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }
}
