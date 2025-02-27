// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_skeleton/image_analyzer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.ubuntuTextTheme(textTheme).copyWith(
          bodyMedium: GoogleFonts.aBeeZee(textStyle: textTheme.bodyMedium),
        ),
      ),
      home: const ImageAnalyzer(),
    );
  }
}
