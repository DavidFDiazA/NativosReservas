import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
// Importaciones de Modelos y Servicios
import 'package:reservas_nativos/models/branch_model.dart';
import 'package:reservas_nativos/models/profecionales_models.dart';
import 'package:reservas_nativos/models/service_model.dart';
import 'package:reservas_nativos/services/branch_service.dart';
import 'package:reservas_nativos/services/profecinal_service.dart';
import 'package:reservas_nativos/services/salon_services.dart';
import '../models/appointment_model.dart';
import '../services/appointments_service.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({Key? key}) : super(key: key);

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  // ----------------------------------------------------
  // SERVICIOS
  // ----------------------------------------------------
  final AppointmentsService _appointmentsService = AppointmentsService();
  final BranchesService _branchService = BranchesService();
  final SalonServicesService _servService = SalonServicesService();
  final ProfessionalsService _profService = ProfessionalsService();

  // ----------------------------------------------------
  // CONSTANTES DE COLOR
  // ----------------------------------------------------
  static const Color _PRIMARY_DARK = Color(0xFF334257);
  static const Color _ACCENT_COLOR = Color(0xFF548CA8);
  static const Color _CARD_BACKGROUND = Color(0xFF476072);
  static const Color _APPBAR_BACKGROUND = Color(0xFFEEEEEE);
  static const Color _MAIN_BACKGROUND = Colors.white;
  static const Color _TEXT_COLOR_LIGHT = Colors.white;
  static const Color _TEXT_COLOR_DARK = Color(0xFF334257);
  // ----------------------------------------------------

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Stream<List<Appointment>> get _selectedAppointmentsStream {
    final day = _selectedDay ?? _focusedDay;
    return _appointmentsService.getAppointmentsForDay(day);
  }

  void _updateAppointmentStatus(String appointmentId, String status) async {
    try {
      await _appointmentsService.updateStatus(appointmentId, status);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar estado: $e')),
        );
      }
    }
  }

  // FUNCIÓN: Muestra TimePicker en formato 24h
  Future<TimeOfDay?> _selectTime(BuildContext context) async {
    return await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
  }

  // FUNCIÓN: Diálogo para agregar nueva cita (LÓGICA PRINCIPAL CORREGIDA)
  void _addAppointment(BuildContext context) async {
    final TextEditingController clientNameCtrl = TextEditingController();
    TimeOfDay? selectedTime;

    // Variables de estado del formulario dentro del diálogo
    String? selectedBranchId;
    // Ahora guardamos el OBJETO Professional
    Professional? selectedProfessional;

    String? selectedServiceId;
    int serviceDuration = 0;
    String serviceName = '';

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateInDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: _MAIN_BACKGROUND,
              title: Text(
                'Agregar cita manual',
                style: TextStyle(
                  color: _ACCENT_COLOR,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 1. Nombre del Cliente
                    TextField(
                      controller: clientNameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del Cliente',
                        border: OutlineInputBorder(),
                      ),
                      style: TextStyle(color: _TEXT_COLOR_DARK),
                    ),
                    const SizedBox(height: 15),

                    // 2. Selección de Sede
                    StreamBuilder<List<Branch>>(
                      stream: _branchService.getBranches(),
                      builder: (context, snapshot) {
                        final branches = snapshot.data ?? [];
                        if (snapshot.connectionState == ConnectionState.waiting)
                          return const LinearProgressIndicator();

                        return DropdownButtonFormField<String>(
                          value: selectedBranchId,
                          decoration: const InputDecoration(labelText: 'Sede'),
                          items: branches
                              .map(
                                (branch) => DropdownMenuItem(
                                  value: branch.id,
                                  child: Text(branch.name),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            setStateInDialog(() {
                              selectedBranchId = val;
                              // Resetea dependencias
                              selectedProfessional = null;
                              selectedServiceId = null;
                              serviceDuration = 0;
                            });
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 15),

                    // 3. Selección de Profesional (Depende de la Sede)
                    if (selectedBranchId != null)
                      StreamBuilder<List<Professional>>(
                        stream: _profService.getProfessionals(
                          branchId: selectedBranchId!,
                        ),
                        builder: (context, snapshot) {
                          final professionals = snapshot.data ?? [];
                          if (snapshot.connectionState ==
                              ConnectionState.waiting)
                            return const LinearProgressIndicator();

                          if (professionals.isEmpty) {
                            return const Text(
                              "No hay profesionales disponibles en esta sede.",
                              style: TextStyle(color: Colors.red),
                            );
                          }

                          return DropdownButtonFormField<Professional>(
                            value: selectedProfessional,
                            decoration: const InputDecoration(
                              labelText: 'Profesional',
                            ),
                            items: professionals
                                .map(
                                  (pro) => DropdownMenuItem(
                                    value: pro,
                                    child: Text(pro.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) {
                              setStateInDialog(() {
                                selectedProfessional = val;
                                // Resetea el Servicio al cambiar el Profesional
                                selectedServiceId = null;
                                serviceDuration = 0;
                                serviceName = '';
                              });
                            },
                          );
                        },
                      ),
                    const SizedBox(height: 15),

                    // 4. Selección de Servicio (Depende del Profesional seleccionado)
                    if (selectedProfessional != null)
                      StreamBuilder<List<SalonService>>(
                        // ⬅️ CORRECCIÓN: Filtra servicios por el ID del Profesional
                        stream: _servService.getServicesByProfessional(
                          selectedProfessional!.id,
                        ),
                        builder: (context, snapshot) {
                          final services = snapshot.data ?? [];
                          if (snapshot.connectionState ==
                              ConnectionState.waiting)
                            return const LinearProgressIndicator();

                          if (services.isEmpty) {
                            return const Text(
                              "El profesional no tiene servicios asignados.",
                              style: TextStyle(color: Colors.red),
                            );
                          }
                          return DropdownButtonFormField<String>(
                            value: selectedServiceId,
                            decoration: const InputDecoration(
                              labelText: 'Servicio',
                            ),
                            items: services
                                .map(
                                  (service) => DropdownMenuItem(
                                    value: service.id,
                                    child: Text(
                                      '${service.name} (${service.duration} min)',
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) {
                              final selected = services.firstWhere(
                                (s) => s.id == val,
                              );
                              setStateInDialog(() {
                                selectedServiceId = val;
                                serviceDuration = selected.duration;
                                serviceName = selected.name;
                              });
                            },
                          );
                        },
                      ),
                    const SizedBox(height: 15),

                    // 5. Selector de Hora (24h)
                    InkWell(
                      onTap: () async {
                        final TimeOfDay? time = await _selectTime(context);
                        setStateInDialog(() {
                          selectedTime = time;
                        });
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Hora de la Cita (24h)',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          selectedTime == null
                              ? 'Seleccionar hora'
                              : selectedTime!.format(context),
                          style: TextStyle(color: _TEXT_COLOR_DARK),
                        ),
                      ),
                    ),

                    // 6. Muestra la duración
                    if (serviceDuration > 0 && selectedTime != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Duración: ${serviceDuration} min. Fin: ${selectedTime!.replacing(minute: selectedTime!.minute + serviceDuration).format(context)}',
                          style: TextStyle(
                            color: _ACCENT_COLOR,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _ACCENT_COLOR,
                    foregroundColor: _TEXT_COLOR_LIGHT,
                  ),
                  onPressed:
                      selectedTime != null &&
                          clientNameCtrl.text.isNotEmpty &&
                          selectedBranchId != null &&
                          selectedServiceId != null &&
                          selectedProfessional != null
                      ? () async {
                          final selectedDate = _selectedDay ?? _focusedDay;
                          final appointmentDateTime = DateTime(
                            selectedDate.year,
                            selectedDate.month,
                            selectedDate.day,
                            selectedTime!.hour,
                            selectedTime!.minute,
                          );

                          final newAppointment = Appointment(
                            id: '',
                            clientName: clientNameCtrl.text,
                            branchId: selectedBranchId!,
                            serviceId: selectedServiceId!,
                            professionalId: selectedProfessional!
                                .id, // Usar el ID del objeto
                            service: serviceName,
                            date: appointmentDateTime,
                            status: 'pending',
                          );

                          await _appointmentsService.addAppointment(
                            newAppointment,
                          );

                          if (mounted) Navigator.pop(ctx);
                        }
                      : null,
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('hh:mm a');

    return Scaffold(
      backgroundColor: _MAIN_BACKGROUND, // Blanco
      appBar: AppBar(
        backgroundColor: _APPBAR_BACKGROUND, // Gris Claro
        elevation: 1,
        iconTheme: IconThemeData(color: _PRIMARY_DARK),
        title: Text(
          'Agenda',
          style: TextStyle(fontWeight: FontWeight.bold, color: _PRIMARY_DARK),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: _MAIN_BACKGROUND,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TableCalendar(
              focusedDay: _focusedDay,
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: _ACCENT_COLOR, // Azul Acento
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: _CARD_BACKGROUND.withOpacity(
                    0.8,
                  ), // Azul Acero más suave
                  shape: BoxShape.circle,
                ),
                weekendTextStyle: TextStyle(color: _PRIMARY_DARK),
                defaultTextStyle: TextStyle(color: _PRIMARY_DARK),
                outsideTextStyle: TextStyle(color: Colors.grey.shade400),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: _PRIMARY_DARK,
                ),
                leftChevronIcon: Icon(Icons.chevron_left, color: _PRIMARY_DARK),
                rightChevronIcon: Icon(
                  Icons.chevron_right,
                  color: _PRIMARY_DARK,
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Appointment>>(
              stream: _selectedAppointmentsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error al cargar citas: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                final appointments = snapshot.data ?? [];

                if (appointments.isEmpty) {
                  return Center(
                    child: Text(
                      'No hay citas para ${DateFormat('dd MMMM yyyy').format(_selectedDay!)}',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  );
                }

                appointments.sort((a, b) => a.date.compareTo(b.date));

                return ListView.builder(
                  itemCount: appointments.length,
                  itemBuilder: (context, index) {
                    final appointment = appointments[index];
                    final status = appointment.status;

                    Color statusColor;
                    IconData icon;
                    String statusText;

                    if (status == 'confirmed') {
                      statusColor = Colors.green.shade600;
                      icon = Icons.check_circle;
                      statusText = 'Confirmada';
                    } else if (status == 'cancelled') {
                      statusColor = Colors.red.shade600;
                      icon = Icons.cancel;
                      statusText = 'Cancelada';
                    } else {
                      // pending
                      statusColor =
                          Colors.orange.shade400; // Naranja para pendiente
                      icon = Icons.schedule;
                      statusText = 'Pendiente';
                    }

                    return Card(
                      color: _CARD_BACKGROUND, // Azul Acero
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      child: ListTile(
                        leading: Icon(icon, color: statusColor, size: 32),
                        title: Text(
                          appointment.clientName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: _TEXT_COLOR_LIGHT, // Texto Blanco
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${timeFormat.format(appointment.date)} - ${appointment.service}',
                              style: TextStyle(
                                fontSize: 14,
                                color: _APPBAR_BACKGROUND,
                              ), // Gris claro
                            ),
                            Text(
                              'Estado: $statusText',
                              style: TextStyle(
                                fontSize: 12,
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_vert,
                            color: _TEXT_COLOR_LIGHT,
                          ), // Icono blanco
                          onSelected: (value) => _updateAppointmentStatus(
                            appointment.id,
                            value,
                          ), // Llama al servicio
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'confirmed',
                              child: Text(
                                'Confirmar',
                                style: TextStyle(color: Colors.green),
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'cancelled',
                              child: Text(
                                'Declinar/Cancelar',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'pending',
                              child: Text(
                                'Marcar como Pendiente',
                                style: TextStyle(color: Colors.orange),
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
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _ACCENT_COLOR, // Azul Acento
        onPressed: () => _addAppointment(context),
        child: const Icon(Icons.add, size: 28, color: _TEXT_COLOR_LIGHT),
      ),
    );
  }
}
