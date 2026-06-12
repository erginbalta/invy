import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class ReceiptScanService {
  ReceiptScanService({
    ImagePicker? imagePicker,
  }) : _imagePicker = imagePicker ?? ImagePicker();

  final ImagePicker _imagePicker;

  Future<String?> scanFrom(ImageSource source) async {
    final image = await _imagePicker.pickImage(source: source, imageQuality: 85);
    if (image == null) return null;

    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final input = InputImage.fromFilePath(image.path);
      final result = await recognizer.processImage(input);
      return result.text.trim();
    } finally {
      await recognizer.close();
    }
  }
}
