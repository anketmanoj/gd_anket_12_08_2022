import 'package:diamon_rose_app/services/PurchaseCaratsModel.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:flutter/material.dart';

class BuyCaratScreen extends StatelessWidget {
  BuyCaratScreen({Key? key}) : super(key: key);

  final List<PurchaseCarats> carats = [
    PurchaseCarats(price: 1.99, name: "1 Carat"),
    PurchaseCarats(price: 6.99, name: "5 Carats"),
    PurchaseCarats(price: 12.99, name: "10 Carats"),
    PurchaseCarats(price: 38.99, name: "30 Carats"),
    PurchaseCarats(price: 64.99, name: "50 Carats"),
    PurchaseCarats(price: 129.99, name: "100 Carats"),
    PurchaseCarats(price: 249.99, name: "200 Carats"),
    PurchaseCarats(price: 349.99, name: "300 Carats"),
    PurchaseCarats(price: 599.99, name: "500 Carats"),
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
