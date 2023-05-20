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
      bottomNavigationBar: BottomAppBar(
        color: Color.fromARGB(255, 41, 47, 39),
        height: 64,
        shape: CircularNotchedRectangle(),
        notchMargin: 12,
        elevation: 12,
        child: Container(
          alignment: Alignment.centerRight,
          child: IconButton(
            onPressed: () => modelSheet(),
            icon: const Icon(
              Icons.more_vert_outlined,
              color: Colors.lightGreen,
            ),
          ),
        ),
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

  modelSheet() {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Settings(),
        );
      },
    );
  }
}

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  TextEditingController urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    urlController.text = apiURL;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: darkGreen2,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "API Source:",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextButton(
                  child: Text("Reset"),
                  onPressed: () => setState(() {
                    urlController.text = azureURL;
                  }),
                ),
              ],
            ),
          ),
          TextField(
            controller: urlController,
            style: formTextDecoration,
            cursorColor: Colors.lightGreen,
            decoration: formFieldDecoration("Model Name"),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
              onPressed: () {
                apiURL = urlController.text;
                Navigator.of(context).pop();
              },
              child: const Text(
                "Save",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  formFieldDecoration(String labelText) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0)),
      filled: true,
      focusColor: Colors.lightGreen,
      fillColor: darkGreen1,
    );
  }

  var formTextDecoration = const TextStyle(
    fontSize: 16,
    color: Colors.white,
    fontWeight: FontWeight.w500,
  );
}
