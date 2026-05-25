# App-clasificacionn-de-plantas
# GreenHouse - Clasificacion de plantas

GreenHouse es una aplicacion movil hecha en Flutter que identifica plantas a partir de una imagen. La app puede reconocer:

- Aloe Vera
- Monstera Deliciosa
- Orquidea

La version final usa un modelo de TensorFlow Lite dentro de la app, asi que no necesita conectarse a un servidor para hacer la prediccion.

## Estructura del proyecto

```text
GreenHouse/
├── green_house/          # Aplicacion Flutter
│   ├── lib/              # Pantallas y logica principal
│   ├── assets/           # Imagenes y modelo local
│   └── pubspec.yaml      # Dependencias de Flutter
│
└── backend/backend/      # Backend Flask usado durante pruebas
    ├── predecir.py
    ├── requirements.txt
    └── modelos .keras / .tflite
```

## Requisitos

Para correr la aplicacion se necesita:

- Flutter instalado
- Un celular Android con depuracion USB activada o emulador


Para verificar que Flutter este listo:

```powershell
flutter doctor
```

Si falta algo, Flutter te va a indicar que componente instalar o configurar.

## Como ejecutar la app

Primero entra a la carpeta del frontend:

```powershell
cd green_house
```

Descarga las dependencias:

```powershell
flutter pub get
```

Conecta un celular o abre un emulador. Para ver los dispositivos disponibles:

Ejecuta la aplicacion:

```powershell
flutter run
```

La app se abrira en el dispositivo seleccionado.

## Como usar la app

1. Abre GreenHouse.
2. Presiona `Comenzar`.
3. Toma una foto o sube una imagen desde galeria.
4. Presiona `Continuar`.
5. La app analiza la imagen con el modelo local.
6. Si la precision es suficiente, muestra la planta detectada y sus cuidados.
7. Si la precision es baja, muestra que no se identifico la planta.

## Modelo de IA

El modelo se encuentra dentro de:

```text
green_house/assets/models/plant_classifier_mobilenetv2_v2.tflite
```

La imagen se prepara antes de enviarse al modelo:

- Se convierte a RGB.
- Se cambia a tamano 225 x 225 pixeles.
- Se normalizan los valores de color.
- TensorFlow Lite calcula la prediccion.

La app usa una precision minima de 75%. Si el resultado no llega a ese porcentaje, se muestra como no identificado.

## Generar APK

Para generar un APK de prueba:

```powershell
cd green_house
flutter build apk --debug
```

El APK queda en:

```text
green_house/build/app/outputs/flutter-apk/app-debug.apk
```

Ese archivo se puede pasar al celular para instalar la app.

## Backend opcional

El backend ya no es necesario para la version final de la app, porque el modelo corre localmente con TensorFlow Lite.

Aun asi, si se quiere probar el backend usado durante el desarrollo:

```powershell
cd backend/backend
py -3.11 -m venv ..\venv
..\venv\Scripts\python.exe -m pip install -r requirements.txt
..\venv\Scripts\python.exe predecir.py
```

El servidor se abre en:

```text
http://localhost:5000
```

El endpoint de prediccion es:

```text
POST http://localhost:5000/predict
```

Recibe una imagen en formato multipart con el campo `image`.

## Notas

- No se deben subir carpetas como `build/`, `.dart_tool/`, `.gradle/` o `venv/`.
- El modelo local `.tflite` si debe estar en `assets/models/`.
- Para usar la app final no se necesita internet ni servidor, solo tener instalada la aplicacion.
