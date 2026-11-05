# Sleep Quality Predictor - Android App with TensorFlow Lite

An AI-powered Android application that performs on-device machine learning inference using **TensorFlow Lite (TFLite)** to predict personal sleep quality tiers based on daily lifestyle and physiological metrics.

Developed for **Assignment No. 2: AI-Based Mini Application Development**  
*Course: Mobile Application Development*  
*Reference Repository:* [NumberGuessingAppTflite](https://github.com/Uzair390-Del/NumberGuessingAppTflite.git)

---

## 📌 Project Overview
Modern health tracking requires low-latency, private, and offline intelligence. This application embeds a trained Artificial Neural Network (ANN) directly into an Android app using TensorFlow Lite.

### Input Features:
1. **Age** (years)
2. **Sleep Duration** (hours per night)
3. **Physical Activity** (minutes per day)
4. **Stress Level** (scale 1 to 10)
5. **Body Mass Index (BMI)** (numeric score)

### Output Predictions:
- **Optimal / Restful Sleep** (Class 2, Green indicator + health insight)
- **Moderate / Fair Sleep** (Class 1, Amber indicator + guidance)
- **Poor / Restless Sleep** (Class 0, Red indicator + recovery warning)
- Exact inference confidence percentage and probability distribution.

---

## ⚙️ Architecture & Working Mechanism
1. **Model Loading:** The binary flatbuffer model `sleep_quality.tflite` in `assets/` is loaded into memory via `AssetFileDescriptor` and `FileChannel.map` as a `MappedByteBuffer`.
2. **Interpreter Initialization:** `org.tensorflow.lite.Interpreter` initializes a native C++ runtime on-device.
3. **Input Preprocessing:** User inputs from the UI are normalized using standard z-score normalization:
   $$\text{scaled\_value} = \frac{\text{raw\_value} - \mu}{\sigma}$$
4. **Inference Execution:** `interpreter.run(inputBuffer, outputBuffer)` performs low-latency inference (~15ms on modern mobile CPU).
5. **Post-Processing:** The output probabilities are parsed using `argmax`, updating the UI with colored status badges, percentage confidence, and actionable health feedback.

---

## 🛠️ Prerequisites & Dependencies
- **Android Studio:** Hedgehog (2023.1.1) or newer
- **Gradle:** 8.5+ with Android Gradle Plugin 8.5+
- **JDK:** Java 11 or 17
- **Target SDK:** 35 | **Minimum SDK:** 24 (Android 7.0+)
- **Core Library:** `org.tensorflow:tensorflow-lite:2.14.0`

---

## 🚀 How to Run the Project
1. Clone or extract this repository into your local machine:
   ```bash
   git clone https://github.com/Faizan-15/SleepQualityPredictor-TFLite-Android.git
   ```
2. Open **Android Studio** and select **File -> Open...**
3. Navigate to the `SleepQualityPredictor` directory and click **OK**.
4. Allow Gradle to sync dependencies automatically.
5. Connect an Android device (via USB with USB Debugging enabled) or start an Android Virtual Device (AVD).
6. Click the green **Run (Shift + F10)** button in Android Studio.
7. Click the **"Auto Fill"** button to load sample data or enter custom values, then click **"Predict Sleep"**.

---

## 📂 Repository Structure
```
SleepQualityPredictor/
├── app/
│   ├── src/
│   │   └── main/
│   │       ├── assets/
│   │       │   └── sleep_quality.tflite      # Compiled TFLite Neural Network Model
│   │       ├── java/com/example/sleepqualitypredictor/
│   │       │   └── MainActivity.java         # Core UI & TFLite Inference logic
│   │       ├── res/
│   │       │   └── layout/activity_main.xml  # Clean Material CardView UI
│   │       └── AndroidManifest.xml
│   └── build.gradle                         # TFLite dependency & noCompress rules
├── gradle/
├── build.gradle
├── settings.gradle
└── README.md
```

---

## 📜 References & Acknowledgments
- Starter Reference Repository: [NumberGuessingAppTflite](https://github.com/Uzair390-Del/NumberGuessingAppTflite.git)
- TensorFlow Lite Documentation: [https://www.tensorflow.org/lite](https://www.tensorflow.org/lite)
- Sleep Health and Lifestyle Dataset: Kaggle Public Domain Health Datasets
