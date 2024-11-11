// lib/models/qr_key_data.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class QRKeyData {
  final String qrCode;
  final String key;

  QRKeyData({
    required this.qrCode,
    required this.key,
  });

  factory QRKeyData.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return QRKeyData(
      qrCode: data['QRcode'] ?? '',
      key: data['key'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'QRcode': qrCode,
      'key': key,
    };
  }
}