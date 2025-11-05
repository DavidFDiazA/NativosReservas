import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/service_model.dart';
// import 'profecinal_service.dart'; // No es necesario si solo usamos la referencia de colección

class SalonServicesService {
  final CollectionReference _servicesRef = FirebaseFirestore.instance
      .collection('salon_services');

  // ⬅️ Se añade la referencia a profesionales para poder actualizar el listado de servicios
  final CollectionReference _professionalsRef = FirebaseFirestore.instance
      .collection('professionals');

  // ✅ Crear servicio (asociado al usuario autenticado)
  Future<void> addService(SalonService service) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception('❌ No hay usuario autenticado.');
    }

    try {
      final docRef = _servicesRef.doc();
      final serviceId = docRef.id;

      // 1. Crear el mapa de datos. service.toMap() ahora incluye branchId
      final data = {
        ...service.toMap(),
        'id': serviceId,
        'companyId': currentUser.uid,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // 2. Guardar el nuevo servicio en la colección salon_services
      await docRef.set(data);
      print(
        '✅ Servicio guardado correctamente con id: $serviceId en sede ${service.branchId}',
      );

      // 3. Actualizar la lista de servicios en el documento del profesional
      await _professionalsRef.doc(service.professionalId).update({
        'services': FieldValue.arrayUnion([
          serviceId,
        ]), // Agrega el ID del servicio
      });
      print(
        '✅ Profesional ${service.professionalId} actualizado con el servicio $serviceId',
      );
    } catch (e, st) {
      print('❌ Error al guardar servicio: $e');
      print(st);
      rethrow;
    }
  }

  // ✅ Obtener servicios del usuario autenticado
  Stream<List<SalonService>> getServices() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print('⚠️ No hay usuario autenticado. Retornando Stream vacío.');
      return const Stream.empty();
    }

    return _servicesRef
        .where('companyId', isEqualTo: currentUser.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          print(
            '📦 SNAPSHOT SERVICIOS (${currentUser.uid}): ${snapshot.docs.length} encontrados.',
          );

          return snapshot.docs.map((doc) {
            try {
              return SalonService.fromMap(
                doc.id,
                doc.data() as Map<String, dynamic>,
              );
            } catch (e, st) {
              print('❌ Error al mapear servicio (${doc.id}): $e');
              print(st);
              return SalonService(
                id: doc.id,
                name: 'Error',
                price: 0,
                duration: 0,
                professionalId: '',
                companyId: '',
                branchId: '', // Campo añadido al modelo
              );
            }
          }).toList();
        });
  }

  // ✅ Obtener servicios por profesional (filtrados por empresa)
  Stream<List<SalonService>> getServicesByProfessional(String professionalId) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const Stream.empty();
    }

    // Esta consulta ya es eficiente porque la lista de profesionales en SalonScreen ya está filtrada por sede.
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
                branchId: '', // Campo añadido al modelo
              );
            }
          }).toList(),
        );
  }

  // ✅ Actualizar servicio
  Future<void> updateService(String id, Map<String, dynamic> data) async {
    await _servicesRef.doc(id).update(data);
    print('🛠 Servicio actualizado: $id');
  }

  // ✅ Eliminar servicio
  Future<void> deleteService(String id) async {
    await _servicesRef.doc(id).delete();
    print('🗑 Servicio eliminado: $id');
  }
}
