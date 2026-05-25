from pathlib import Path
import argparse
import json

import numpy as np
from PIL import Image
import tensorflow as tf


BASE_DIR = Path(__file__).resolve().parent
DEFAULT_MODEL = BASE_DIR / "plant_classifier_mobilenetv2.keras"
CLASSES_PATH = BASE_DIR / "clases.json"
TEST_DIR = BASE_DIR / "testimg"
IMG_SIZE = (224, 224)

EXPECTED_BY_NAME = {
    "aloe": "Aloe_Vera",
    "monstera": "Monstera_Deliciosa",
    "orquidea": "Orchid",
    "orchid": "Orchid",
}


def preprocess_image(path):
    image = Image.open(path).convert("RGB")
    image = image.resize(IMG_SIZE)
    image = np.array(image) / 255.0
    return np.expand_dims(image, axis=0)


def expected_class_for(path):
    name = path.name.lower()
    for marker, class_name in EXPECTED_BY_NAME.items():
        if marker in name:
            return class_name
    return None


def run_tests(model_path):
    with open(CLASSES_PATH, "r", encoding="utf-8") as f:
        class_indices = json.load(f)

    class_names = list(class_indices.keys())
    model = tf.keras.models.load_model(model_path)

    image_paths = sorted(
        path for path in TEST_DIR.iterdir()
        if path.suffix.lower() in {".jpg", ".jpeg", ".png", ".webp"}
    )

    total = 0
    correct = 0
    rows = []

    for path in image_paths:
        expected = expected_class_for(path)
        if expected is None:
            continue

        predictions = model.predict(preprocess_image(path), verbose=0)[0]
        predicted_index = int(np.argmax(predictions))
        predicted_class = class_names[predicted_index]
        confidence = float(predictions[predicted_index] * 100)
        ok = predicted_class == expected

        total += 1
        correct += int(ok)
        rows.append((path.name, expected, predicted_class, confidence, ok))

    accuracy = (correct / total * 100) if total else 0
    print(f"Modelo: {model_path}")
    print(f"Pruebas: {correct}/{total} correctas ({accuracy:.2f}%)")
    print()

    for filename, expected, predicted, confidence, ok in rows:
        status = "OK" if ok else "FALLO"
        print(
            f"{status:5} | {filename:55} | "
            f"esperado={expected:18} predicho={predicted:18} "
            f"confianza={confidence:.2f}%"
        )

    return correct, total


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "model",
        nargs="?",
        default=str(DEFAULT_MODEL),
        help="Ruta al modelo .keras que se quiere probar",
    )
    args = parser.parse_args()
    run_tests(Path(args.model).resolve())


if __name__ == "__main__":
    main()
