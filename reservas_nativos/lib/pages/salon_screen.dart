import 'package:flutter/material.dart';
import 'package:reservas_nativos/models/profecionales_models.dart';
import 'package:reservas_nativos/models/service_model.dart';
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

  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController priceCtrl = TextEditingController();
  final TextEditingController durCtrl = TextEditingController();

  String? selectedProId;

  @override
  void dispose() {
    nameCtrl.dispose();
    priceCtrl.dispose();
    durCtrl.dispose();
    super.dispose();
  }

  // ✅ Diálogo para añadir nuevo servicio
  void _showAddServiceDialog() {
    showDialog(
      context: context,
      builder: (ctx2) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text("Agregar nuevo servicio"),
          content: SingleChildScrollView(
            child: Column(
              children: [
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
                  stream: _profService.getProfessionals(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }

                    final professionals = snapshot.data!;
                    if (professionals.isEmpty) {
                      return const Text("No hay profesionales registrados.");
                    }

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
                      onChanged: (val) => setState(() => selectedProId = val),
                    );
                  },
                ),
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
                if (nameCtrl.text.isEmpty) return;

                await _servService.addService(
                  SalonService(
                    id: '',
                    name: nameCtrl.text.trim(),
                    price: double.tryParse(priceCtrl.text) ?? 0,
                    duration: int.tryParse(durCtrl.text) ?? 0,
                    professionalId: selectedProId ?? '',
                    companyId: '', // ✅ Se asigna automáticamente en el servicio
                  ),
                );

                nameCtrl.clear();
                priceCtrl.clear();
                durCtrl.clear();
                selectedProId = null;

                if (mounted) Navigator.pop(ctx2);
              },
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );
  }

  // ✅ Diálogo para agregar un profesional
  void _showAddProfessionalDialog() {
    final TextEditingController nameProCtrl = TextEditingController();
    final TextEditingController roleProCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text("Agregar profesional"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameProCtrl,
                decoration: const InputDecoration(labelText: "Nombre"),
              ),
              TextField(
                controller: roleProCtrl,
                decoration: const InputDecoration(labelText: "Rol"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameProCtrl.text.isEmpty || roleProCtrl.text.isEmpty)
                  return;

                final professional = Professional(
                  id: '',
                  name: nameProCtrl.text.trim(),
                  email:
                      '', // Por ahora vacío, puedes agregar un campo si luego lo pides al usuario
                  phone: '', // También vacío si no lo pides aún
                  role: roleProCtrl.text.trim(),
                  services: [], // Ningún servicio asignado al crear
                  companyId:
                      '', // Se asigna automáticamente en el servicio// Se asigna dentro del servicio
                );

                await _profService.addProfessional(professional);
                if (mounted) Navigator.pop(ctx);
              },
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color _dark = Colors.grey.shade900;

    return Scaffold(
      backgroundColor: _dark,
      appBar: AppBar(
        backgroundColor: _dark,
        title: const Text("Panel del Salón"),
        actions: [
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
      body: StreamBuilder<List<Professional>>(
        stream: _profService.getProfessionals(),
        builder: (context, snapshotPro) {
          if (!snapshotPro.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final professionals = snapshotPro.data!;
          if (professionals.isEmpty) {
            return const Center(child: Text("No hay profesionales aún."));
          }

          return ListView.builder(
            itemCount: professionals.length,
            itemBuilder: (context, index) {
              final pro = professionals[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                      stream: _servService.getServicesByProfessional(pro.id),
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
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                "\$${s.price} - ${s.duration}min",
                                style: const TextStyle(color: Colors.white70),
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
    );
  }
}
