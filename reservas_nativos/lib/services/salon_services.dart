import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/service_model.dart';

class SalonServicesService {
  final CollectionReference _servicesRef = FirebaseFirestore.instance
      .collection('salon_services');

  final CollectionReference _professionalsRef = FirebaseFirestore.instance
      .collection('professionals');

  // ✅ Crear servicio
  Future<void> addService(SalonService service) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception('❌ No hay usuario autenticado.');
    }

    try {
      final docRef = _servicesRef.doc();
      final serviceId = docRef.id;

      final data = {
        ...service.toMap(),
        'id': serviceId,
        'companyId': currentUser.uid,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await docRef.set(data);

      await _professionalsRef.doc(service.professionalId).update({
        'services': FieldValue.arrayUnion([serviceId]),
      });
    } catch (e, st) {
      print('❌ Error al guardar servicio: $e');
      print(st);
      rethrow;
    }
  }

  // 🟢 Método: Obtener servicios filtrados por Sede
  Stream<List<SalonService>> getServicesByBranch(String branchId) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const Stream.empty();
    }

    return _servicesRef
        .where('companyId', isEqualTo: currentUser.uid)
        .where('branchId', isEqualTo: branchId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            try {
              return SalonService.fromMap(
                doc.id,
                doc.data() as Map<String, dynamic>,
              );
            } catch (e) {
              print('Error mapeando servicio: $e');
              return SalonService(
                id: doc.id,
                name: 'Error',
                price: 0,
                duration: 0,
                professionalId: '',
                companyId: '',
                branchId: '',
              );
            }
          }).toList(),
        );
  }

  // 🟢 Método clave: Obtener servicios por profesional (USADO EN AGENDASCREEN)
  Stream<List<SalonService>> getServicesByProfessional(String professionalId) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const Stream.empty();
    }

    return _servicesRef
        .where('companyId', isEqualTo: currentUser.uid)
        .where('professionalId', isEqualTo: professionalId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            try {
              return SalonService.fromMap(
                doc.id,
                doc.data() as Map<String, dynamic>,
              );
            } catch (e) {
              print('Error mapeando servicio: $e');
              return SalonService(
                id: doc.id,
                name: 'Error',
                price: 0,
                duration: 0,
                professionalId: '',
                companyId: '',
                branchId: '',
              );
            }
          }).toList(),
        );
  }

  // Métodos restantes (getServices, updateService, deleteService) se mantienen.
  Stream<List<SalonService>> getServices() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return const Stream.empty();

    return _servicesRef
        .where('companyId', isEqualTo: currentUser.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            try {
              return SalonService.fromMap(
                doc.id,
                doc.data() as Map<String, dynamic>,
              );
            } catch (e) {
              return SalonService(
                id: doc.id,
                name: 'Error',
                price: 0,
                duration: 0,
                professionalId: '',
                companyId: '',
                branchId: '',
              );
            }
          }).toList(),
        );
  }

  Future<void> updateService(String id, Map<String, dynamic> data) async {
    await _servicesRef.doc(id).update(data);
  }

  Future<void> deleteService(String id) async {
    await _servicesRef.doc(id).delete();
  }
}
