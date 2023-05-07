import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hotelapp/Utils/global.dart';
import 'package:path_provider/path_provider.dart';
import 'Data/entry.dart';
import 'Services/entryDB.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class ViewModel extends StatefulWidget {
  final Entry entry;
  final VoidCallback refresher;
  ViewModel({super.key, required this.entry, required this.refresher});

  @override
  ViewModelState createState() => ViewModelState();
}

class ViewModelState extends State<ViewModel> {
  double diameter = 28;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: darkGreen2,
        toolbarHeight: 64,
        foregroundColor: Colors.white,
        title: Text(widget.entry.name),
        actions: [
          IconButton(
            onPressed: () => download(context),
            icon: Icon(
              Icons.file_download_outlined,
            ),
          ),
          IconButton(
            onPressed: () => delete(),
            icon: Icon(
              Icons.delete_outline,
            ),
          ),
        ],
      ),
      body: ModelViewer(
        src: "file://${widget.entry.model}",
        alt: "3D model of ${widget.entry.name}",
        ar: true,
        autoRotate: true,
        cameraControls: true,
      ),
    );
  }

  delete() async {
    var db = EntryDBProvider.db;
    db.deleteEntry(widget.entry.id!.toInt());
    widget.refresher();

    Navigator.of(context)
        .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
  }

  download(BuildContext context) async {
    var downloadsDir;

    if (Platform.isAndroid) {
      downloadsDir = Directory('/storage/emulated/0/Download');
    } else {
      downloadsDir = await getDownloadsDirectory();
    }

    final sourceFile = File(widget.entry.model);
    final destinationFile = await File(
        "${downloadsDir?.path}/${widget.entry.name.replaceAll(' ', '_')}.glb").create();

    try {
      await sourceFile.copy(destinationFile.path);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File downloaded successfully.')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error downloading file.')));
    }
  }
}
