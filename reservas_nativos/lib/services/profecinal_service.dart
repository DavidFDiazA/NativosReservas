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
  Stream<List<Professional>> getProfessionals({String? branchId}) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const Stream.empty();
    }
    final ownerId = currentUser.uid;

    // 1. Inicia la consulta con el filtro obligatorio del dueño
    Query query = _professionalsRef.where('companyId', isEqualTo: ownerId);

    // 🔍 LOG EXPLICITO (INICIO)
    print('--- INICIANDO CONSULTA DE PROFESIONALES ---');
    print('   - Buscando por Dueño (companyId): $ownerId');

    // 2. Aplicar el filtro opcional de sede (branchId)
    if (branchId != null && branchId.isNotEmpty) {
      query = query.where('branchId', isEqualTo: branchId);
      print(
        '   - Y por Sede (branchId): $branchId',
      ); // ⬅️ ID de Sede usado en el filtro
    } else {
      print('   - SIN FILTRO POR SEDE (branchId).');
    }

    // 3. Ejecutar la consulta sin ordenación (para evitar el índice de 3 campos)
    return query.snapshots().map((snapshot) {
      print(
        '📦 PROFESIONALES (RESULTADO FINAL): ${snapshot.docs.length} encontrados.',
      );
      print('-------------------------------------------');

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
            branchId: '',
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

  // ✅ Obtener un profesional específico (CORREGIDO para aceptar branchId)
  Future<Professional?> getProfessionalById(
    String id, {
    String? branchId, // ⬅️ Nuevo parámetro nombrado opcional
  }) async {
    // 1. Iniciar la consulta filtrando por el campo 'id' dentro del documento.
    Query query = _professionalsRef.where('id', isEqualTo: id);

    // 2. Aplicar el filtro opcional de sede (branchId) si está presente
    if (branchId != null && branchId.isNotEmpty) {
      query = query.where('branchId', isEqualTo: branchId);
    }

    // 3. Obtener el resultado (solo esperamos un resultado y limitamos la consulta)
    final snapshot = await query.limit(1).get();

    if (snapshot.docs.isEmpty) {
      // Si no se encuentra, o no cumple ambos filtros, retorna null
      return null;
    }

    // 4. Mapear y retornar el primer resultado
    final doc = snapshot.docs.first;
    return Professional.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }
}
