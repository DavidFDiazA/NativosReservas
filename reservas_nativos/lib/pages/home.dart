import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';

class OwnerHomePage extends StatefulWidget {
  const OwnerHomePage({super.key});

  @override
  State<OwnerHomePage> createState() => _OwnerHomePageState();
}

class _OwnerHomePageState extends State<OwnerHomePage> {
  final user = FirebaseAuth.instance.currentUser;
  String fullName = '';
  String phone = '';

  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  List<Map<String, dynamic>> _appointments = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadAppointmentsForDay(_selectedDay);
  }

  Future<void> _loadUserData() async {
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      if (doc.exists) {
        setState(() {
          fullName = doc['fullName'] ?? '';
          phone = doc['phone'] ?? '';
        });
      }
    }
  }

  Future<void> _loadAppointmentsForDay(DateTime day) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('appointments')
        .where('ownerId', isEqualTo: user!.uid)
        .where(
          'date',
          isEqualTo: DateTime(day.year, day.month, day.day).toIso8601String(),
        ) // formato fecha
        .get();

    setState(() {
      _appointments = snapshot.docs.map((d) => d.data()).toList();
    });
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
    _loadAppointmentsForDay(selectedDay);
  }

  void _showProfileDialog() {
    final nameController = TextEditingController(text: fullName);
    final phoneController = TextEditingController(text: phone);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFEEEEEE),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Mi Perfil",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF222831),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Nombre completo",
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Teléfono",
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0092CA),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(Icons.save, color: Colors.white),
            label: const Text("Guardar"),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(user!.uid)
                  .update({
                    'fullName': nameController.text.trim(),
                    'phone': phoneController.text.trim(),
                  });

              setState(() {
                fullName = nameController.text.trim();
                phone = phoneController.text.trim();
              });

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Perfil actualizado exitosamente ✅"),
                  backgroundColor: Color(0xFF0092CA),
                ),
              );
            },
          ),
          TextButton(
            onPressed: _logout,
            child: const Text(
              "Cerrar sesión",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      appBar: AppBar(
        backgroundColor: const Color(0xFF222831),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Panel de Control',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: _showProfileDialog,
            icon: const Icon(
              Icons.account_circle_outlined,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bienvenido 👋',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF222831),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                fullName.isEmpty
                    ? 'Administra tu salón y tus reservas fácilmente'
                    : '$fullName, administra tu salón y tus reservas fácilmente',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 25),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSummaryCard(
                    title: 'Reservas',
                    value: '0',
                    icon: Icons.calendar_today_rounded,
                    color: const Color(0xFF0092CA),
                  ),
                  _buildSummaryCard(
                    title: 'Clientes',
                    value: '0',
                    icon: Icons.people_alt_rounded,
                    color: const Color(0xFF0092CA),
                  ),
                  _buildSummaryCard(
                    title: 'Ingresos',
                    value: '\$0',
                    icon: Icons.attach_money_rounded,
                    color: const Color(0xFF0092CA),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              Text(
                'Calendario de hoy',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF222831),
                ),
              ),
              const SizedBox(height: 10),

              TableCalendar(
                firstDay: DateTime.utc(2023, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: _onDaySelected,
                calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Color(0xFF0092CA),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Color(0xFF222831),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              Text(
                'Citas del día',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              if (_appointments.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      'No tienes citas programadas para hoy 😌',
                      style: GoogleFonts.poppins(color: Colors.grey[600]),
                    ),
                  ),
                )
              else
                ..._appointments.map(
                  (a) => Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: const Icon(
                        Icons.schedule_rounded,
                        color: Color(0xFF0092CA),
                      ),
                      title: Text(a['clientName'] ?? 'Cliente'),
                      subtitle: Text(a['time'] ?? 'Hora no definida'),
                    ),
                  ),
                ),

              const SizedBox(height: 30),

              Text(
                'Gestión rápida',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF222831),
                ),
              ),
              const SizedBox(height: 15),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildMenuCard(
                    context,
                    'Mi Salón',
                    Icons.store_rounded,
                    () => Navigator.pushNamed(context, '/salon'),
                  ),
                  _buildMenuCard(
                    context,
                    'Agenda',
                    Icons.calendar_month_rounded,
                    () => Navigator.pushNamed(context, '/agenda'),
                  ),
                  _buildMenuCard(
                    context,
                    'Suscripción',
                    Icons.workspace_premium_rounded,
                    () => Navigator.pushNamed(context, '/suscription'),
                  ),
                  _buildMenuCard(
                    context,
                    'Configuración',
                    Icons.settings_rounded,
                    () => Navigator.pushNamed(context, '/salonConfig'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF393E46),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF0092CA), size: 38),
            const SizedBox(height: 10),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
