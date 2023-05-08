// ignore_for_file: use_build_context_synchronously
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:hotelapp/Utils/global.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'Data/entry.dart';
import 'Services/api.dart';
import 'Services/entryDB.dart';

class NewEntryForm extends StatefulWidget {
  const NewEntryForm({super.key});

  @override
  NewEntryFormState createState() => NewEntryFormState();
}

class NewEntryFormState extends State<NewEntryForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  var isLoading = false;
  var file, imagePath;
  var entry = null;
  dynamic _validationMsg;
  bool removeBG = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkGreen2,
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 0,
        backgroundColor: darkGreen2,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              progress(1),
              const SizedBox(height: 32),
              const Text(
                "Create \n3D Model",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 40,
                  height: 1.25,
                  color: Colors.white,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 32),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(32.0),
                    child: ElevatedButton(
                      style: ButtonStyle(
                        elevation: MaterialStateProperty.all<double>(0),
                        backgroundColor:
                            MaterialStateProperty.all<Color>(darkGreen1),
                        padding: MaterialStateProperty.all<EdgeInsets>(
                            const EdgeInsets.all(0)),
                      ),
                      onPressed: () {
                        pickImage();
                      },
                      child: Container(
                        height: 300,
                        width: double.infinity,
                        child: file == null
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.add_circle_outline,
                                    color: Colors.lightGreen,
                                    size: 64,
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    "Pick Image",
                                    style: TextStyle(
                                        color: Colors.lightGreen, fontSize: 16),
                                  )
                                ],
                              )
                            : Image.file(
                                file,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: nameController,
                    style: formTextDecoration,
                    cursorColor: Colors.lightGreen,
                    decoration: formFieldDecoration("Model Name"),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Row(
                      children: [
                        FlutterSwitch(
                          value: removeBG,
                          width: 52,
                          height: 32,
                          inactiveColor: Colors.white24,
                          activeColor: Colors.lightGreen,
                          onToggle: (val) {
                            setState(() => removeBG = !removeBG);
                          },
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          "Remove Background",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      ],
                    ),
                  ),
                  _validationMsg != null
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 0, 0),
                          child: SizedBox(
                              width: double.infinity,
                              child: Text(
                                _validationMsg,
                                style: const TextStyle(color: Colors.redAccent),
                              )),
                        )
                      : const SizedBox(height: 8),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    height: 64,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: const StadiumBorder()),
                      onPressed: () {
                        if (isLoading == false) {
                          onPressedCreate();
                        }
                      },
                      child: !isLoading
                          ? Text(
                              (removeBG)
                                  ? "Remove Background"
                                  : "Generate Model",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          : Container(
                              height: 24,
                              width: 24,
                              child: const CircularProgressIndicator(
                                color: Colors.black,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  formValidator(String text) async {
    setState(() {
      _validationMsg = null;
    });

    var db = EntryDBProvider.db;
    bool exists = await db.entryExist(text);

    if (imagePath == null) {
      setState(() {
        _validationMsg = "* Pick an image";
      });
      return;
    }

    if (exists) {
      setState(() {
        _validationMsg = "* File name already exists";
      });
      return;
    }

    if (text == null || text.isEmpty) {
      setState(() {
        _validationMsg = "* This is a required Field";
      });
      return;
    }
  }

  var formTextDecoration = const TextStyle(
    fontSize: 16,
    color: Colors.white,
    fontWeight: FontWeight.w500,
  );

  formFieldDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0)),
      labelStyle: const TextStyle(
        color: Colors.white60,
      ),
      filled: true,
      focusColor: Colors.lightGreen,
      fillColor: darkGreen1,
    );
  }

  onPressedCreate() async {
    setState(() {
      isLoading = true;
    });

    await formValidator(nameController.text);

    if (_validationMsg == null) {
      Entry newEntry = Entry();
      newEntry.name = nameController.text;
      newEntry.photo = imagePath;

      if(removeBG) {
        newEntry.no_bg =
          await Api.removebg(imagePath, newEntry.name.replaceAll(' ', '_'));
      } else {
        await Future<void>.delayed(const Duration(seconds: 1));
        newEntry.no_bg = imagePath;
      }
      
      entry = newEntry;

      setState(() {
        isLoading = false;
      });

      if (newEntry.no_bg != null) {
        if (removeBG) {
          Navigator.push(
            context,
            PageTransition(
              child: GenerateModel(entry: entry),
              type: PageTransitionType.rightToLeft,
              duration: Duration(milliseconds: 200),
            ));
        } else {
          Navigator.push(
            context,
            PageTransition(
              child: Generating(entry: entry),
              type: PageTransitionType.rightToLeft,
              duration: Duration(milliseconds: 200),
            ));
        }
        
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  Future pickImage() async {
    final XFile? pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        file = File(pickedFile.path);
        imagePath = file.path;
        print(imagePath);
      });
    }
  }
}

class GenerateModel extends StatefulWidget {
  final Entry entry;
  const GenerateModel({super.key, required this.entry});

  @override
  State<GenerateModel> createState() => _GenerateModelState();
}

class _GenerateModelState extends State<GenerateModel> {
  var isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkGreen2,
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 0,
        backgroundColor: darkGreen2,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              progress(2),
              const SizedBox(height: 32),
              const Text(
                "View Image",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 40,
                  height: 1.25,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                height: 300,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32.0),
                  child: Image.file(
                    File(widget.entry.no_bg),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 36),
              Container(
                width: double.infinity,
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
                  onPressed: () {
                    if (isLoading == false) {
                      onPressedGenerate();
                    }
                  },
                  child: !isLoading
                      ? const Text(
                          "Generate 3D Model",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : Container(
                          height: 24,
                          width: 24,
                          child: const CircularProgressIndicator(
                            color: Colors.black,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  onPressedGenerate() async {
    setState(() {
      isLoading = true;
    });

    await Future<void>.delayed(const Duration(seconds: 1));

    setState(() {
      isLoading = false;
    });

    Navigator.push(
        context,
        PageTransition(
          child: Generating(entry: widget.entry),
          type: PageTransitionType.rightToLeft,
          duration: Duration(milliseconds: 200),
        ));
  }
}

class Generating extends StatefulWidget {
  final Entry entry;
  const Generating({super.key, required this.entry});

  @override
  State<Generating> createState() => _GeneratingState();
}

class _GeneratingState extends State<Generating> {
  @override
  void initState() {
    super.initState();
    generateModel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkGreen2,
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 0,
        backgroundColor: darkGreen2,
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        child: Column(
          children: [
            progress(3),
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/generate.png",
                    height: 264,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 32),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 24),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: const LinearProgressIndicator(
                        backgroundColor: Colors.white30,
                        valueColor: AlwaysStoppedAnimation(Colors.lightGreen),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const Text(
                    "Hang on while we generate your model.\nThis might take a while.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      height: 1.5,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  generateModel() async {
    widget.entry.model = await Api.generateModel(
        widget.entry.no_bg, widget.entry.name.replaceAll(' ', '_'));

    var db = EntryDBProvider.db;
    db.newEntry(widget.entry);

    Navigator.of(context)
        .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
  }
}

progress(int stepNo) {
  var height = 4.0;

  return Row(
    children: [
      Expanded(
        flex: 1,
        child: Container(
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            color: stepNo > 0 ? Colors.lightGreen : Colors.white38,
          ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        flex: 1,
        child: Container(
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            color: stepNo > 1 ? Colors.lightGreen : Colors.white38,
          ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        flex: 1,
        child: Container(
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            color: stepNo > 2 ? Colors.lightGreen : Colors.white38,
          ),
        ),
      ),
    ],
  );
}
