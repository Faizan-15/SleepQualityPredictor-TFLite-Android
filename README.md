# Sleep Quality Predictor — Flutter & TensorFlow Lite (`tflite_flutter`)

An AI-powered cross-platform **Flutter (Dart)** mobile application that performs on-device machine learning inference using **TensorFlow Lite (`tflite_flutter`)** to predict personal sleep quality tiers based on daily lifestyle and physiological metrics.

Developed for **Assignment No. 2: AI-Based Mini Application Development**  
*Course: Mobile Application Development (BSCS-5B, KICSIT)*  
*Author:* **Muhammad Faizan Ashraf** (Roll No: `242201089`)  
*Reference Repository:* [NumberGuessingAppTflite](https://github.com/Uzair390-Del/NumberGuessingAppTflite.git)

---

## 📌 Project Overview
Modern health tracking requires low-latency, private, and offline intelligence. This Flutter application embeds a trained Deep Neural Network (`.tflite`) directly into the app bundle and executes inference on-device via `tflite_flutter`.

### Input Features (5 Health & Lifestyle Metrics):
1. **Age** (years)
2. **Sleep Duration** (hours per night)
3. **Physical Activity** (minutes per day)
4. **Stress Level** (scale 1 to 10)
5. **Body Mass Index (BMI)** (numeric score)

### Output Predictions:
- **Optimal / Restful Sleep** (Class 2, Green indicator + restorative health insight)
- **Moderate / Fair Sleep** (Class 1, Amber indicator + sleep hygiene guidance)
- **Poor / Restless Sleep** (Class 0, Red indicator + recovery warning)
- Exact inference confidence percentage and 3-class Softmax probability distribution.

---

## ⚙️ Architecture & Working Mechanism
1. **Model Loading (`lib/services/tflite_sleep_service.dart`):** Loads `assets/sleep_quality.tflite` using `Interpreter.fromAsset('assets/sleep_quality.tflite')`.
2. **Input Preprocessing:** Raw user inputs from Flutter `TextField` controllers are standardized using training Z-score normalization parameters ($\mu$ and $\sigma$).
3. **Inference Execution:** `_interpreter.run(inputBuffer, outputBuffer)` executes the forward pass locally in under 5ms.
4. **Post-Processing (`lib/widgets/prediction_result_card.dart`):** Softmax probabilities are parsed via `ArgMax` to render color-coded Material 3 diagnostic cards.

---

## 📂 Repository Structure
```text
SleepQualityPredictor-TFLite-Android/
├── assets/
│   └── sleep_quality.tflite                 # Quantized TFLite Neural Network Model
├── lib/
│   ├── main.dart                            # Flutter Application Entry Point
│   ├── models/
│   │   └── sleep_prediction.dart            # Data Models (SleepInputMetrics, SleepPredictionResult)
│   ├── screens/
│   │   └── home_screen.dart                 # Interactive Material 3 Form & Prediction Screen
│   ├── services/
│   │   └── tflite_sleep_service.dart        # TFLite Interpreter Wrapper & Z-Score Normalizer
│   └── widgets/
│       └── prediction_result_card.dart      # Dynamic Color-Coded Outcome Card Widget
├── test/
│   └── widget_test.dart                     # Unit Tests for TC-01, TC-02, TC-03 Profiles
├── app/                                     # Android Studio Host Module & Gradle Wrapper
├── pubspec.yaml                             # Flutter Dependencies (tflite_flutter) & Assets
├── train_sleep_quality.py                   # Python Keras Training & TFLite Conversion Script
├── SleepQualityPredictor.apk                # Pre-built Signed Installable Android APK
└── README.md
```

---

## 🚀 How to Run the Project

### Option A: Run with Flutter CLI
```bash
git clone https://github.com/Faizan-15/SleepQualityPredictor-TFLite-Android.git
cd SleepQualityPredictor-TFLite-Android
flutter pub get
flutter run
```

### Option B: Install the Pre-Built Signed APK Directly
Download [`SleepQualityPredictor.apk`](./SleepQualityPredictor.apk) from this repository and install it on any Android device (Android 7.0+ / API 24+):
```bash
adb install -r SleepQualityPredictor.apk
```
