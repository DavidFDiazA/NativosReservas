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

  // Controladores de texto para formularios
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController priceCtrl = TextEditingController();
  final TextEditingController durCtrl = TextEditingController();

  // Variables para crear una NUEVA sede
  final TextEditingController branchNameCtrl = TextEditingController();
  final TextEditingController branchAddressCtrl = TextEditingController();
  final TextEditingController branchPhoneCtrl = TextEditingController();

  // Controladores de estado para diálogos y filtro
  String? selectedProId;
  String? _selectedFilterBranchId; // Filtro por Sede
  String? _selectedProfessionalId; // Filtro por Profesional

  // ----------------------------------------------------
  // PALETA DE COLORES FINAL (Basada en la imagen adjunta)
  // ----------------------------------------------------
  static const Color _PRIMARY_DARK = Color(
    0xFF334257,
  ); // Azul muy oscuro (Texto en fondos claros)
  static const Color _ACCENT_COLOR = Color(
    0xFF548CA8,
  ); // Azul Claro (Acento/Interacciones)
  static const Color _CARD_BACKGROUND = Color(
    0xFF476072,
  ); // Azul Acero (Fondo de Tarjeta/Círculo)
  static const Color _APPBAR_BACKGROUND = Color(
    0xFFEEEEEE,
  ); // Gris Claro para AppBar
  static const Color _MAIN_BACKGROUND =
      Colors.white; // Fondo de Scaffold (Blanco)
  static const Color _TEXT_COLOR_LIGHT =
      Colors.white; // Texto en fondos oscuros
  static const Color _TEXT_COLOR_DARK = Color(
    0xFF334257,
  ); // Texto en fondos claros
  // ----------------------------------------------------

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
  // HELPER: DIÁLOGO TEMATIZADO
  // ----------------------------------------------------
  Widget _buildThemedDialog({
    required String title,
    required Widget content,
    required List<Widget> actions,
  }) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Text(
        title,
        style: TextStyle(color: _ACCENT_COLOR),
      ), // Título en color Acento
      content: content,
      actions: actions,
      backgroundColor: _MAIN_BACKGROUND, // Fondo de diálogo Blanco
    );
  }

  // ----------------------------------------------------
  // DIÁLOGO PARA CREAR SEDE
  // ----------------------------------------------------
  void _showAddBranchDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return _buildThemedDialog(
          title: "Crear Nueva Sede",
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: branchNameCtrl,
                  decoration: const InputDecoration(
                    labelText: "Nombre de la Sede",
                  ),
                  style: TextStyle(color: _TEXT_COLOR_DARK),
                ),
                TextField(
                  controller: branchAddressCtrl,
                  decoration: const InputDecoration(labelText: "Dirección"),
                  style: TextStyle(color: _TEXT_COLOR_DARK),
                ),
                TextField(
                  controller: branchPhoneCtrl,
                  decoration: const InputDecoration(labelText: "Teléfono"),
                  keyboardType: TextInputType.phone,
                  style: TextStyle(color: _TEXT_COLOR_DARK),
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
              child: const Text(
                "Cancelar",
                style: TextStyle(color: Colors.grey),
              ),
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
                  ownerId: '',
                );

                final savedBranchId = await _branchService.addBranch(newBranch);

                branchNameCtrl.clear();
                branchAddressCtrl.clear();
                branchPhoneCtrl.clear();

                if (mounted) Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _ACCENT_COLOR,
              ), // ⬅️ Color Acento
              child: const Text(
                "Guardar Sede",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // ----------------------------------------------------
  // Helper para el Dropdown de Sedes (en diálogos)
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
          decoration: InputDecoration(
            labelText: "Seleccionar Sede",
            labelStyle: TextStyle(color: Colors.grey.shade700),
          ),
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
            return _buildThemedDialog(
              // Usando el helper de tema
              title: "Agregar Nuevo Servicio",
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildBranchDropdown(
                      initialValue: dialogSelectedBranchId,
                      onChanged: (val) =>
                          setStateInDialog(() => dialogSelectedBranchId = val),
                    ),
                    const SizedBox(height: 10),
                    if (dialogSelectedBranchId != null) ...[
                      TextField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(labelText: "Nombre"),
                        style: TextStyle(color: _TEXT_COLOR_DARK),
                      ),
                      TextField(
                        controller: priceCtrl,
                        decoration: const InputDecoration(labelText: "Precio"),
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: _TEXT_COLOR_DARK),
                      ),
                      TextField(
                        controller: durCtrl,
                        decoration: const InputDecoration(
                          labelText: "Duración (minutos)",
                        ),
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: _TEXT_COLOR_DARK),
                      ),
                      const SizedBox(height: 10),
                      StreamBuilder<List<Professional>>(
                        stream: _profService.getProfessionals(
                          branchId: dialogSelectedBranchId,
                        ),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Text(
                              "No hay profesionales disponibles en esta sede.",
                              style: TextStyle(color: Colors.redAccent),
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
                  child: const Text(
                    "Cancelar",
                    style: TextStyle(color: Colors.grey),
                  ), // ⬅️ Color gris
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

                    if (mounted) {
                      setState(() {
                        _selectedFilterBranchId = dialogSelectedBranchId;
                      });
                    }

                    if (mounted) Navigator.pop(ctx2);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _ACCENT_COLOR,
                  ), // ⬅️ Color Acento
                  child: const Text(
                    "Guardar",
                    style: TextStyle(color: Colors.white),
                  ),
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
            return _buildThemedDialog(
              // Usando el helper de tema
              title: "Agregar Nuevo Profesional",
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildBranchDropdown(
                    initialValue: dialogSelectedBranchId,
                    onChanged: (val) =>
                        setStateInDialog(() => dialogSelectedBranchId = val),
                  ),
                  const SizedBox(height: 10),
                  if (dialogSelectedBranchId != null) ...[
                    TextField(
                      controller: nameProCtrl,
                      decoration: const InputDecoration(labelText: "Nombre"),
                      style: TextStyle(color: _TEXT_COLOR_DARK),
                    ),
                    TextField(
                      controller: roleProCtrl,
                      decoration: const InputDecoration(labelText: "Rol"),
                      style: TextStyle(color: _TEXT_COLOR_DARK),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    "Cancelar",
                    style: TextStyle(color: Colors.grey),
                  ), // ⬅️ Color gris
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

                    if (mounted) {
                      setState(() {
                        _selectedFilterBranchId = dialogSelectedBranchId;
                      });
                    }

                    if (mounted) Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _ACCENT_COLOR,
                  ), // ⬅️ Color Acento
                  child: const Text(
                    "Guardar",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ----------------------------------------------------
  // Selector de Sedes en Formato Horizontal (Chips)
  // ----------------------------------------------------
  Widget _buildBranchSelectionChips(List<Branch> branches, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 12.0, top: 4.0, bottom: 8.0),
          child: Text(
            "Selecciona la Sede Activa:",
            style: TextStyle(
              color: _PRIMARY_DARK,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          height: 50, // Altura fija para la fila de chips
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            itemCount: branches.length,
            itemBuilder: (context, index) {
              final branch = branches[index];
              final isSelected = branch.id == _selectedFilterBranchId;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: ChoiceChip(
                  label: Text(branch.name),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedFilterBranchId = branch.id;
                        // Reiniciar la selección de profesional al cambiar la sede
                        _selectedProfessionalId = null;
                      });
                    }
                  },
                  selectedColor: primaryColor, // ⬅️ Color Acento
                  backgroundColor: _APPBAR_BACKGROUND, // ⬅️ Fondo de Chip Gris
                  labelStyle: TextStyle(
                    color: isSelected ? _TEXT_COLOR_LIGHT : _TEXT_COLOR_DARK,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  elevation: isSelected ? 4 : 1,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ----------------------------------------------------
  // BUILD METHOD
  // ----------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final Color _primaryColor = _ACCENT_COLOR; // Color Azul (Acento)
    final Color _mainBackground = _MAIN_BACKGROUND; // Color Blanco
    final Color _appBarBackground = _APPBAR_BACKGROUND; // Color Gris Claro
    final Color _cardBackground =
        _CARD_BACKGROUND; // Color Azul Acero para tarjetas de lista

    return Scaffold(
      backgroundColor: _mainBackground, // ⬅️ Fondo Blanco
      appBar: AppBar(
        backgroundColor: _appBarBackground, // ⬅️ AppBar Gris Claro
        elevation: 1, // Sombra sutil para separar del contenido
        // Título en color de texto oscuro
        title: const Text(
          "Panel del Salón",
          style: TextStyle(color: _PRIMARY_DARK),
        ),
        actions: [
          // ⬅️ ÍCONOS en Color Acento (Azul)
          IconButton(
            icon: Icon(Icons.add_location_alt, color: _primaryColor),
            onPressed: _showAddBranchDialog,
            tooltip: 'Crear Sede',
          ),
          IconButton(
            icon: Icon(Icons.add_business, color: _primaryColor),
            onPressed: _showAddProfessionalDialog,
            tooltip: 'Crear Profesional',
          ),
          IconButton(
            icon: Icon(Icons.add, color: _primaryColor),
            onPressed: _showAddServiceDialog,
            tooltip: 'Crear Servicio',
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ⬅️ 1. Selector de Sedes (Chips Horizontales)
          StreamBuilder<List<Branch>>(
            stream: _branchService.getBranches(),
            builder: (context, snapshot) {
              final branches = snapshot.data ?? [];

              if (branches.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Center(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                      ),
                      icon: const Icon(
                        Icons.add_home_work,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "CREAR PRIMERA SEDE",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: _showAddBranchDialog,
                    ),
                  ),
                );
              }

              // Lógica de inicialización del filtro
              if (_selectedFilterBranchId == null ||
                  !branches.any((b) => b.id == _selectedFilterBranchId)) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  setState(() {
                    _selectedFilterBranchId = branches.first.id;
                    _selectedProfessionalId = null;
                  });
                });
              }

              if (_selectedFilterBranchId == null) {
                return const LinearProgressIndicator();
              }

              // 🟢 Usamos el nuevo widget de chips horizontales
              return _buildBranchSelectionChips(branches, _primaryColor);
            },
          ),

          // ⬅️ 2. Lista Horizontal de Profesionales (CIRCULOS)
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 12.0,
            ),
            child: Text(
              "Profesionales de la Sede:",
              style: TextStyle(
                color: _PRIMARY_DARK,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            height: 100, // Altura fija para la lista horizontal
            child: StreamBuilder<List<Professional>>(
              stream: _profService.getProfessionals(
                branchId: _selectedFilterBranchId,
              ),
              builder: (context, snapshotPro) {
                if (_selectedFilterBranchId == null || !snapshotPro.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final professionals = snapshotPro.data ?? [];

                // Auto-seleccionar el primer profesional si no hay uno seleccionado
                if (_selectedProfessionalId == null &&
                    professionals.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      _selectedProfessionalId = professionals.first.id;
                    });
                  });
                }

                if (professionals.isEmpty) {
                  return const Center(
                    child: Text(
                      "No hay profesionales para esta sede.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: professionals.length,
                  itemBuilder: (context, index) {
                    final pro = professionals[index];
                    final isSelected = pro.id == _selectedProfessionalId;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedProfessionalId = pro.id;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              // 🟢 CÍRCULO para Profesional
                              radius: 30,
                              backgroundColor: isSelected
                                  ? _primaryColor.withOpacity(0.9) // ⬅️ Acento
                                  : _APPBAR_BACKGROUND, // ⬅️ Gris
                              child: Text(
                                pro.name.isNotEmpty
                                    ? pro.name[0].toUpperCase()
                                    : '?',
                                style: TextStyle(
                                  color: isSelected
                                      ? _TEXT_COLOR_LIGHT
                                      : _TEXT_COLOR_DARK,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              pro.name
                                  .split(' ')
                                  .first, // Mostrar solo el primer nombre
                              style: TextStyle(
                                color: isSelected
                                    ? _TEXT_COLOR_DARK
                                    : Colors.grey,
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          const Padding(
            padding: EdgeInsets.only(top: 12.0, left: 12.0, bottom: 4.0),
            child: Text(
              "Servicios del Profesional:",
              style: TextStyle(
                color: _PRIMARY_DARK,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // ⬅️ 3. Lista Vertical de Servicios Filtrados (CUADRADOS/CARDS)
          Expanded(
            child: StreamBuilder<List<SalonService>>(
              // Filtrar servicios por el ID del profesional seleccionado
              stream: _selectedProfessionalId != null
                  ? _servService.getServicesByProfessional(
                      _selectedProfessionalId!,
                    )
                  : const Stream.empty(),
              builder: (context, snapshotServ) {
                if (_selectedProfessionalId == null) {
                  return const Center(
                    child: Text(
                      "Selecciona un profesional para ver sus servicios.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                if (!snapshotServ.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final services = snapshotServ.data ?? [];
                if (services.isEmpty) {
                  return Center(
                    child: Text(
                      "Este profesional no tiene servicios asignados.",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 0, bottom: 20),
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    final s = services[index];

                    // 🟢 CUADRADO/CARD para Servicios
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 6.0,
                      ),
                      child: Card(
                        color:
                            _cardBackground, // ⬅️ Color de fondo de tarjeta Azul Acero
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            10,
                          ), // Bordes suavizados (cuadrado)
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: _ACCENT_COLOR, // ⬅️ Color Acento
                              borderRadius: BorderRadius.circular(6),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.content_cut,
                              size: 22,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            s.name,
                            style: const TextStyle(
                              color: _TEXT_COLOR_LIGHT,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            "\$${s.price} - ${s.duration}min",
                            style: const TextStyle(
                              color: _APPBAR_BACKGROUND,
                            ), // Subtítulo en Gris Claro para contraste
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
                        ),
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
