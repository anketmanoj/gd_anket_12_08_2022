import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UrlImage extends StatelessWidget {
  UrlImage(
      {Key? key,
      required this.width,
      required this.height,
      required this.imageURL})
      : super(key: key);

  final double width, height;
  final String imageURL;

  @override
  Widget build(BuildContext context) {
    return FadeInImage.memoryNetwork(
      width: width,
      height: height,
      imageCacheWidth: width ~/
          1, // Used to set cache width as Widget size to avoid decode large image
      fit: BoxFit.cover,
      placeholder:
          kTransparentImage, // Transparent placeholder while loading image
      image: imageURL,
      imageErrorBuilder: (context, error, stacktrace) {
        // Handle error multiple time when first try is error
        return FadeInImage.memoryNetwork(
          width: width,
          height: height,
          imageCacheWidth: width ~/ 1,
          fit: BoxFit.cover,
          placeholder: kTransparentImage,
          image: imageURL,
          imageErrorBuilder: (context, error, stacktrace) {
            return FadeInImage.memoryNetwork(
              width: width,
              height: height,
              imageCacheWidth: width ~/ 1,
              fit: BoxFit.cover,
              placeholder: kTransparentImage,
              image: imageURL,
              imageErrorBuilder: (context, error, stacktrace) {
                return Center(child: Text('Image Not Available'));
              },
            );
          },
        );
      },
    );
  }
}

final Uint8List kTransparentImage = new Uint8List.fromList(<int>[
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0A,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
]);
