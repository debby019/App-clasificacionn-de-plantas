"""
Clasificador de Plantas con MobileNetV2 + Transfer Learning
"""

import os
import json
import warnings
import numpy as np
import matplotlib.pyplot as plt
import tensorflow as tf
import seaborn as sns

from tensorflow.keras import layers, models, optimizers, callbacks
from tensorflow.keras.applications import MobileNetV2
from tensorflow.keras.preprocessing.image import ImageDataGenerator

from sklearn.metrics import classification_report, confusion_matrix




# 1. CONFIGURACIÓN GENERAL

IMG_SIZE = (224, 224)
BATCH_SIZE = 32

EPOCHS_FREEZE = 15
EPOCHS_FINETUNE = 20

SEED = 42
VALIDATION_SPLIT = 0.15
DATASET_DIR = "dataset"


# 2. DATA AUGMENTATION

train_datagen = ImageDataGenerator(
    rescale=1.0 / 255,
    rotation_range=30,
    width_shift_range=0.15,
    height_shift_range=0.15,
    shear_range=0.10,
    zoom_range=0.20,
    horizontal_flip=True,
    vertical_flip=False,
    brightness_range=[0.75, 1.25],
    channel_shift_range=20.0,
    fill_mode="reflect",
    validation_split=VALIDATION_SPLIT
)

train_generator = train_datagen.flow_from_directory(
    DATASET_DIR,
    target_size=IMG_SIZE,
    batch_size=BATCH_SIZE,
    class_mode="categorical",
    subset="training",
    shuffle=True,
    seed=SEED
)

val_generator = train_datagen.flow_from_directory(
    DATASET_DIR,
    target_size=IMG_SIZE,
    batch_size=BATCH_SIZE,
    class_mode="categorical",
    subset="validation",
    shuffle=False,
    seed=SEED
)

class_names = list(train_generator.class_indices.keys())
NUM_CLASSES = len(class_names)

print("\nClases detectadas:", train_generator.class_indices)
print(f"Número de clases: {NUM_CLASSES}")

with open("clases.json", "w") as f:
    json.dump(train_generator.class_indices, f, indent=4)


# 3. CONSTRUCCIÓN DEL MODELO
def build_model(num_classes, dropout_rate=0.4):
    base_model = MobileNetV2(
        input_shape=(*IMG_SIZE, 3),
        include_top=False,
        weights="imagenet",
        alpha=1.0
    )

    base_model.trainable = False

    inputs = tf.keras.Input(shape=(*IMG_SIZE, 3))

 
    x = base_model(inputs)

    x = layers.GlobalAveragePooling2D()(x)

    # Clasificación
    x = layers.Dense(256, activation="relu")(x)
    x = layers.BatchNormalization()(x)
    x = layers.Dropout(dropout_rate)(x)

    x = layers.Dense(128, activation="relu")(x)
    x = layers.BatchNormalization()(x)
    x = layers.Dropout(dropout_rate / 2)(x)

    outputs = layers.Dense(num_classes, activation="softmax")(x)
    model = models.Model(inputs, outputs)

    return model, base_model

model, base_model = build_model(NUM_CLASSES)
model.summary()


# 4. FASE 1 
model.compile(
    optimizer=optimizers.Adam(learning_rate=1e-3),
    loss="categorical_crossentropy",
    metrics=["accuracy"]
)

os.makedirs("checkpoints", exist_ok=True)

callbacks_phase1 = [
    callbacks.EarlyStopping(
        monitor="val_loss",
        patience=5,
        restore_best_weights=True,
        verbose=1
    ),
    callbacks.ReduceLROnPlateau(
        monitor="val_loss",
        factor=0.5,
        patience=3,
        min_lr=1e-6,
        verbose=1
    ),
    callbacks.ModelCheckpoint(
        "checkpoints/best_phase1.keras",
        monitor="val_accuracy",
        save_best_only=True,
        verbose=1
    )
]

print("\n   FASE 1: Entrenando cabeza       ")
history1 = model.fit(
    train_generator,
    validation_data=val_generator,
    epochs=EPOCHS_FREEZE,
    callbacks=callbacks_phase1
)


# 5. FASE 2 — FINE TUNING 
print("\n  FASE 2: Fine-Tuning    ")

base_model.trainable = True


FINE_TUNE_AT = 130
for layer in base_model.layers[:FINE_TUNE_AT]:
    layer.trainable = False

# Learning rate a 1e-5 
model.compile(
    optimizer=optimizers.Adam(learning_rate=1e-5),
    loss="categorical_crossentropy",
    metrics=["accuracy"]
)

callbacks_phase2 = [
    callbacks.EarlyStopping(
        monitor="val_loss",
        patience=7,
        restore_best_weights=True,
        verbose=1
    ),
    callbacks.ReduceLROnPlateau(
        monitor="val_loss",
        factor=0.3,
        patience=4,
        min_lr=1e-7,
        verbose=1
    ),
    callbacks.ModelCheckpoint(
        "checkpoints/best_phase2.keras",
        monitor="val_accuracy",
        save_best_only=True,
        verbose=1
    )
]

history2 = model.fit(
    train_generator,
    validation_data=val_generator,
    epochs=EPOCHS_FINETUNE,
    callbacks=callbacks_phase2,
    initial_epoch=len(history1.history["loss"])
)



print("\n      Evaluación Final     ")
loss, acc = model.evaluate(val_generator)
print(f"\nValidation Loss: {loss:.4f}")
print(f"Validation Accuracy: {acc:.4f}")

model.save("plant_classifier_mobilenetv2.keras")
print("\nModelo guardado: Modelo_v2.keras")


# 7. GRÁFICAS DE ENTRENAMIENTO

def merge_histories(h1, h2):
    merged = {}
    for key in h1.history:
        merged[key] = h1.history[key] + h2.history[key]
    return merged

history = merge_histories(history1, history2)
fig, axes = plt.subplots(1, 2, figsize=(14, 5))
fig.suptitle("MobileNetV2 Optimizado — Clasificación de Plantas", fontsize=14)

# Gráfica de Accuracy
axes[0].plot(history["accuracy"], label="Train Accuracy")
axes[0].plot(history["val_accuracy"], label="Val Accuracy", linestyle="--")
axes[0].axvline(x=len(history1.history["accuracy"]) - 1, color="gray", linestyle=":")
axes[0].set_title("Accuracy")
axes[0].set_xlabel("Época")
axes[0].legend()

# Gráfica de Loss
axes[1].plot(history["loss"], label="Train Loss")
axes[1].plot(history["val_loss"], label="Val Loss", linestyle="--")
axes[1].axvline(x=len(history1.history["loss"]) - 1, color="gray", linestyle=":")
axes[1].set_title("Loss")
axes[1].set_xlabel("Época")
axes[1].legend()

plt.tight_layout()
plt.savefig("training_curves.png", dpi=150)
plt.show()


# 8. MATRIZ DE CONFUSIÓN Y REPORTE

val_generator.reset()
y_pred = model.predict(val_generator)
y_pred_classes = np.argmax(y_pred, axis=1)
y_true = val_generator.classes

print("\n     Classification Report       ")
print(classification_report(y_true, y_pred_classes, target_names=class_names))

cm = confusion_matrix(y_true, y_pred_classes)
plt.figure(figsize=(8, 6))
sns.heatmap(cm, annot=True, fmt='d', cmap="Blues", xticklabels=class_names, yticklabels=class_names)
plt.title("Matriz de Confusión Final")
plt.xlabel("Predicción")
plt.ylabel("Real")
plt.tight_layout()
plt.savefig("confusion_matrix.png")
plt.show()