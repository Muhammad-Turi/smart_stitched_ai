import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OCRService {
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<List<String>> extractNumbers(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

    List<String> results = [];

    RegExp regExp = RegExp(r'\d{1,2}(\.\d{1,2})?');

    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        String cleanLine = line.text.trim();

        Iterable<Match> matches = regExp.allMatches(cleanLine);

        for (Match match in matches) {
          String val = match.group(0)!;
          double? numVal = double.tryParse(val);

          if (numVal != null && numVal >= 5 && numVal <= 70) {
            results.add(val);
          }
        }
      }
    }

    return results.toSet().toList();
  }
  void dispose() {
    _textRecognizer.close();
  }
}