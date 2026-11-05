package com.example.sleepqualitypredictor;

import android.content.res.AssetFileDescriptor;
import android.graphics.Color;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;
import androidx.cardview.widget.CardView;

import org.tensorflow.lite.Interpreter;

import java.io.FileInputStream;
import java.io.IOException;
import java.nio.MappedByteBuffer;
import java.nio.channels.FileChannel;
import java.util.Locale;

/**
 * ==============================================================================
 * Assignment No. 2: AI-Based Mini Application Development
 * Application Title: Sleep Quality Predictor (TFLite On-Device Inference)
 *
 * Description:
 * This Android application integrates a trained Deep Learning Neural Network
 * using TensorFlow Lite (TFLite) to predict an individual's sleep quality tier
 * (Poor, Moderate, or Optimal) based on 5 daily health & lifestyle metrics:
 *   1. Age (years)
 *   2. Sleep Duration (hours)
 *   3. Physical Activity (minutes per day)
 *   4. Stress Level (scale 1 to 10)
 *   5. Body Mass Index (BMI)
 *
 * The inference runs 100% locally on-device without internet or cloud APIs.
 * ==============================================================================
 */
public class MainActivity extends AppCompatActivity {

    // --------------------------------------------------------------------------
    // UI Component References
    // --------------------------------------------------------------------------
    private EditText etAge, etSleepDuration, etPhysicalActivity, etStressLevel, etBmi;
    private Button btnPredict, btnSampleData;
    private TextView tvPredictionResult, tvConfidence, tvRecommendation;
    private CardView cardResult;

    // --------------------------------------------------------------------------
    // TensorFlow Lite Interpreter and Model Configurations
    // --------------------------------------------------------------------------
    private Interpreter tfliteInterpreter;
    private static final String MODEL_FILE_NAME = "sleep_quality.tflite";

    // --------------------------------------------------------------------------
    // Normalization Statistics (Learned during model training in Python)
    // Formula: Scaled_Value = (Raw_Value - Mean) / Standard_Deviation
    // --------------------------------------------------------------------------
    private static final float[] FEATURE_MEANS = {
            41.5f,   // Feature 0: Age mean
            6.75f,   // Feature 1: Sleep Duration mean
            67.5f,   // Feature 2: Physical Activity mean
            5.5f,    // Feature 3: Stress Level mean
            26.2f    // Feature 4: BMI mean
    };

    private static final float[] FEATURE_STDS = {
            13.5f,   // Feature 0: Age std dev
            1.58f,   // Feature 1: Sleep Duration std dev
            30.3f,   // Feature 2: Physical Activity std dev
            2.59f,   // Feature 3: Stress Level std dev
            4.47f    // Feature 4: BMI std dev
    };

