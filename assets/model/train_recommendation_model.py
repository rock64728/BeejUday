import pandas as pd
from sklearn.preprocessing import LabelEncoder
from sklearn.neighbors import KNeighborsClassifier
from sklearn.ensemble import RandomForestClassifier
import joblib
import tensorflow as tf
import numpy as np

# Load data
df = pd.read_csv("crop_recommendation.csv")

# Encode crop name
encoder = LabelEncoder()
df['crop'] = encoder.fit_transform(df['crop'])

# Features and label
X = df.drop("crop", axis=1)
y = df['crop']

# Train models
rf = RandomForestClassifier(n_estimators=50)
rf.fit(X, y)

knn = KNeighborsClassifier(n_neighbors=3)
knn.fit(X, y)

# Save models
joblib.dump(rf, "rf_crop_model.pkl")
joblib.dump(knn, "knn_crop_model.pkl")
joblib.dump(encoder, "label_encoder.pkl")

print("Models trained and saved.")

# Create small neural model to mimic RF predictions
model = tf.keras.Sequential([
    tf.keras.layers.Dense(8, activation='relu', input_shape=(X.shape[1],)),
    tf.keras.layers.Dense(4, activation='softmax')
])

# Train neural model using RF outputs as labels
rf_labels = rf.predict(X)
model.compile(optimizer='adam', loss='sparse_categorical_crossentropy')
model.fit(X, rf_labels, epochs=50, verbose=0)

# Export to TFLite
converter = tf.lite.TFLiteConverter.from_keras_model(model)
tflite_model = converter.convert()

open("crop_recommendation.tflite", "wb").write(tflite_model)
print("TFLite model saved.")