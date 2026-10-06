import tensorflow as tf

# Load your trained Keras model
model = tf.keras.models.load_model("keras_model.h5")

# Convert to TensorFlow Lite
converter = tf.lite.TFLiteConverter.from_keras_model(model)
converter.optimizations = [tf.lite.Optimize.DEFAULT]

tflite_model = converter.convert()

with open("model.tflite", "wb") as f:
    f.write(tflite_model)

print("✅ Model converted to model.tflite")
