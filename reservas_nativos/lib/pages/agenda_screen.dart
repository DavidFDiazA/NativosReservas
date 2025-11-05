import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({Key? key}) : super(key: key);

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Lista temporal de citas
  final Map<DateTime, List<Map<String, dynamic>>> _appointments = {};

  List<Map<String, dynamic>> get _selectedAppointments {
    return _appointments[_selectedDay] ?? [];
  }

  void _addAppointment(BuildContext context) async {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController hourController = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        title: const Text(
          'Agregar cita manual',
          style: TextStyle(
            color: Color(0xFF6C63FF),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: hourController,
              decoration: const InputDecoration(
                labelText: 'Hora (Ej: 10:00 AM)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
            ),
            onPressed: () {
              if (titleController.text.isNotEmpty &&
                  hourController.text.isNotEmpty &&
                  _selectedDay != null) {
                setState(() {
                  _appointments[_selectedDay!] ??= [];
                  _appointments[_selectedDay!]!.add({
                    'title': titleController.text,
                    'hour': hourController.text,
                    'status': 'pendiente',
                  });
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _toggleStatus(int index, String status) {
    setState(() {
      _selectedAppointments[index]['status'] = status;
    });
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      appBar: AppBar(
        backgroundColor: const Color(0xFF222831),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Agenda',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white,
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
              calendarStyle: const CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: Color(0xFF0092CA),
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Color(0xFF222831),
                  shape: BoxShape.circle,
                ),
                weekendTextStyle: TextStyle(color: Colors.redAccent),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: _selectedAppointments.isEmpty
                  ? const Center(
                      child: Text(
                        'No hay citas para este día',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _selectedAppointments.length,
                      itemBuilder: (context, index) {
                        final appointment = _selectedAppointments[index];
                        final status = appointment['status'];

                        Color statusColor;
                        IconData icon;

                        if (status == 'confirmada') {
                          statusColor = Colors.green;
                          icon = Icons.check_circle;
                        } else if (status == 'cancelada') {
                          statusColor = Colors.red;
                          icon = Icons.cancel;
                        } else {
                          statusColor = Colors.orange;
                          icon = Icons.schedule;
                        }

                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: Icon(icon, color: statusColor, size: 32),
                            title: Text(
                              appointment['title'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text(
                              appointment['hour'],
                              style: const TextStyle(fontSize: 14),
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) =>
                                  _toggleStatus(index, value),
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'confirmada',
                                  child: Text('Confirmar'),
                                ),
                                const PopupMenuItem(
                                  value: 'cancelada',
                                  child: Text('Cancelar'),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF0092CA),
        onPressed: () => _addAppointment(context),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}
