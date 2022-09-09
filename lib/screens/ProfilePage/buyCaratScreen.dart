import 'package:diamon_rose_app/services/PurchaseCaratsModel.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

class BuyCaratScreen extends StatelessWidget {
  BuyCaratScreen({Key? key}) : super(key: key);

  final List<PurchaseCarats> carats = [
    PurchaseCarats(price: 1.99, name: "1 Carat"),
    PurchaseCarats(price: 7.99, name: "5 Carats"),
    PurchaseCarats(price: 13.99, name: "10 Carats"),
    PurchaseCarats(price: 39.99, name: "30 Carats"),
    PurchaseCarats(price: 74.99, name: "50 Carats"),
    PurchaseCarats(price: 149.99, name: "100 Carats"),
    PurchaseCarats(price: 299.99, name: "200 Carats"),
    PurchaseCarats(price: 399.99, name: "300 Carats"),
    PurchaseCarats(price: 699.99, name: "500 Carats"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: constantColors.whiteColor,
      appBar: AppBarWidget(text: "Collect Carats", context: context),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: 9,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                onTap: () {
                  Get.bottomSheet(
                    Container(
                      height: 25.h,
                      width: 100.w,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: constantColors.navButton,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 150),
                            child: Divider(
                              thickness: 4,
                              color: constantColors.whiteColor,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Container(
                              height: 50,
                              width: 100.w,
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  foregroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.white),
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          constantColors.bioBg),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  Get.dialog(
                                    SimpleDialog(
                                      backgroundColor:
                                          constantColors.whiteColor,
                                      title: Text(
                                        "Pending in-app purchase approval",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: constantColors.black,
                                        ),
                                      ),
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Text(
                                            "We've submitted our in-app purchase approval request for all the Carat tiers shown",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: constantColors.black),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(10),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: ElevatedButton(
                                                  style: ButtonStyle(
                                                    foregroundColor:
                                                        MaterialStateProperty
                                                            .all<Color>(
                                                                Colors.white),
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .all<Color>(
                                                                constantColors
                                                                    .navButton),
                                                    shape: MaterialStateProperty
                                                        .all<
                                                            RoundedRectangleBorder>(
                                                      RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                      ),
                                                    ),
                                                  ),
                                                  onPressed: Get.back,
                                                  child: Text(
                                                    "Understood!",
                                                    style:
                                                        TextStyle(fontSize: 12),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Expanded(
                                                child: ElevatedButton(
                                                  style: ButtonStyle(
                                                    foregroundColor:
                                                        MaterialStateProperty
                                                            .all<Color>(
                                                                Colors.white),
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .all<Color>(
                                                                constantColors
                                                                    .navButton),
                                                    shape: MaterialStateProperty
                                                        .all<
                                                            RoundedRectangleBorder>(
                                                      RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                      ),
                                                    ),
                                                  ),
                                                  onPressed: Get.back,
                                                  child: Text(
                                                    "View Items",
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    barrierDismissible: false,
                                  );
                                },
                                child: Text(
                                  "Apple App Store",
                                  style: TextStyle(
                                    color: constantColors.navButton,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Container(
                              height: 50,
                              width: 100.w,
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  foregroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.white),
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          constantColors.bioBg),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ),
                                onPressed: () async {},
                                child: Text(
                                  "Glamorous Diastation Direct Payment",
                                  style: TextStyle(
                                    color: constantColors.navButton,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                leading: Image.asset("assets/carats/${index}.png"),
                title: Text(carats[index].name),
                trailing: Text("\$${carats[index].price}"),
              ),
            );
          },
        ),
      ),
    );
  }
}
