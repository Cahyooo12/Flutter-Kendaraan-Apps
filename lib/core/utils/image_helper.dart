import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ImageHelper {
  static final _picker = ImagePicker();

  static Future<File?> pickFromCamera() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1280,
      imageQuality: 80,
    );
    if (photo == null) return null;
    return _saveToAppDir(File(photo.path));
  }

  static Future<File?> pickFromGallery() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1280,
      imageQuality: 80,
    );
    if (photo == null) return null;
    return _saveToAppDir(File(photo.path));
  }

  static Future<File> _saveToAppDir(File file) async {
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}${p.extension(file.path)}';
    final savedFile = await file.copy('${appDir.path}/$fileName');
    return savedFile;
  }

  static Future<String> saveReceiptImage({
    required File file,
    required int vehicleId,
    required String type,
  }) async {
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = '${vehicleId}_${type}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedFile = await file.copy('${appDir.path}/$fileName');
    return savedFile.path;
  }

  static Future<void> deleteImage(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
