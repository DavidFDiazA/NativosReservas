# 💇‍♀️ Reservas Nativos — Sistema de gestión de salones

**Reservas Nativos** es una aplicación desarrollada en **Flutter + Firebase**, diseñada para ayudar a salones de belleza y barberías a gestionar fácilmente sus sedes, profesionales, servicios y reservas, desde una interfaz moderna, intuitiva y optimizada para dispositivos móviles.

---

## ✨ Características principales

✅ **Gestión multi-sede** — Cada usuario puede registrar una o más sedes (salones).
✅ **Control de profesionales** — Asocia estilistas, barberos y especialistas a cada sede.
✅ **Catálogo de servicios** — Define tus servicios (corte, color, manicure, etc.) con precios y duración.
✅ **Autenticación con Firebase Auth** — Control total de acceso y seguridad.
✅ **Sincronización en tiempo real** — Todos los cambios se actualizan automáticamente con Firestore.
✅ **Diseño adaptable y elegante** — Inspirado en el estilo premium de Nativos.

---

## 🧭 Flujo general del usuario

1. **Inicio de sesión / registro** (Firebase Authentication)
2. Si el usuario **no tiene sedes**, aparece el formulario para crear su primera:
   - Nombre del salón
   - Dirección
   - Teléfono
3. Al guardar, la sede se almacena en **Cloud Firestore**.
4. Luego el usuario accede a la **pantalla de configuración del salón**, donde puede:
   - Ver y gestionar **profesionales**
   - Agregar o editar **servicios**
   - Alternar entre sedes creadas

---

## 🧱 Estructura de carpetas

```bash
lib/
├── models/
│   ├── branch_model.dart          # Modelo de sede
│   ├── profecionales_models.dart  # Modelo de profesional
│   └── service_model.dart         # Modelo de servicio
│
├── services/
│   ├── branch_service.dart        # CRUD de sedes
│   ├── profecinal_service.dart    # CRUD de profesionales
│   └── salon_services.dart        # CRUD de servicios
│
├── screens/
│   ├── salon_first_screen.dart         # Pantalla para crear la primera sede
│   ├── salon_configuration_screen.dart # Configuración general del salón
│   └── salon_entry_screen.dart         # Controla flujo inicial
│
└── main.dart
