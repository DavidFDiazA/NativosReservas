import 'package:flutter/material.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FA),
      appBar: AppBar(
        title: const Text(
          "Planes de Suscripción",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Text(
              "Elige el plan perfecto para tu negocio",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3A2C72),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Potencia tus reservas, clientes y gestión interna con la mejor herramienta.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, fontSize: 15),
            ),
            const SizedBox(height: 28),

            // START PLAN
            _buildPlanCard(
              context,
              title: "Start",
              price: "60.000 COP / mes",
              description: "Ideal para emprendedores",
              features: [
                "Hasta 80 reservas al mes",
                "Panel de control básico",
                "Soporte por correo",
                "1 usuario administrador",
              ],
              gradient: const LinearGradient(
                colors: [Color(0xFFEDEAF6), Color(0xFFDAD3F5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              buttonColor: const Color(0xFF3A2C72),
            ),
            const SizedBox(height: 24),

            // GROWTH PLAN (nuevo diseño elegante)
            _buildPlanCard(
              context,
              title: "Growth",
              price: "99.000 COP / mes",
              description: "Impulsa tu negocio con un estilo profesional 🚀",
              features: [
                "Reservas ilimitadas",
                "Gestión avanzada de clientes y servicios",
                "Panel con analíticas en tiempo real",
                "Soporte prioritario 24/7",
                "Hasta 5 usuarios colaboradores",
              ],
              highlight: true,
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF312E81),
                  Color(0xFF8B5CF6),
                ], // azul-violeta elegante
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              buttonColor: Colors.white,
            ),
            const SizedBox(height: 24),

            // PRO PLAN
            _buildPlanCard(
              context,
              title: "Pro",
              price: "199.000 COP / mes",
              description: "Para líderes del sector ✨",
              features: [
                "Reservas ilimitadas + analíticas premium",
                "Asesoría personalizada 1:1",
                "Soporte VIP 24/7",
                "Dominio y branding propio",
                "Usuarios ilimitados",
              ],
              gradient: const LinearGradient(
                colors: [Colors.black87, Colors.black],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              dark: true,
              buttonColor: Colors.amber,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context, {
    required String title,
    required String price,
    required String description,
    required List<String> features,
    required LinearGradient gradient,
    required Color buttonColor,
    bool highlight = false,
    bool dark = false,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        border: highlight
            ? Border.all(color: Colors.amber.shade300, width: 2.5)
            : null,
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (highlight)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: const Text(
                "Más popular",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 13.5,
                ),
              ),
            ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: dark
                  ? Colors.white
                  : highlight
                  ? Colors.white
                  : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 15,
              color: dark
                  ? Colors.white70
                  : highlight
                  ? Colors.white70
                  : Colors.black54,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            price,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: dark
                  ? Colors.amber.shade300
                  : highlight
                  ? Colors.white
                  : const Color(0xFF3A2C72),
            ),
          ),
          const SizedBox(height: 20),
          Column(
            children: features
                .map(
                  (f) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: dark
                              ? Colors.amber.shade400
                              : highlight
                              ? Colors.white
                              : Colors.green.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            f,
                            style: TextStyle(
                              color: dark
                                  ? Colors.white.withOpacity(0.9)
                                  : highlight
                                  ? Colors.white.withOpacity(0.9)
                                  : Colors.black87,
                              fontSize: 14.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      "Integración de pagos próximamente 💳",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: Colors.black87,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: highlight
                    ? Colors.white
                    : dark
                    ? buttonColor
                    : buttonColor,
                foregroundColor: highlight
                    ? Colors.black
                    : dark
                    ? Colors.black
                    : Colors.white,
                shadowColor: highlight
                    ? Colors.black.withOpacity(0.3)
                    : Colors.transparent,
                elevation: highlight ? 6 : 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                minimumSize: const Size(double.infinity, 55),
              ),
              child: const Text(
                "Suscribirme ahora",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
