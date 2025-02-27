import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

void _getAPIkey() async {
  // This function gets the API key and sets up the model to be used in _generateRecipe()

  // Uses the flutter_dotenv library to get the API key stored in .env
  await dotenv.load(fileName: ".env");
  var apikey = dotenv.env['API_KEY'] ?? '';

  // Sets up the Gemini Flash model that is multimodal and can read both images and text
  var _model = GenerativeModel(
    model: 'gemini-1.5-flash-latest',
    apiKey: apikey,
    safetySettings: [
      SafetySetting(HarmCategory.harassment, HarmBlockThreshold.high),
      SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.high),
    ],
  );
}
