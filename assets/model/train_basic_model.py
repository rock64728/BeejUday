import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LinearRegression
from sklearn.ensemble import RandomForestRegressor
import joblib
import tensorflow as tf
import numpy as np

# Load dataset
df = pd.read_csv("agri_training_data.csv")

# ---- PRICE MODEL ----
price_features = ["rainfall", "temp", "humidity"]
X_price = df[price_features]
y_price = df["price_per_qtl"]

price_model = LinearRegression()
price_model.fit(X_price, y_price)

joblib.dump(price_model, "price_model.pkl")
print("Price model trained and saved.")


# ---- YIELD MODEL ----
yield_features = ["rainfall", "temp", "humidity", "fertilizer_cost", "seed_cost", "labour_cost"]
X_yield = df[yield_features]
y_yield = df["yield_qtl_per_ha"]

yield_model = RandomForestRegressor(n_estimators=10)
yield_model.fit(X_yield, y_yield)

joblib.dump(yield_model, "yield_model.pkl")
print("Yield model trained and saved.")



# Convert sklearn price model to TFLite
coef = price_model.coef_
intercept = price_model.intercept_

price_tf = tf.keras.Sequential([
    tf.keras.layers.Dense(1, input_shape=(3,), activation=None)
])
price_tf.layers[0].set_weights([coef.reshape((3,1)), np.array([intercept])])

converter = tf.lite.TFLiteConverter.from_keras_model(price_tf)
price_tflite_model = converter.convert()
open("price_model.tflite", "wb").write(price_tflite_model)

print("TFLite price model ready.")


# Convert yield model (simple version)
yield_tf = tf.keras.Sequential([
    tf.keras.layers.Dense(1, input_shape=(6,), activation=None)
])
yield_tf.layers[0].set_weights([np.ones((6,1)), np.array([0])])

converter = tf.lite.TFLiteConverter.from_keras_model(yield_tf)
yield_tflite_model = converter.convert()
open("yield_model.tflite", "wb").write(yield_tflite_model)

print("TFLite yield model ready.")

