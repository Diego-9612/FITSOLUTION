# 🧠 FitSolution

**FitSolution** es una aplicación móvil desarrollada con **Flutter** que integra **Inteligencia Artificial (IA)** para crear rutinas de entrenamiento personalizadas según los objetivos físicos del usuario, como **bajar de peso, ganar masa muscular o mantener la forma física**.  

La app utiliza tus datos básicos —como peso, estatura, nivel de actividad y meta— para generar automáticamente un plan de entrenamiento adaptado a tu perfil y evolución.

---

## 🚀 Características principales

- 🧬 **Rutinas generadas con IA:** Crea planes personalizados según tus objetivos (bajar o subir de peso, tonificar, etc.).
- 📊 **Seguimiento de progreso:** Permite monitorear métricas corporales y avances en el tiempo.
- 💬 **Asistente inteligente:** Ofrece recomendaciones sobre ejercicios, descanso y alimentación.
- 🎯 **Interfaz intuitiva:** Diseñada para ofrecer una experiencia fluida y atractiva.
- 🔒 **Datos locales y seguros:** La información del usuario se maneja de forma privada y segura.

---

## 🛠️ Tecnologías utilizadas

- **Flutter** — Framework principal de desarrollo móvil.
- **Dart** — Lenguaje base del proyecto.
- **IA/ML** — Integración con modelo inteligente para generación de rutinas.
- **Groq API** *(o similar)* — Motor de procesamiento de lenguaje natural y recomendaciones.
- **Clean Architecture + BLoC** — Patrón de arquitectura modular para escalabilidad y mantenibilidad.

---

## 📁 Estructura del proyecto

```bash
fitsolution/
├── lib/
│   ├── main.dart              # Punto de entrada principal
│   ├── ui/                    # Pantallas y componentes visuales
│   ├── core/                  # Configuraciones base y utilidades
│   ├── data/                  # Modelos y fuentes de datos
│   ├── bloc/                  # Controladores de estado (BLoC)
│   └── env.dart               # Variables de entorno (sin claves sensibles)
└── pubspec.yaml               # Dependencias y configuración del proyecto

