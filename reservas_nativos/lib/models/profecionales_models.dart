import 'package:cloud_firestore/cloud_firestore.dart';

class Professional {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final List<String> services;
  final String companyId;

  Professional({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.services,
    required this.companyId,
  });

  // ✅ Convertir modelo a mapa (para subir a Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'services': services,
      'companyId': companyId,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  // ✅ Crear modelo desde Firestore
  factory Professional.fromMap(String id, Map<String, dynamic> data) {
    return Professional(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      role: data['role'] ?? '',
      services: List<String>.from(data['services'] ?? []),
      companyId: data['companyId'] ?? '',
    );
  }
}
