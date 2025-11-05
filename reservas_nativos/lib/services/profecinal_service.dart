import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:reservas_nativos/models/profecionales_models.dart';

class ProfessionalsService {
  final CollectionReference _professionalsRef = FirebaseFirestore.instance
      .collection('professionals');

  // ✅ Crear profesional (asociado al usuario autenticado)
  Future<void> addProfessional(Professional professional) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      throw Exception('❌ No hay usuario autenticado.');
    }

    try {
      // Creamos el documento manualmente para tener acceso a su ID
      final docRef = _professionalsRef.doc();

      final data = {
        ...professional.toMap(),
        'id': docRef.id, // 🔥 Ahora guardamos el id
        'companyId': currentUser.uid,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await docRef.set(data);
      print('✅ Profesional agregado correctamente con ID: ${docRef.id}');
    } catch (e) {
      print('❌ Error al agregar profesional: $e');
      rethrow;
    }
  }

  // ✅ Obtener profesionales del usuario autenticado
  Stream<List<Professional>> getProfessionals() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print('⚠️ No hay usuario autenticado. Retornando Stream vacío.');
      return const Stream.empty();
    }

    return _professionalsRef
        .where('companyId', isEqualTo: currentUser.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          print(
            '📦 PROFESIONALES (${currentUser.uid}): ${snapshot.docs.length} encontrados.',
          );

          return snapshot.docs.map((doc) {
            try {
              return Professional.fromMap(
                doc.id,
                doc.data() as Map<String, dynamic>,
              );
            } catch (e, st) {
              print('❌ Error al mapear profesional (${doc.id}): $e');
              print(st);
              return Professional(
                id: doc.id,
                name: 'Error',
                email: '',
                phone: '',
                role: '',
                services: [],
                companyId: '',
              );
            }
          }).toList();
        });
  }

  // ✅ Actualizar profesional
  Future<void> updateProfessional(String id, Map<String, dynamic> data) async {
    await _professionalsRef.doc(id).update(data);
    print('🛠 Profesional actualizado: $id');
  }

  // ✅ Eliminar profesional
  Future<void> deleteProfessional(String id) async {
    await _professionalsRef.doc(id).delete();
    print('🗑 Profesional eliminado: $id');
  }

  // ✅ Obtener un profesional específico
  Future<Professional?> getProfessionalById(String id) async {
    final doc = await _professionalsRef.doc(id).get();
    if (!doc.exists) return null;

    return Professional.fromMap(id, doc.data() as Map<String, dynamic>);
  }
}
