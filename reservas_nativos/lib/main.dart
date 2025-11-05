import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:reservas_nativos/firebase_options.dart';
import 'package:reservas_nativos/pages/agenda_screen.dart';
import 'package:reservas_nativos/pages/auth.dart';
import 'package:reservas_nativos/pages/home.dart';

import 'package:reservas_nativos/pages/salon_screen.dart';
//import 'package:reservas_nativos/pages/bookin_page.dart';
//import 'package:reservas_nativos/pages/favorite_page.dart';
//mport 'package:reservas_nativos/pages/home.dart';

import 'package:reservas_nativos/pages/suscription_page.dart';

//import 'package:reservas_nativos/pages/Pages_owner/combos_page.dart';..import 'package:reservas_nativos/pages/Pages_owner/professionals_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase correctamente para móvil y web
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "BeautyBook",
      theme: ThemeData(primarySwatch: Colors.pink),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthPage(),
        '/home': (context) => const OwnerHomePage(),
        '/suscription': (context) => const SubscriptionScreen(),
        '/agenda': (context) => const AgendaScreen(),
        '/salon': (context) => const SalonScreen(),

        // 🔹 Dueño de negocio
      },
    );
  }
}
