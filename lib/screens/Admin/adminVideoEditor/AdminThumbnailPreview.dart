import 'dart:typed_data';

import 'package:diamon_rose_app/providers/video_editor_provider.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class AdminThumbnailPreview extends StatelessWidget {
  const AdminThumbnailPreview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(text: "Thumbnail Preview", context: context),
      backgroundColor: constantColors.whiteColor,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Center(
              child: Container(
                height: 40.h,
                width: 80.w,
                child: Image.memory(
                  Uint8List.fromList(
                    context
                        .read<VideoEditorProvider>()
                        .getCoverGif
                        .readAsBytesSync(),
                  ),
                  alignment: Alignment.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
