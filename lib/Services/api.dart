import 'dart:io';
import '../Utils/global.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class Api{
  static removebg(String imgPath, String filename) async {
    var req = http.MultipartRequest("POST", Uri.parse("$apiURL/remove-bg"));
    req.files.add(await http.MultipartFile.fromPath("image", imgPath));

    final dir = await getApplicationDocumentsDirectory();
    final path = "${dir.path}/$filename.png";

    final res = await req.send();

    if(res.statusCode == 200) {
      http.Response img = await http.Response.fromStream(res);
      final file = File(path);
      await file.writeAsBytes(img.bodyBytes);
      return path;
    }
  }

  static generateModel(String imgPath, String filename) async {
    var req = http.MultipartRequest("POST", Uri.parse("$apiURL/generate"));
    req.files.add(await http.MultipartFile.fromPath("image", imgPath));

    final dir = await getApplicationDocumentsDirectory();
    final path = "${dir.path}/$filename.glb";

    final res = await req.send();
    if(res.statusCode == 200) {
      http.Response model = await http.Response.fromStream(res);
      final file = File(path);
      await file.writeAsBytes(model.bodyBytes);
      return path;
    }
  }
}