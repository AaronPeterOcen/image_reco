import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ImageAnalyzer extends StatefulWidget {
  const ImageAnalyzer({super.key});

  @override
  State<ImageAnalyzer> createState() => _ImageAnalyzerState();
}

class _ImageAnalyzerState extends State<ImageAnalyzer> {
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
  }

  @override
  void initState() {
    super.initState();
    _getAPIkey();
  }

  @override
  Widget build(BuildContext context) {
    // var _pickedFiles;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Suggestor'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _pickFiles,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        (_selectedFileName == "")
                            ? const Text(
                                'Select a photo of the ingredients',
                                style: TextStyle(color: Colors.black54),
                              )
                            : Text(
                                _selectedFileName,
                                style: const TextStyle(color: Colors.black54),
                              ),
                        const Icon(Icons.image, color: Colors.teal),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: _generateRecipe,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Submit'),
                ),
              ],
            ),
            const SizedBox(height: 24.0),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.teal[50],
                  borderRadius: BorderRadius.circular(12.0),
                ),
                width: double.infinity,
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(minWidth: double.infinity),
                    child: SelectableText(
                      generatedText,
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.teal[900],
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
