import 'dart:io';

import 'package:flasktest/imagwDisplay.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

void main() {
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  File image;
  final picker = ImagePicker();
  bool _isuploading = false;
  String url = "";

  Future<PickedFile> getImage() async {
    var pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        image = File(pickedFile.path);
      } else {
        print("nothing is selected");
      }
    });
    return pickedFile;
  }

  Future webApi(
    File image,
  ) async {
    setState(() {
      _isuploading = true;
    });
    Uri apiUrl = Uri.parse('http://vidflask.herokuapp.com/save');

    final mimeTypeData =
        lookupMimeType(image.path.toString(), headerBytes: [0xFF, 0xD8])
            .split('/');

    // Intilize the multipart request
    final imageUploadRequest = http.MultipartRequest('POST', apiUrl);

    // Attach the file in the request
    final file = await http.MultipartFile.fromPath(
        'file', image.path.toString(),
        contentType: MediaType(mimeTypeData[0], mimeTypeData[1]));
    imageUploadRequest.files.add(file);
    // imageUploadRequest.fields["username"] = _controller.text.trim();

    // print(imageUploadRequest);

    try {
      final streamedResponse = await imageUploadRequest.send();
      final response = await http.Response.fromStream(streamedResponse);
      // print(response.body);
      setState(() {
        _isuploading = false;
      });
      print(response.body);
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return ImageDisplay(
          imageUrl: response.body.toString(),
        );
      }));
      return response.body;
    } catch (e) {
      print(e);
      setState(() {
        _isuploading = false;
      });
      return e;
    }
  }

  // Future getImages(String name) async {}

  TextEditingController _controller = TextEditingController();
  bool uploading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Text(image != null ? "send" : "Select Image"),
        onPressed: () {
          image == null
              ? print("select image")
              : webApi(image).then((value) {
                  print(value);
                });
        },
      ),
      body: _isuploading
          ? Center(
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Uploading..."),
                CircularProgressIndicator(),
              ],
            ))
          : SingleChildScrollView(
              child: SafeArea(
                child: Container(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.3,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            keyboardType: TextInputType.number,
                            controller: _controller,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.phone_android),
                              border: OutlineInputBorder(gapPadding: 20),
                              labelText: "Enter Id",
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: RaisedButton(
                            child: Text("PickUp Image"),
                            onPressed: () {
                              getImage().then((value) {
                                print(value.path);
                                // webApi(File(value.path)).then((value) {
                                //   print(value);
                                // });
                              });
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            child: image != null
                                ? Image.file(
                                    image,
                                    scale: 0.2,
                                  )
                                : Text("No Image Is selected"),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
