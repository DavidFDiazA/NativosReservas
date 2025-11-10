import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment_model.dart';

class AppointmentsService {
  final _db = FirebaseFirestore.instance;

  // Obtiene todas las citas para un día específico
  Stream<List<Appointment>> getAppointmentsForDay(DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));

    return _db
        .collection('appointments')
        .where('date', isGreaterThanOrEqualTo: start)
        .where('date', isLessThan: end)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Appointment.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  // Añade una nueva cita a Firestore
  // Usa el método toMap() del modelo que incluye branchId, serviceId y professionalId
  Future<void> addAppointment(Appointment appointment) async {
    await _db.collection('appointments').add(appointment.toMap());
  }

  // Actualiza el estado de la cita (pending, confirmed, cancelled)
  Future<void> updateStatus(String id, String status) async {
    await _db.collection('appointments').doc(id).update({'status': status});
  }

}
