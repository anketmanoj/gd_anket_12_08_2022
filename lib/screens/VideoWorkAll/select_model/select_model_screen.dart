import 'package:diamon_rose_app/Navigation/page.dart';
import 'package:diamon_rose_app/constants/styles/colors.dart';
import 'package:diamon_rose_app/constants/styles/style.dart';
import 'package:diamon_rose_app/screens/VideoWorkAll/select_model/select_model_view_model.dart';

import 'package:diamon_rose_app/widgets/button_action.dart';
import 'package:diamon_rose_app/widgets/custom_scaffold.dart';
import 'package:diamon_rose_app/widgets/utils.dart';
import 'package:diamon_rose_app/widgets/widgets.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;

class SelectModelScreen extends GetView<SelectModelPresenter> {
  final _controller = Get.put(SelectModelPresenter());

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      enableSingleScrollView: false,
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) => SafeArea(
        child: Column(
          children: [
            Container(
              alignment: Alignment.center,
              height: 50,
              width: MediaQuery.of(context).size.width,
              child: Text(
                "title",
                style: TextStyle(fontSize: 16, color: AppColors.white),
              ),
            ),
            Expanded(
              child: Container(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ButtonAction(
                        content: "record now",
                        action: () => goTo(screen: ROUTER_CREATE_VIDEO_CAMERA),
                        textStyle:
                            AppStyles.typeTextNormal(color: AppColors.white),
                        color: AppColors.black,
                      ),
                      heightSpace(19),
                      ButtonAction(
                        content: "labeled video",
                        action: _controller.openVideoGallery.call,
                        textStyle:
                            AppStyles.typeTextNormal(color: AppColors.white),
                        color: AppColors.purple02,
                      ),
                      heightSpace(19),
                      ButtonAction(
                        content: "labeled video",
                        action: () => goTo(screen: ROUTER_CREATE_VIDEO),
                        textStyle: AppStyles.typeTextNormal(),
                        color: AppColors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}
