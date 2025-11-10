import 'package:cloud_firestore/cloud_firestore.dart';

class Appointment {
  final String id;
  final String clientName;
  // Campos de referencia NUEVOS
  final String branchId;
  final String professionalId;
  final String serviceId;
  // Campos existentes
  final String service; // Nombre del servicio, mantenido por simplicidad
  final DateTime date;
  final String status; // 'pending', 'confirmed', 'cancelled'
  final String? notes;

  Appointment({
    required this.id,
    required this.clientName,
    required this.branchId, // NUEVO
    required this.professionalId, // NUEVO
    required this.serviceId, // NUEVO
    required this.service,
    required this.date,
    required this.status,
    this.notes,
  });

  factory Appointment.fromMap(Map<String, dynamic> data, String id) {
    return Appointment(
      id: id,
      clientName: data['clientName'],
      branchId: data['branchId'] ?? '', // NUEVO
      professionalId: data['professionalId'] ?? '', // NUEVO
      serviceId: data['serviceId'] ?? '', // NUEVO
      service: data['service'],
      date: (data['date'] as Timestamp).toDate(),
      status: data['status'],
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clientName': clientName,
      'branchId': branchId, // NUEVO
      'professionalId': professionalId, // NUEVO
      'serviceId': serviceId, // NUEVO
      'service': service,
      'date': date,
      'status': status,
      'notes': notes,
    };
  }
}
