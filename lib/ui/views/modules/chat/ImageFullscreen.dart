import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';


class ImageFullscreen extends StatelessWidget {
  final String url;
  ImageFullscreen(this.url);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () async {
              Navigator.of(context).pop();
            }),
      ),
      body: Container(
          child: PhotoView(
              imageProvider: NetworkImage(url)
          )
      ),
    );
  }
}