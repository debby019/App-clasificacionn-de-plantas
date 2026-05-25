# Backend GreenHouse

API Flask para clasificar plantas con el modelo `plant_classifier_mobilenetv2.keras`.

## Ejecutar

Desde esta carpeta, usando una version de Python compatible con TensorFlow, idealmente Python 3.11 o 3.12:

```powershell
py -3.11 -m venv ..\venv
..\venv\Scripts\python.exe -m pip install -r requirements.txt
..\venv\Scripts\python.exe predecir.py
```

La API queda disponible en:

```text
http://localhost:5000
http://localhost:5000/predict
```

`/predict` recibe una imagen en un formulario multipart con el campo `image`.

## Flutter

En el emulador Android usa:

```text
http://10.0.2.2:5000
```

En Windows, web o navegador local usa:

```text
http://localhost:5000
```
