import 'package:flutter/material.dart';
import 'package:reservas_nativos/models/branch_model.dart';
import 'package:reservas_nativos/models/profecionales_models.dart';
import 'package:reservas_nativos/models/service_model.dart';
import 'package:reservas_nativos/services/branch_service.dart';
import 'package:reservas_nativos/services/profecinal_service.dart';
import 'package:reservas_nativos/services/salon_services.dart';

class SalonScreen extends StatefulWidget {
  const SalonScreen({super.key});

  @override
  State<SalonScreen> createState() => _SalonScreenState();
}

class _SalonScreenState extends State<SalonScreen> {
  final ProfessionalsService _profService = ProfessionalsService();
  final SalonServicesService _servService = SalonServicesService();
  final BranchesService _branchService = BranchesService();

  // Controladores de texto para servicios
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController priceCtrl = TextEditingController();
  final TextEditingController durCtrl = TextEditingController();

  // Variables para crear una NUEVA sede
  final TextEditingController branchNameCtrl = TextEditingController();
  final TextEditingController branchAddressCtrl = TextEditingController();
  final TextEditingController branchPhoneCtrl = TextEditingController();

  // Controladores de estado para diálogos y filtro
  String? selectedProId;
  String? _selectedFilterBranchId; // Para el filtro principal

  @override
  void dispose() {
    nameCtrl.dispose();
    priceCtrl.dispose();
    durCtrl.dispose();
    branchNameCtrl.dispose();
    branchAddressCtrl.dispose();
    branchPhoneCtrl.dispose();
    super.dispose();
  }

  // ----------------------------------------------------
  // DIÁLOGO PARA CREAR SEDE (NUEVA IMPLEMENTACIÓN)
  // ----------------------------------------------------
  void _showAddBranchDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text("Crear Nueva Sede"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: branchNameCtrl,
                  decoration: const InputDecoration(
                    labelText: "Nombre de la Sede",
                  ),
                ),
                TextField(
                  controller: branchAddressCtrl,
                  decoration: const InputDecoration(labelText: "Dirección"),
                ),
                TextField(
                  controller: branchPhoneCtrl,
                  decoration: const InputDecoration(labelText: "Teléfono"),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                branchNameCtrl.clear();
                branchAddressCtrl.clear();
                branchPhoneCtrl.clear();
                Navigator.pop(ctx);
              },
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (branchNameCtrl.text.isEmpty ||
                    branchAddressCtrl.text.isEmpty)
                  return;

                final newBranch = Branch(
                  id: '',
                  name: branchNameCtrl.text.trim(),
                  address: branchAddressCtrl.text.trim(),
                  phone: branchPhoneCtrl.text.trim(),
                  imageUrl: '',
                  ownerId: '', // Será llenado por el servicio
                );

                await _branchService.addBranch(newBranch);

                // 🔥 Sincronizar el filtro de sede al crear la primera
                if (mounted) {
                  setState(() {
                    // Usar el ID de la sede recién creada para que se vea inmediatamente
                    _selectedFilterBranchId = newBranch.id;
                  });
                }

                branchNameCtrl.clear();
                branchAddressCtrl.clear();
                branchPhoneCtrl.clear();