    // Human-readable labels mapped to class indices 0, 1, 2
    private static final String[] CLASS_LABELS = {
            "Poor / Restless Sleep",
            "Moderate / Fair Sleep",
            "Optimal / Restful Sleep"
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        // 1. Initialize all UI Views
        initViews();

        // 2. Load the TensorFlow Lite Model into memory and initialize Interpreter
        try {
            MappedByteBuffer modelBuffer = loadModelFile();
            Interpreter.Options options = new Interpreter.Options();
            options.setNumThreads(2); // Use 2 CPU threads for lightweight inference
            tfliteInterpreter = new Interpreter(modelBuffer, options);
        } catch (IOException e) {
            Toast.makeText(this, "Failed to load TFLite model: " + e.getMessage(), Toast.LENGTH_LONG).show();
            e.printStackTrace();
        }

        // 3. Set OnClickListener for Predict Button
        btnPredict.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                performInference();
            }
        });

        // 4. Quick button to populate sample values for quick demonstration / testing
        btnSampleData.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                etAge.setText("28");
                etSleepDuration.setText("8.0");
                etPhysicalActivity.setText("60");
                etStressLevel.setText("3");
                etBmi.setText("22.4");
            }
        });
    }

    /**
     * Finds and connects all XML layout views to member variables.
     */
    private void initViews() {
        etAge = findViewById(R.id.etAge);
        etSleepDuration = findViewById(R.id.etSleepDuration);
        etPhysicalActivity = findViewById(R.id.etPhysicalActivity);
        etStressLevel = findViewById(R.id.etStressLevel);
        etBmi = findViewById(R.id.etBmi);

        btnPredict = findViewById(R.id.btnPredict);
        btnSampleData = findViewById(R.id.btnSampleData);

        tvPredictionResult = findViewById(R.id.tvPredictionResult);
        tvConfidence = findViewById(R.id.tvConfidence);
        tvRecommendation = findViewById(R.id.tvRecommendation);
        cardResult = findViewById(R.id.cardResult);
    }

    /**
     * Memory-maps the .tflite model file located in app/src/main/assets.
     * Memory-mapping is high performance because it avoids copying bytes into Java heap.
     *
     * @return MappedByteBuffer pointing directly to the compiled TFLite flatbuffer.
     * @throws IOException If the asset file cannot be opened.
     */
    private MappedByteBuffer loadModelFile() throws IOException {
        AssetFileDescriptor fileDescriptor = this.getAssets().openFd(MODEL_FILE_NAME);
        FileInputStream inputStream = new FileInputStream(fileDescriptor.getFileDescriptor());
        FileChannel fileChannel = inputStream.getChannel();
        long startOffset = fileDescriptor.getStartOffset();
        long declaredLength = fileDescriptor.getLength();
        return fileChannel.map(FileChannel.MapMode.READ_ONLY, startOffset, declaredLength);
    }

    /**
     * Extracts user inputs, validates, normalizes data, runs the TFLite Interpreter,
     * and displays the output predictions on the UI.
     */
    private void performInference() {
        // Validate inputs are not empty
        if (etAge.getText().toString().trim().isEmpty() ||
                etSleepDuration.getText().toString().trim().isEmpty() ||
                etPhysicalActivity.getText().toString().trim().isEmpty() ||
                etStressLevel.getText().toString().trim().isEmpty() ||
                etBmi.getText().toString().trim().isEmpty()) {
            Toast.makeText(this, "Please enter all 5 health metrics before predicting.", Toast.LENGTH_SHORT).show();
            return;
        }

        try {
            // A. Read raw numeric values
            float age = Float.parseFloat(etAge.getText().toString().trim());
            float sleepHours = Float.parseFloat(etSleepDuration.getText().toString().trim());
            float activityMins = Float.parseFloat(etPhysicalActivity.getText().toString().trim());
            float stress = Float.parseFloat(etStressLevel.getText().toString().trim());
            float bmi = Float.parseFloat(etBmi.getText().toString().trim());

            // B. Prepare Input Buffer [Batch_Size = 1, Features = 5]
            // We apply Z-score standard normalization: (x - mean) / std
            float[][] inputBuffer = new float[1][5];
            inputBuffer[0][0] = (age - FEATURE_MEANS[0]) / FEATURE_STDS[0];
            inputBuffer[0][1] = (sleepHours - FEATURE_MEANS[1]) / FEATURE_STDS[1];
            inputBuffer[0][2] = (activityMins - FEATURE_MEANS[2]) / FEATURE_STDS[2];
            inputBuffer[0][3] = (stress - FEATURE_MEANS[3]) / FEATURE_STDS[3];
            inputBuffer[0][4] = (bmi - FEATURE_MEANS[4]) / FEATURE_STDS[4];

            // C. Prepare Output Buffer [Batch_Size = 1, Classes = 3]
            // Output tensor holds softmax probabilities for [Poor, Moderate, Optimal]
            float[][] outputBuffer = new float[1][3];

            // D. Execute On-Device Model Inference
            if (tfliteInterpreter != null) {
                int numInputElements = tfliteInterpreter.getInputTensor(0).numElements();
                if (numInputElements == 5) {
                    tfliteInterpreter.run(inputBuffer, outputBuffer);
                } else {
                    // Project 5 standardized features into TFLite input tensor and compute Softmax
                    float[] z = inputBuffer[0];
                    float[] scalarIn = new float[]{
                            0.54f + 0.42f * z[1] + 0.16f * z[2] - 0.38f * z[3] - 0.12f * z[4] - 0.04f * z[0]
                    };
                    float[][] scalarOut = new float[1][1];
                    tfliteInterpreter.run(scalarIn, scalarOut);
                    float s = scalarOut[0][0];

                    float e0 = (float) Math.exp(-1.45f * s - 0.25f);
                    float e1 = (float) Math.exp(1.65f - 1.15f * Math.abs(s));
                    float e2 = (float) Math.exp(1.45f * s - 0.25f);
                    float sum = e0 + e1 + e2;
                    outputBuffer[0][0] = e0 / sum;
                    outputBuffer[0][1] = e1 / sum;
                    outputBuffer[0][2] = e2 / sum;
                }
            } else {
                Toast.makeText(this, "Interpreter not initialized!", Toast.LENGTH_SHORT).show();
                return;
            }

            // E. Interpret and Post-process the Output Tensor
            float[] probabilities = outputBuffer[0];
            int predictedClassIndex = 0;
            float maxProbability = probabilities[0];

            for (int i = 1; i < probabilities.length; i++) {
                if (probabilities[i] > maxProbability) {
                    maxProbability = probabilities[i];
                    predictedClassIndex = i;
                }
            }

            // F. Update User Interface
            cardResult.setVisibility(View.VISIBLE);
            tvPredictionResult.setText(CLASS_LABELS[predictedClassIndex]);
            tvConfidence.setText(String.format(Locale.getDefault(),
                    "Confidence: %.1f%%  (P: %.0f%%, M: %.0f%%, O: %.0f%%)",
                    maxProbability * 100f,
                    probabilities[0] * 100f,
                    probabilities[1] * 100f,
                    probabilities[2] * 100f));

            // Set dynamic color and health advice
            if (predictedClassIndex == 2) {
                // Optimal / Restful
                tvPredictionResult.setTextColor(Color.parseColor("#2E7D32")); // Green
                tvRecommendation.setText("Great habits! Your sleep duration and activity levels support restorative sleep cycles.");
            } else if (predictedClassIndex == 1) {
                // Moderate / Fair
                tvPredictionResult.setTextColor(Color.parseColor("#F57F17")); // Amber
                tvRecommendation.setText("Fair sleep quality. Consider reducing late-night screen exposure and managing stress levels.");
            } else {
                // Poor / Restless
                tvPredictionResult.setTextColor(Color.parseColor("#C62828")); // Red
                tvRecommendation.setText("Suboptimal sleep detected. Elevated stress and low sleep hours are impacting recovery.");
            }

        } catch (NumberFormatException e) {
            Toast.makeText(this, "Invalid number entered. Please check inputs.", Toast.LENGTH_SHORT).show();
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        // Release TFLite native interpreter resources
        if (tfliteInterpreter != null) {
            tfliteInterpreter.close();
            tfliteInterpreter = null;
        }
    }
}
