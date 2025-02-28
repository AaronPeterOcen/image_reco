import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

String _selectedFileName = '';
Uint8List? _imageBytes;
String generatedText = '';
late final _model;

void _getAPIkey() async {
  // This function gets the API key and sets up the model to be used in _generateRecipe()

  // Uses the flutter_dotenv library to get the API key stored in .env
  await dotenv.load(fileName: ".env");
  var apikey = dotenv.env['API_KEY'] ?? '';

  // Sets up the Gemini Flash model that is multimodal and can read both images and text
  _model = GenerativeModel(
    model: 'gemini-1.5-flash-latest',
    apiKey: apikey,
    safetySettings: [
      SafetySetting(HarmCategory.harassment, HarmBlockThreshold.high),
      SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.high),
    ],
  );
}

void _pickFiles() async {
  // This function enables users to pick files from their local directories
  // This is used to allow users to select the image with the ingredients they want to cook with
  // Uses the file picker Flutter library to achieve this

  // The result variable contains the user's selected file
  // The parameters here only allows the user to upload one image files
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowMultiple: false,
    allowedExtensions: ['jpg', 'jpeg', 'png'],
  );

  if (result != null) {
    PlatformFile file = result.files.first;

    // Updates file name and data into appropriate variables when the user selects the files
    setState(() {
      _selectedFileName = file.name;
      _imageBytes = file.bytes;
    });
  } else {
    // User canceled the picker
  }
}

void setState(Null Function() param0) {}

void _generateRecipe() async {
  //  This function creates the recipe based on the user provided image. This function is where Gemini is used.

  // The instructions provided tell Gemini to create a recipe based on all logical ingredients observed in the image
  String prompt = '''You are an expert cook with detailed knowledge of making 
    recipes. A user is interested in making recipes with a certain set of 
    ingredients and have provided this. If no ingredients that can be used to realistically create
    food are provided, please state 'No ingredients in picture' to the user. 
    Please generate a recipe that uses these ingredients. Please only return the 
    following sections: Recipe Name, Ingredients, Complexity, Steps to Create. 
    Please only return the recipe and do not return any other text in your 
    response.''';

  final content = [
    Content.multi([
      TextPart(prompt),
      // The only accepted mime types are image/*.
      DataPart('image/jpeg', _imageBytes!),
      // DataPart('image/jpeg', sconeBytes.buffer.asUint8List()),
    ])
  ];

  // The model is then run and the recipe is generated
  final recipe = await _model.generateContent(content);

  // Sets state to update the display of the app
  setState(() {
    generatedText = recipe.text;
  });
}
