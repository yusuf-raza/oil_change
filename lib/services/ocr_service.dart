import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  Future<int?> readMileage(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final result = await recognizer.processImage(inputImage);
    await recognizer.close();

    final matches = RegExp(r'\d+').allMatches(result.text);
    if (matches.isEmpty) {
      return null;
    }

    final values = matches
        .map((match) => int.tryParse(match.group(0) ?? ''))
        .whereType<int>()
        .toList();

    if (values.isEmpty) {
      return null;
    }

    values.sort((a, b) => b.compareTo(a));
    return values.first;
  }

  Future<double?> readNumeric(
    String imagePath, {
    bool allowDecimal = false,
  }) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final result = await recognizer.processImage(inputImage);
    await recognizer.close();

    final pattern = allowDecimal ? r'\d+(?:[.,]\d+)?' : r'\d+';
    final matches = RegExp(pattern).allMatches(result.text);
    if (matches.isEmpty) {
      return null;
    }

    final values = matches
        .map((match) => match.group(0)?.replaceAll(',', '.'))
        .map((value) => value == null ? null : double.tryParse(value))
        .whereType<double>()
        .toList();

    if (values.isEmpty) {
      return null;
    }

    values.sort((a, b) => b.compareTo(a));
    return values.first;
  }
}
