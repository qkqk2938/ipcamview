import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

class GallerySaver {
  static Future<bool> saveImageToGallery(Uint8List imageBytes) async {
    if (!await requestPermission()) {
      return false;
    }

    final imagePath = await saveImage(imageBytes);
    final result = await saveToGallery(imagePath);
    return result;
  }

  static Future<String> saveImage(Uint8List imageBytes) async {
    final directory = await getTemporaryDirectory();
    final imagePath = '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.png';
    final imageFile = File(imagePath);
    await imageFile.writeAsBytes(imageBytes);
    return imagePath;
  }

  static Future<bool> saveToGallery(String imagePath) async {
    final imageFile = File(imagePath);
    final result = await GallerySaver.saveImage(imageFile);
    print(result);
    return true;
  }

  static Future<bool> requestPermission() async {
    final status = await Permission.photos.request();
    return status == PermissionStatus.granted;
  }
}
