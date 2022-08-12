import 'package:diamon_rose_app/constants/styles/colors.dart';
import 'package:diamon_rose_app/widgets/shimmer_custom.dart';
import 'package:flutter/material.dart';

class ImagePlaceholderWidget extends StatelessWidget {
  const ImagePlaceholderWidget({
    Key? key,
    required this.url,
    this.placeholderHeight = 150,
    this.placeholderWidth = 100,
    this.highlightColor,
    this.baseColor,
    this.fit = BoxFit.fill,
  }) : super(key: key);

  final String url;
  final double placeholderHeight;
  final double placeholderWidth;
  final Color? highlightColor;
  final Color? baseColor;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      errorBuilder: (_, __, ___) {
        return Center(
          child: Container(
            height: 50,
            width: 50,
            color: AppColors.grey,
            child: Icon(Icons.error_outline, size: 10),
          ),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        return loadingProgress == null
            ? child
            : ShimmerCustom(
                highlightColor: highlightColor,
                baseColor: baseColor,
                child: Container(
                    color: AppColors.black,
                    height: placeholderHeight,
                    width: placeholderWidth));
      },
    );
  }
}
