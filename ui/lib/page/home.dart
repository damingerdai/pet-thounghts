import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pet_thounghts_ui/config/config.dart';
import 'package:pet_thounghts_ui/model/reponse.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? message = null;
  PlatformFile? selectedFile = null;

  selectFile() async {
    setState(() {
      message = null;
      selectedFile = null;
    });
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() {
        selectedFile = result.files.first;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagePlacholder = message != null
        ? Text(
            message!,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
            ),
          )
        : Container();

    final imagePlaceholder = AspectRatio(
      aspectRatio: 3 / 2,
      child: Container(
          decoration: BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.add_a_photo_outlined,
            size: 56,
            color: Colors.black26,
          )),
    );

    final imagePlaceholderMask = Positioned.fill(
      child: InkWell(
          borderRadius: BorderRadius.circular(20),
          splashColor: Colors.deepOrangeAccent.withOpacity(0.3),
          onTap: selectFile),
    );

    final selectedImage = selectedFile != null
        ? ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(
              File(selectedFile!.path!),
              fit: BoxFit.cover,
            ))
        : Container(); // Provide a non-null value when selectFile is null

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title, style: const TextStyle(fontSize: 16), textAlign: TextAlign.center),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'I know what your pet is thinking!',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 24),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  imagePlaceholder,
                  imagePlaceholderMask,
                  if (selectedFile != null) selectedImage
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(40),
                ),
                onPressed: selectFile,
                child: const Text("Select File"),
              ),
            ),
            messagePlacholder,
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
              child: FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(40),
                ),
                onPressed: () async {
                  Dio dio = Dio();
                  FormData formData = FormData.fromMap({
                    "file": await MultipartFile.fromFile(selectedFile!.path!),
                  });
                  var res = await dio.post(
                      "${AppConfig.apiBaseUrl}/file/upload",
                      data: formData);

                  if (res.statusCode == 200) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("File uploaded successfully"),
                      ),
                    );
                    var message = CommonReponse.fromJson(res.data).message;
                    setState(() {
                      this.message = message;
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("File upload failed"),
                      ),
                    );
                  }
                },
                child: const Text("Publish"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
