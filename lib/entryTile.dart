import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hotelapp/viewModel.dart';
import 'package:path_provider/path_provider.dart';
import 'Data/entry.dart';
import 'Services/entryDB.dart';
import 'Utils/global.dart';

typedef refreshCallback = void Function(BuildContext context, Entry entry);

class EntryTile extends StatefulWidget {
  final Entry entry;
  final VoidCallback refresher;
  EntryTile({super.key, required this.entry, required this.refresher});

  @override
  EntryTileState createState() => EntryTileState();
}

class EntryTileState extends State<EntryTile> {
  double diameter = 28;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: darkGreen1,
        borderRadius: BorderRadius.circular(24),
      ),
      child: InkWell(
        onTap: () => open(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  child: ClipOval(
                    child: Image.file(
                      File(
                        widget.entry.photo,
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.entry.name,
                      style: textDecoration,
                    ),
                    TextButton(
                      onPressed: () => open(),
                      style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(50, 30),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          alignment: Alignment.centerLeft),
                      child: const Text("View Model"),
                    )
                  ],
                ),
              ],
            ),
            PopupMenuButton<String>(
              color: darkGreen2,
              icon: const Icon(Icons.more_horiz, color: Colors.white54),
              onSelected: (String choice) {
                if (choice == 'Delete') {
                  delete();
                } else if (choice == 'Download') {
                  download(context);
                }
              },
              itemBuilder: (BuildContext context) {
                return <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'Delete',
                    child: Text(
                      'Delete',
                      style: subTextDecoration,
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'Download',
                    child: Text(
                      'Download',
                      style: subTextDecoration,
                    ),
                  ),
                ];
              },
            ),
          ],
        ),
      ),
    );
  }

  open() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ViewModel(
              entry: widget.entry,
              refresher: widget.refresher,
            )));
  }

  var textDecoration = const TextStyle(
    fontSize: 18,
    color: Colors.white,
    fontWeight: FontWeight.w600,
  );

  var subTextDecoration = const TextStyle(
    fontSize: 14,
    color: Colors.white70,
    fontWeight: FontWeight.w400,
  );

  delete() async {
    var db = EntryDBProvider.db;
    db.deleteEntry(widget.entry.id!.toInt());
    widget.refresher();
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
