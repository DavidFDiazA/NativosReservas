import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reservas_nativos/services/auth_service.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AuthService _authService = AuthService();

  // Controladores
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  String? selectedEmployees;
  String? selectedBranches;

  bool isLoading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, "/home");
      });
    }
  }

  String _errorMessage(String code) {
    if (code.contains('user-not-found'))
      return "No existe una cuenta con este correo.";
    if (code.contains('wrong-password')) return "La contraseña es incorrecta.";
    if (code.contains('invalid-email'))
      return "El correo no tiene un formato válido.";
    if (code.contains('email-already-in-use'))
      return "Este correo ya está registrado.";
    if (code.contains('weak-password'))
      return "La contraseña es demasiado débil.";
    return "Ocurrió un error inesperado. ($code)";
  }

  void showSnack(String message, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color ?? Colors.black87,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // LOGIN
  Future<void> handleSignIn() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      showSnack("Por favor completa todos los campos");
      return;
    }

    setState(() => isLoading = true);
    try {
      await _authService.signIn(
        emailController.text.trim(),
        passwordController.text.trim(),
      );
      showSnack("Bienvenido 💇‍♂️", color: Colors.green);
      Navigator.pushReplacementNamed(context, "/home");
    } catch (e) {
      showSnack(_errorMessage(e.toString()), color: Colors.red);
    } finally {
      setState(() => isLoading = false);
    }
  }

  // REGISTRO SIMPLE
  Future<void> handleSignUp() async {
    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty ||
        nameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        selectedEmployees == null ||
        selectedBranches == null) {
      showSnack("Por favor completa todos los campos");
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      showSnack("Las contraseñas no coinciden");
      return;
    }

    setState(() => isLoading = true);
    try {
      final userCred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCred.user!.uid)
          .set({
            "fullName": nameController.text.trim(),
            "email": emailController.text.trim(),
            "phone": phoneController.text.trim(),
            "employees": selectedEmployees,
            "branches": selectedBranches,
            "roles": ["owner"],
            "createdAt": DateTime.now(),
            "updatedAt": DateTime.now(),
          });

      showSnack("Cuenta creada exitosamente 🎉", color: Colors.green);
      Navigator.pushReplacementNamed(context, "/home");
    } catch (e) {
      showSnack(_errorMessage(e.toString()), color: Colors.red);
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.business, size: 50, color: Colors.purple),
                const SizedBox(height: 10),
                const Text(
                  "BeautyBook Pro",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const Text("Gestión de tu negocio de belleza"),
                const SizedBox(height: 20),

                TabBar(
                  controller: _tabController,
                  labelColor: Colors.purple,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.purple,
                  tabs: const [
                    Tab(text: "Iniciar Sesión"),
                    Tab(text: "Registrarse"),
                  ],
                ),
                const SizedBox(height: 20),

                SizedBox(
                  height: 460,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // LOGIN
                      Column(
                        children: [
                          TextField(
                            controller: emailController,
                            decoration: const InputDecoration(
                              labelText: "Email",
                            ),
                          ),
                          TextField(
                            controller: passwordController,
                            obscureText: obscurePassword,
                            decoration: InputDecoration(
                              labelText: "Contraseña",
                              suffixIcon: IconButton(
                                icon: Icon(
                                  obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () => setState(
                                  () => obscurePassword = !obscurePassword,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: isLoading ? null : handleSignIn,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              minimumSize: const Size(double.infinity, 45),
                            ),
                            child: Text(
                              isLoading ? "Iniciando..." : "Iniciar Sesión",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),

                      // REGISTRO
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            TextField(
                              controller: nameController,
                              decoration: const InputDecoration(
                                labelText: "Nombre completo",
                              ),
                            ),
                            TextField(
                              controller: phoneController,
                              decoration: const InputDecoration(
                                labelText: "Teléfono",
                              ),
                            ),
                            TextField(
                              controller: emailController,
                              decoration: const InputDecoration(
                                labelText: "Email",
                              ),
                            ),

                            // Lista de empleados
                            DropdownButtonFormField<String>(
                              value: selectedEmployees,
                              decoration: const InputDecoration(
                                labelText: "Número de empleados",
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: "2-5",
                                  child: Text("2 a 5"),
                                ),
                                DropdownMenuItem(
                                  value: "5-8",
                                  child: Text("5 a 8"),
                                ),
                                DropdownMenuItem(
                                  value: "8-10",
                                  child: Text("8 a 10"),
                                ),
                                DropdownMenuItem(
                                  value: "10+",
                                  child: Text("Más de 10"),
                                ),
                              ],
                              onChanged: (val) =>
                                  setState(() => selectedEmployees = val),
                            ),

                            // Lista de sedes
                            DropdownButtonFormField<String>(
                              value: selectedBranches,
                              decoration: const InputDecoration(
                                labelText: "Número de sedes",
                              ),
                              items: const [
                                DropdownMenuItem(value: "1", child: Text("1")),
                                DropdownMenuItem(value: "2", child: Text("2")),
                                DropdownMenuItem(value: "3", child: Text("3")),
                                DropdownMenuItem(value: "4", child: Text("4")),
                                DropdownMenuItem(
                                  value: "4+",
                                  child: Text("Más de 4"),
                                ),
                              ],
                              onChanged: (val) =>
                                  setState(() => selectedBranches = val),
                            ),

                            TextField(
                              controller: passwordController,
                              obscureText: obscurePassword,
                              decoration: InputDecoration(
                                labelText: "Contraseña",
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () => setState(
                                    () => obscurePassword = !obscurePassword,
                                  ),
                                ),
                              ),
                            ),
                            TextField(
                              controller: confirmPasswordController,
                              obscureText: obscureConfirmPassword,
                              decoration: InputDecoration(
                                labelText: "Confirmar contraseña",
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    obscureConfirmPassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () => setState(
                                    () => obscureConfirmPassword =
                                        !obscureConfirmPassword,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: isLoading ? null : handleSignUp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                                minimumSize: const Size(double.infinity, 45),
                              ),
                              child: Text(
                                isLoading ? "Creando..." : "Crear Cuenta",
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
