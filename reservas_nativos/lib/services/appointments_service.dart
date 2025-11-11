// Archivo: lib/services/appointments_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment_model.dart';

class AppointmentsService {
  final _db = FirebaseFirestore.instance;

  // 🚀 MODIFICADO: Ahora requiere el userId para filtrar las citas
  Stream<List<Appointment>> getAppointmentsForDay(DateTime day, String userId) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));

    return _db
        .collection('appointments')
        // 🚀 AÑADIDO: Filtro por el ID del usuario autenticado
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: start)
        .where('date', isLessThan: end)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Appointment.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  // NUEVO: Verifica si la cita es única basándose en cliente, profesional y hora.
  Future<bool> checkIfAppointmentIsUnique(Appointment appointment) async {
    // Busca una cita que coincida en profesional, cliente y hora exacta.
    final QuerySnapshot result = await _db
        .collection('appointments')
        .where('professionalId', isEqualTo: appointment.professionalId)
        .where('clientName', isEqualTo: appointment.clientName)
        .where('date', isEqualTo: appointment.date)
        // Opcional: Podrías considerar agregar el filtro userId aquí para permitir
        // dos usuarios diferentes reserven el mismo slot si lo necesitas.
        .limit(1)
        .get();

    // Es única si no se encuentra ningún documento (docs.isEmpty).
    return result.docs.isEmpty;
  }

  // ✅ MODIFICADO: Añade una nueva cita a Firestore con chequeo de unicidad
  Future<void> addAppointment(Appointment appointment) async {
    final isUnique = await checkIfAppointmentIsUnique(appointment);

    if (!isUnique) {
      // Si no es única, lanzamos una excepción con un mensaje claro.
      throw Exception(
        'El cliente ya tiene una cita reservada con el mismo profesional y a la misma hora.',
      );
    }

    // Si es única, procedemos a agregarla.
    await _db.collection('appointments').add(appointment.toMap());
  }

  // Actualiza el estado de la cita (pending, confirmed, cancelled)
  Future<void> updateStatus(String id, String status) async {
    await _db.collection('appointments').doc(id).update({'status': status});
  }
}
