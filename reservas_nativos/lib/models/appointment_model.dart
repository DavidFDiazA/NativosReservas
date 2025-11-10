import 'package:cloud_firestore/cloud_firestore.dart';

class Appointment {
  final String id;
  final String clientName;
  // Campos de referencia
  final String branchId;
  final String professionalId;
  final String serviceId;
  // Campos existentes
  final String service; // Nombre del servicio
  final DateTime date;
  final String status; // 'pending', 'confirmed', 'cancelled'
  final String? notes;

  Appointment({
    required this.id,
    required this.clientName,
    required this.branchId,
    required this.professionalId,
    required this.serviceId,
    required this.service,
    required this.date,
    required this.status,
    this.notes,
  });

  factory Appointment.fromMap(Map<String, dynamic> data, String id) {
    return Appointment(
      id: id,
      clientName: data['clientName'],
      branchId: data['branchId'] ?? '',
      professionalId: data['professionalId'] ?? '',
      serviceId: data['serviceId'] ?? '',
      service: data['service'],
      date: (data['date'] as Timestamp).toDate(),
      status: data['status'],
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clientName': clientName,
      'branchId': branchId,
      'professionalId': professionalId,
      'serviceId': serviceId,
      'service': service,
      'date': date,
      'status': status,
      'notes': notes,
    };
  }
}
