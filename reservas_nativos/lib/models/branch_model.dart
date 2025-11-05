import 'package:cloud_firestore/cloud_firestore.dart';

class Branch {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String? imageUrl;
  final String? ownerId; // quién creó esta sede

  Branch({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    this.imageUrl,
    this.ownerId,
  });

  /// ✅ Convierte el objeto en un mapa para Firebase
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'phone': phone,
      'imageUrl': imageUrl,
      'ownerId': ownerId,
    };
  }

  /// ✅ Crea el objeto Branch desde Firestore
  factory Branch.fromMap(String id, Map<String, dynamic> data) {
    return Branch(
      id: id,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      phone: data['phone'] ?? '',
      imageUrl: data['imageUrl'],
      ownerId: data['ownerId'],
    );
  }

  /// ✅ Soporte alternativo si usas `.fromFirestore` directamente
  static Branch fromFirestore(QueryDocumentSnapshot<Object?> doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Branch.fromMap(doc.id, data);
  }
}
