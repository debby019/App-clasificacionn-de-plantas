from pathlib import Path

import tensorflow as tf


BASE_DIR = Path(__file__).resolve().parent
MODEL_PATH = BASE_DIR / "plant_classifier_mobilenetv2_v2.keras"
OUTPUT_PATH = BASE_DIR / "plant_classifier_mobilenetv2_v2.tflite"


def main():
    print(f"Cargando modelo: {MODEL_PATH}")
    model = tf.keras.models.load_model(MODEL_PATH)

    print("Convirtiendo a TensorFlow Lite...")
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    tflite_model = converter.convert()

    OUTPUT_PATH.write_bytes(tflite_model)
    print(f"Modelo TFLite guardado en: {OUTPUT_PATH}")
    print(f"Tamano: {OUTPUT_PATH.stat().st_size / (1024 * 1024):.2f} MB")


if __name__ == "__main__":
    main()
