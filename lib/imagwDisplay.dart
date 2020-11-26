import 'package:flutter/material.dart';

class ImageDisplay extends StatelessWidget {
  final String imageUrl;
  ImageDisplay({this.imageUrl});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.15,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Text(imageUrl),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.1,
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.4,
                width: MediaQuery.of(context).size.width * 0.8,
                child: Image.network(
                  imageUrl,
                  // scale: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
