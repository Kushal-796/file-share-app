import 'dart:io';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/transfer_model.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

class TransferProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();

  double _uploadProgress = 0.0;
  double get uploadProgress => _uploadProgress;

  bool _isTransferring = false;
  bool get isTransferring => _isTransferring;

  // Send multiple files logic
  Future<void> sendFiles({
    required List<File> files,
    required String senderId,
    required String senderCode,
    required String receiverCode,
  }) async {
    // 1. Block self-send
    if (senderCode.toUpperCase() == receiverCode.toUpperCase()) {
      throw Exception('You cannot send files to yourself.');
    }

    // 2. Check if receiver exists
    bool exists = await _firestoreService.userExists(receiverCode);
    if (!exists) {
      throw Exception('Receiver code not found. Please check and try again.');
    }

    _isTransferring = true;
    notifyListeners();

    for (var file in files) {
      try {
        final int fileSize = await file.length();
        
        // 3. Size limit 500MB
        if (fileSize > 500 * 1024 * 1024) {
          debugPrint('File ${file.path.split('/').last} is too large (>500MB). Skipping.');
          continue; // Don't kill the rest, just skip this one
        }

        final String transferId = Uuid().v4();
        final String fileName = file.path.split('/').last;

        final transfer = TransferModel(
          transferId: transferId,
          senderId: senderId,
          senderCode: senderCode,
          receiverCode: receiverCode.toUpperCase(),
          fileName: fileName,
          fileSize: fileSize,
          status: TransferStatus.pending,
          timestamp: DateTime.now(),
        );

        await _firestoreService.createTransfer(transfer);
        await _firestoreService.updateTransferStatus(transferId, TransferStatus.uploading);
        
        final String downloadUrl = await _storageService.uploadFile(
          file, 
          fileName, 
          transferId,
          (progress) {
            _uploadProgress = progress;
            notifyListeners();
          }
        );

        await _firestoreService.updateTransferStatus(
          transferId, 
          TransferStatus.completed, 
          fileUrl: downloadUrl
        );
      } catch (e) {
        debugPrint('Error sending file ${file.path}: $e');
        // Continue with the next file even if one fails
      }
    }

    _isTransferring = false;
    _uploadProgress = 0.0;
    notifyListeners();
  }

  Stream<List<TransferModel>> incomingTransfers(String userCode) {
    return _firestoreService.getIncomingTransfers(userCode);
  }
}
