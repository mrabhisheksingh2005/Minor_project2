# AgriVision AI – Smart Farming Through Artificial Intelligence

AgriVision AI is an offline-capable, premium-designed Flutter application built as a Capstone/B.Tech CSE major project. It leverages machine learning concepts to detect crop leaf diseases, providing instant diagnostics, treatment guides, an interactive chatbot assistant, and real-time agricultural advisories.

## 🌟 Key Features

* **Visual Splash & Onboarding**: A beautiful 3-page slideshow introducing crop diagnostics, detail sheets, and chat support with rich green-earth aesthetics.
* **Smart Dashboard**: Hosts a mock location-based weather station displaying temperature, soil moisture, humidity, and rainfall probability along with dynamic daily farming tips and notification updates.
* **Scan Leaf Flow**: Multi-option leaf scan interface supporting camera capture and gallery uploads. Features a realistic step-by-step loading phase (simulating neural network feature extraction).
* **Deep Diagnostic Results**: Comprehensive results display primary diagnosed disease with confidence metrics, symptoms, biological causes, chemical treatments, organic remedies, prevention strategies, and a list of alternative predictions.
* **Offline Crop Guide**: Fully browsable catalog covering common diseases of **Tomato, Potato, Rice, Wheat, Corn, Cotton, Chili, Apple, and Grapes**.
* **Agri AI Chat Assistant**: Keyword-matching chatbot that simulates expert agronomy advice about watering, N-P-K ratios, compost preparation, and disease treatments.
* **Farmer Profile & Settings**: Supports a dark mode toggle (forest-earth theme), mock Hindi language selection, push alert settings, and project info metadata.

---

## 🛠️ Architecture & Tech Stack

AgriVision AI is structured following a **clean, feature-based architecture** under the `lib/` directory:

```
lib/
├── core/
│   ├── models/           # Common data models (DiseaseInfo, ScanRecord)
│   ├── services/         # Interfaces and mock service implementations (AI Prediction, Weather, Chat)
│   ├── router.dart       # Declarative go_router configuration
│   └── theme.dart        # Light & Dark Material 3 theme schemes
└── features/
    ├── onboarding/       # Splash & onboarding screen flows
    ├── dashboard/        # Home screen & shell navigation container
    ├── scan/             # Crop selector, camera/gallery picking, and results report
    ├── history/          # Local logs list & scan details database
    ├── assistant/        # Chatbot assistant widget & provider
    ├── guide/            # Offline crop guide list & detailed cards
    └── profile/          # Settings page, dark mode toggle, and project details
```

### Libraries Used:
* **State Management**: `provider` (version `^6.1.5+1`)
* **Routing**: `go_router` (version `^14.8.1`)
* **Camera/Gallery Picker**: `image_picker` (version `^1.2.3`)
* **Local Persistence**: `shared_preferences` (version `^2.5.5`)
* **Localization / Formats**: `intl` (version `^0.19.0`)

---

## 🚀 Setting Up & Running Locally

### Prerequisites
* Flutter SDK (v3.12.2+ or stable)
* Android Studio / VS Code with Dart & Flutter plugins
* Android Emulator or physical device

### Running Commands
1. Clone or navigate to the project directory:
   ```bash
   cd agrivision_ai
   ```
2. Fetch package dependencies:
   ```bash
   flutter pub get
   ```
3. Run static analyzer (guaranteed compilation-safe, 0 errors):
   ```bash
   flutter analyze
   ```
4. Start the application:
   ```bash
   flutter run
   ```

---

## 🧠 Future Real-AI Integration Path

For academic submissions or production expansion, replace `MockDiseasePredictionService` inside `lib/core/services/prediction_service.dart` with one of the following methods:

### Option A: Local Mobile Inference via TensorFlow Lite
To run AI models completely offline on the phone:
1. Export your trained CNN model (e.g. ResNet50 or MobileNetV2 trained on the PlantVillage dataset) as a `.tflite` model file.
2. Add the `tflite_v2` or `google_mlkit_image_labeling` dependency to `pubspec.yaml`.
3. Import the model and labels into your `assets/` directory.
4. Implement a `TFLitePredictionService` extending `DiseasePredictionService`:
   ```dart
   class TFLitePredictionService implements DiseasePredictionService {
     @override
     Future<DiseasePredictionResult> predictCropDisease({
       required String imagePath,
       required String selectedCrop,
     }) async {
       // 1. Load model bytes from assets
       // 2. Preprocess the image to 224x224 RGB float arrays
       // 3. Run model inference: Tflite.runModelOnImage(path: imagePath)
       // 4. Match highest confidence index to DiseaseInfo.cropDiseasesDataset
       // 5. Return DiseasePredictionResult
     }
   }
   ```

### Option B: Cloud API Inference via Flask / FastAPI
To run complex models on a GPU server:
1. Deploy your PyTorch/TensorFlow models on a Python Flask or FastAPI server.
2. Expose a `/predict` endpoint that receives an image file and returning crop, disease, and confidence JSON arrays.
3. Add the `http` package to `pubspec.yaml`.
4. Implement a `RESTApiPredictionService` extending `DiseasePredictionService`:
   ```dart
   import 'package:http/http.dart' as http;
   
   class RESTApiPredictionService implements DiseasePredictionService {
     final String apiUrl = 'https://api.yourfarm.com/predict';

     @override
     Future<DiseasePredictionResult> predictCropDisease({
       required String imagePath,
       required String selectedCrop,
     }) async {
       var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
       request.files.add(await http.MultipartFile.fromPath('image', imagePath));
       request.fields['crop'] = selectedCrop;
       
       var response = await request.send();
       if (response.statusCode == 200) {
         // Parse the response body JSON and retrieve matching DiseaseInfo
       } else {
         throw Exception('Inference server returned status ${response.statusCode}');
       }
     }
   }
   ```
5. Simply swap the binding in `lib/main.dart` from `MockDiseasePredictionService()` to `RESTApiPredictionService()`. Because the code follows clean architecture, **no UI components will ever need modification!**
