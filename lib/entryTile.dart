import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
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
    return InkWell(
      onTap: () => open(),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: darkGreen1,
          borderRadius: BorderRadius.circular(24),
        ),
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
                      onPressed: () {},
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
                  download();
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

  delete() async{
    var db = EntryDBProvider.db;
    db.deleteEntry(widget.entry.id!.toInt());
    widget.refresher();
  }

  download() {
    print("Download");
  }

  open() {
    print("Open");
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
}
