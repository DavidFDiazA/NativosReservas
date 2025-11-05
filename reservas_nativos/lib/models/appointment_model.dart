import 'package:cloud_firestore/cloud_firestore.dart';

class Appointment {
  final String id;
  final String clientName;
  final String service;
  final DateTime date;
  final String status; // 'pending', 'confirmed', 'cancelled'
  final String? notes;

  Appointment({
    required this.id,
    required this.clientName,
    required this.service,
    required this.date,
    required this.status,
    this.notes,
  });

  factory Appointment.fromMap(Map<String, dynamic> data, String id) {
    return Appointment(
      id: id,
      clientName: data['clientName'],
      service: data['service'],
      date: (data['date'] as Timestamp).toDate(),
      status: data['status'],
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clientName': clientName,
      'service': service,
      'date': date,
      'status': status,
      'notes': notes,
    };
  }
}
