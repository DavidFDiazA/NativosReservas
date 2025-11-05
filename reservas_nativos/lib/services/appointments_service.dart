import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment_model.dart';

class AppointmentsService {
  final _db = FirebaseFirestore.instance;

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

  Future<void> updateStatus(String id, String status) async {
    await _db.collection('appointments').doc(id).update({'status': status});
  }
}
