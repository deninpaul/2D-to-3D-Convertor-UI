import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'Utils/global.dart';
import 'package:hotelapp/newDialog.dart';
import 'Services/entryDB.dart';
import 'entryTile.dart';

class Entry extends StatefulWidget {
  const Entry({super.key});

  @override
  State<Entry> createState() => _EntryState();
}

class _EntryState extends State<Entry> {
  @override
  void initState() {
    super.initState();
    requestPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: darkGreen2,
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 0,
        backgroundColor: darkGreen2,
      ),
      body: RefreshIndicator(
        onRefresh: refresher,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: FutureBuilder(
            future: EntryDBProvider.db.getAllEntry(),
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.data != null) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    const Text('2D to 3D \nConvertor',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                          color: Colors.white,
                        )),
                    const SizedBox(height: 24),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index) {
                        return EntryTile(
                          entry: snapshot.data[index],
                          refresher: () => refresher(),
                        );
                      },
                    ),
                    const SizedBox(height: 140),
                  ],
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: customFAB(context),
      bottomNavigationBar: const BottomAppBar(
        color: Color.fromARGB(255, 41, 47, 39),
        height: 64,
        shape: CircularNotchedRectangle(),
        notchMargin: 12,
        elevation: 12,
      ),
    );
  }

  Future refresher() async {
    setState(() {
      EntryDBProvider.db.getAllEntry();
    });
    return Future<void>.delayed(const Duration(seconds: 1));
  }

  customFAB(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => NewEntryForm())),
      child: const Icon(
        Icons.add,
        size: 32,
      ),
    );
  }

  Future<void> requestPermissions() async {
  final PermissionStatus status = await Permission.storage.request();
  if (status != PermissionStatus.granted) {
    throw Exception('Permission denied');
  }
}
}