                if (mounted) Navigator.pop(ctx);
              },
              child: const Text("Guardar Sede"),
            ),
          ],
        );
      },
    );
  }

  // ----------------------------------------------------
  // Helper para el Dropdown de Sedes (se usa en los diálogos)
  // ----------------------------------------------------
  Widget _buildBranchDropdown({
    String? initialValue,
    required Function(String?) onChanged,
  }) {
    return StreamBuilder<List<Branch>>(
      stream: _branchService.getBranches(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: LinearProgressIndicator());
        }

        final branches = snapshot.data ?? [];
        if (branches.isEmpty) {
          return InkWell(
            onTap: _showAddBranchDialog,
            child: const Text(
              "❌ Crea una sede. Toca para agregar.",
              style: TextStyle(
                color: Colors.red,
                decoration: TextDecoration.underline,
              ),
            ),
          );
        }

        return DropdownButtonFormField<String>(
          value: initialValue,
          decoration: const InputDecoration(labelText: "Seleccionar Sede"),
          items: branches.map((branch) {
            return DropdownMenuItem(value: branch.id, child: Text(branch.name));
          }).toList(),
          onChanged: onChanged,
        );
      },
    );
  }

  // ----------------------------------------------------
  // Diálogos de Añadir Profesional y Servicio
  // ----------------------------------------------------

  // ✅ Diálogo para añadir nuevo servicio
  void _showAddServiceDialog() {
    String? dialogSelectedBranchId = _selectedFilterBranchId;

    showDialog(
      context: context,
      builder: (ctx2) {
        return StatefulBuilder(
          builder: (context, setStateInDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text("Agregar nuevo servicio"),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    // ⬅️ Selector de Sede para el nuevo servicio
                    _buildBranchDropdown(
                      initialValue: dialogSelectedBranchId,
                      onChanged: (val) =>
                          setStateInDialog(() => dialogSelectedBranchId = val),
                    ),
                    const SizedBox(height: 10),
                    if (dialogSelectedBranchId != null) ...[
                      // Mostrar campos si hay sede seleccionada
                      TextField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(labelText: "Nombre"),
                      ),
                      TextField(
                        controller: priceCtrl,
                        decoration: const InputDecoration(labelText: "Precio"),
                        keyboardType: TextInputType.number,
                      ),
                      TextField(
                        controller: durCtrl,
                        decoration: const InputDecoration(
                          labelText: "Duración (minutos)",
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 10),
                      StreamBuilder<List<Professional>>(
                        // ⬅️ Filtrar profesionales por la sede seleccionada en el diálogo
                        stream: _profService.getProfessionals(
                          branchId: dialogSelectedBranchId,
                        ),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Text(
                              "No hay profesionales disponibles en esta sede.",
                            );
                          }

                          final professionals = snapshot.data!;

                          return DropdownButtonFormField<String>(
                            value: selectedProId,
                            decoration: const InputDecoration(
                              labelText: "Seleccionar profesional",
                            ),
                            items: professionals.map((pro) {
                              return DropdownMenuItem(
                                value: pro.id,
                                child: Text(pro.name),
                              );
                            }).toList(),
                            onChanged: (val) => selectedProId = val,
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx2),
                  child: const Text("Cancelar"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameCtrl.text.isEmpty || dialogSelectedBranchId == null)
                      return;

                    await _servService.addService(
                      SalonService(
                        id: '',
                        name: nameCtrl.text.trim(),
                        price: double.tryParse(priceCtrl.text) ?? 0,
                        duration: int.tryParse(durCtrl.text) ?? 0,
                        professionalId: selectedProId ?? '',
                        companyId: '',
                        branchId: dialogSelectedBranchId!,
                      ),
                    );

                    nameCtrl.clear();
                    priceCtrl.clear();
                    durCtrl.clear();
                    selectedProId = null;

                    // Sincronizar el filtro de la pantalla principal
                    if (mounted) {
                      setState(() {
                        _selectedFilterBranchId = dialogSelectedBranchId;
                      });
                    }

                    if (mounted) Navigator.pop(ctx2);
                  },
                  child: const Text("Guardar"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ✅ Diálogo para agregar un profesional
  void _showAddProfessionalDialog() {
    final TextEditingController nameProCtrl = TextEditingController();
    final TextEditingController roleProCtrl = TextEditingController();
    String? dialogSelectedBranchId = _selectedFilterBranchId;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateInDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text("Agregar profesional"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ⬅️ Selector de Sede para el nuevo profesional
                  _buildBranchDropdown(
                    initialValue: dialogSelectedBranchId,
                    onChanged: (val) =>
                        setStateInDialog(() => dialogSelectedBranchId = val),
                  ),
                  const SizedBox(height: 10),
                  if (dialogSelectedBranchId != null) ...[
                    // Mostrar campos si hay sede seleccionada
                    TextField(
                      controller: nameProCtrl,
                      decoration: const InputDecoration(labelText: "Nombre"),
                    ),
                    TextField(
                      controller: roleProCtrl,
                      decoration: const InputDecoration(labelText: "Rol"),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Cancelar"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameProCtrl.text.isEmpty ||
                        roleProCtrl.text.isEmpty ||
                        dialogSelectedBranchId == null)
                      return;

                    final professional = Professional(
                      id: '',
                      name: nameProCtrl.text.trim(),
                      email: '',
                      phone: '',
                      role: roleProCtrl.text.trim(),
                      services: [],
                      companyId: '',
                      branchId: dialogSelectedBranchId!,
                    );

                    await _profService.addProfessional(professional);

                    // Sincronizar el filtro de la pantalla principal
                    if (mounted) {
                      setState(() {
                        _selectedFilterBranchId = dialogSelectedBranchId;
                      });
                    }

                    if (mounted) Navigator.pop(ctx);
                  },
                  child: const Text("Guardar"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ----------------------------------------------------
  // BUILD METHOD
  // ----------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final Color _dark = Colors.grey.shade900;

    return Scaffold(
      backgroundColor: _dark,
      appBar: AppBar(
        backgroundColor: _dark,
        title: const Text("Panel del Salón"),
        actions: [
          // ⬅️ BOTÓN PARA CREAR NUEVA SEDE (INTEGRADO EN EL FLUJO)
          IconButton(
            icon: const Icon(Icons.add_location_alt),
            onPressed: _showAddBranchDialog,
          ),
          IconButton(
            icon: const Icon(Icons.add_business),
            onPressed: _showAddProfessionalDialog,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddServiceDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // ⬅️ Selector de Sedes para Filtrado@
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: StreamBuilder<List<Branch>>(
              stream: _branchService.getBranches(),
              builder: (context, snapshot) {
                final branches = snapshot.data ?? [];

                if (branches.isEmpty) {
                  return Center(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add_home_work),
                      label: const Text("CREAR PRIMERA SEDE"),
                      onPressed: _showAddBranchDialog,
                    ),
                  );
                }

                // Inicializar el filtro automáticamente a la primera sede si es la primera vez
                if (_selectedFilterBranchId == null ||
                    !branches.any((b) => b.id == _selectedFilterBranchId)) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      _selectedFilterBranchId = branches.first.id;
                    });
                  });
                }

                if (_selectedFilterBranchId == null) {
                  return const LinearProgressIndicator();
                }

                return DropdownButtonFormField<String>(
                  value: _selectedFilterBranchId,
                  decoration: const InputDecoration(
                    labelText: "Filtrar por Sede Activa",
                    labelStyle: TextStyle(color: Colors.white),
                    fillColor: Color.fromARGB(255, 66, 66, 66),
                    filled: true,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white70),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.cyan),
                    ),
                  ),
                  dropdownColor: Colors.grey.shade800,
                  style: const TextStyle(color: Colors.white),
                  items: branches.map((branch) {
                    return DropdownMenuItem(
                      value: branch.id,
                      child: Text(branch.name),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedFilterBranchId = val;
                    });
                  },
                );
              },
            ),
          ),

          // ⬅️ Lista de Profesionales Filtrada
          Expanded(
            child: StreamBuilder<List<Professional>>(
              // ⬅️ Pasar el ID de la sede seleccionada para filtrar
              stream: _profService.getProfessionals(
                branchId: _selectedFilterBranchId,
              ),
              builder: (context, snapshotPro) {
                if (_selectedFilterBranchId == null) {
                  return const Center(
                    child: Text(
                      "Selecciona una sede.",
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                if (!snapshotPro.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final professionals = snapshotPro.data!;
                if (professionals.isEmpty) {
                  return Center(
                    child: Text(
                      "No hay profesionales registrados en esta sede.",
                      style: const TextStyle(color: Colors.white70),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: professionals.length,
                  itemBuilder: (context, index) {
                    final pro = professionals[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      color: Colors.grey.shade800,
                      child: ExpansionTile(
                        title: Text(
                          pro.name,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          pro.role,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        children: [
                          StreamBuilder<List<SalonService>>(
                            stream: _servService.getServicesByProfessional(
                              pro.id,
                            ),
                            builder: (context, snapshotServ) {
                              if (!snapshotServ.hasData) {
                                return const CircularProgressIndicator();
                              }

                              final services = snapshotServ.data!;
                              if (services.isEmpty) {
                                return const ListTile(
                                  title: Text(
                                    "No hay servicios aún",
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                );
                              }

                              return Column(
                                children: services.map((s) {
                                  return ListTile(
                                    title: Text(
                                      s.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    subtitle: Text(
                                      "\$${s.price} - ${s.duration}min",
                                      style: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.redAccent,
                                      ),
                                      onPressed: () async {
                                        await _servService.deleteService(s.id);
                                      },
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
