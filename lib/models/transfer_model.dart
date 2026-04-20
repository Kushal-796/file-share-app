enum TransferStatus { pending, uploading, completed, failed, cancelled }

class TransferModel {
  final String transferId;
  final String senderId;
  final String senderCode;
  final String receiverCode;
  final String fileName;
  final int fileSize;
  final String? fileUrl;
  final TransferStatus status;
  final DateTime timestamp;

  TransferModel({
    required this.transferId,
    required this.senderId,
    required this.senderCode,
    required this.receiverCode,
    required this.fileName,
    required this.fileSize,
    this.fileUrl,
    required this.status,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'transferId': transferId,
      'senderId': senderId,
      'senderCode': senderCode,
      'receiverCode': receiverCode,
      'fileName': fileName,
      'fileSize': fileSize,
      'fileUrl': fileUrl,
      'status': status.name,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory TransferModel.fromMap(Map<String, dynamic> map) {
    return TransferModel(
      transferId: map['transferId'] ?? '',
      senderId: map['senderId'] ?? '',
      senderCode: map['senderCode'] ?? '',
      receiverCode: map['receiverCode'] ?? '',
      fileName: map['fileName'] ?? '',
      fileSize: map['fileSize'] ?? 0,
      fileUrl: map['fileUrl'],
      status: TransferStatus.values.byName(map['status'] ?? 'pending'),
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
