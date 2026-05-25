from pathlib import Path
import json

from flask import Flask, jsonify, request
from flask_cors import CORS
import numpy as np
from PIL import Image
import tensorflow as tf


BASE_DIR = Path(__file__).resolve().parent
MODEL_PATH = BASE_DIR / "plant_classifier_mobilenetv2_v2.keras"
CLASSES_PATH = BASE_DIR / "clases.json"
IMG_SIZE = (224, 224)
CONFIDENCE_THRESHOLD = 85.0

print("Cargando modelo...")
model = tf.keras.models.load_model(MODEL_PATH)

with open(CLASSES_PATH, "r", encoding="utf-8") as f:
    class_indices = json.load(f)

class_names = list(class_indices.keys())
print("Clases:", class_names)

app = Flask(__name__)
CORS(app)


def preprocess_image(image):
    image = image.convert("RGB")
    image = image.resize(IMG_SIZE)
    image = np.array(image)
    image = image / 255.0
    image = np.expand_dims(image, axis=0)
    return image


@app.route("/")
def home():
    return {
        "message": "API Clasificador de Plantas funcionando",
        "classes": class_names,
    }


@app.route("/predict", methods=["POST"])
def predict():
    if "image" not in request.files:
        return jsonify({"error": "No se envio imagen"}), 400

    file = request.files["image"]

    try:
        image = Image.open(file)
        processed = preprocess_image(image)
        predictions = model.predict(processed, verbose=0)[0]

        predicted_index = int(np.argmax(predictions))
        predicted_class = class_names[predicted_index]
        confidence = float(predictions[predicted_index] * 100)
        identified = confidence >= CONFIDENCE_THRESHOLD

        results = []
        sorted_predictions = sorted(
            zip(class_names, predictions),
            key=lambda item: item[1],
            reverse=True,
        )

        for class_name, prob in sorted_predictions:
            results.append({
                "class": class_name,
                "confidence": round(float(prob * 100), 2),
            })

        return jsonify({
            "prediction": predicted_class if identified else "No se identifico la planta",
            "confidence": round(confidence, 2),
            "identified": identified,
            "threshold": CONFIDENCE_THRESHOLD,
            "message": "Planta identificada correctamente"
            if identified
            else "La imagen no coincide con ninguna planta conocida",
            "all_predictions": results,
        })

    except Exception as e:
        return jsonify({"error": str(e)}), 500


if __name__ == "__main__":
    app.run(
        host="0.0.0.0",
        port=5000,
        debug=False,
        use_reloader=False,
    )
