import 'package:diamon_rose_app/screens/testVideoEditor/TrimVideo/domain/entities/transform_data.dart';
import 'package:flutter/material.dart';

class CropTransform extends StatelessWidget {
  const CropTransform({
    Key? key,
    required this.transform,
    required this.child,
  }) : super(key: key);

  final Widget child;
  final TransformData transform;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: Transform.rotate(
        angle: transform.rotation,
        child: Transform.scale(
          scale: transform.scale,
          child: Transform.translate(
            offset: transform.translate,
            child: child,
          ),
        ),
      ),
    );
  }
}
