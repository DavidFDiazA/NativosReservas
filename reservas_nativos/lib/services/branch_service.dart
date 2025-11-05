import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/branch_model.dart';

class BranchesService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  CollectionReference get _branchesRef =>
      _firestore.collection('salon_branches');

  /// ✅ Agregar una nueva sede asociada al usuario actual
  Future<void> addBranch(Branch branch) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Usuario no autenticado");

    final branchData = branch.toMap();
    branchData['ownerId'] = user.uid;
    branchData['createdAt'] = FieldValue.serverTimestamp();

    await _branchesRef.add(branchData);
  }

  /// ✅ Obtener todas las sedes del usuario actual
  Stream<List<Branch>> getBranches() {
    final user = _auth.currentUser;
    if (user == null) {
      // Devuelve un stream vacío si no hay sesión
      return const Stream.empty();
    }

    return _branchesRef.where('ownerId', isEqualTo: user.uid).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        return Branch.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  /// ✅ Saber si el usuario ya tiene una sede registrada
  Future<bool> hasBranches() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final snapshot = await _branchesRef
        .where('ownerId', isEqualTo: user.uid)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  /// ✅ Actualizar datos de una sede
  Future<void> updateBranch(String id, Map<String, dynamic> data) async {
    await _branchesRef.doc(id).update(data);
  }

  /// ✅ Eliminar una sede
  Future<void> deleteBranch(String id) async {
    await _branchesRef.doc(id).delete();
  }

  Stream<List<Branch>> getBranchesByOwner(String ownerId) {
    return _branchesRef
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) =>
                    Branch.fromMap(doc.id, doc.data() as Map<String, dynamic>),
              )
              .toList(),
        );
  }

  Future<List<Branch>> getBranchesByOwnerOnce(String ownerId) async {
    final snapshot = await _branchesRef
        .where('ownerId', isEqualTo: ownerId)
        .get();
    return snapshot.docs
        .map(
          (doc) => Branch.fromMap(doc.id, doc.data() as Map<String, dynamic>),
        )
        .toList();
  }
}
