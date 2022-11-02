import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diamon_rose_app/services/FirebaseOperations.dart';
import 'package:diamon_rose_app/services/payoutRequestModel.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:flutter/material.dart';

class PayoutScreen extends StatelessWidget {
  PayoutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: constantColors.whiteColor,
      appBar: AppBarWidget(text: "Payout Requests", context: context),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("payoutRequest")
            .orderBy("timestamp", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: Text("All payouts have been completed!"),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(
                        label: Text("Date"),
                      ),
                      DataColumn(
                        label: Text("User ID"),
                      ),
                      DataColumn(
                        label: Text("User Name"),
                      ),
                      DataColumn(
                        label: Text("User Email"),
                      ),
                      DataColumn(
                        label: Text("Paypal Link"),
                      ),
                      DataColumn(
                        label: Text("Transfer Amount"),
                      ),
                      DataColumn(
                        label: Text("Total Generated"),
                      ),
                      DataColumn(
                        label: Text("Transferred"),
                      ),
                    ],
                    rows: snapshot.data!.docs.map(
                      (data) {
                        PayoutRequestModel payoutData =
                            PayoutRequestModel.fromJson(
                                data.data() as Map<String, dynamic>);
                        return DataRow(
                          cells: [
                            DataCell(
                              Text(
                                payoutData.timestamp
                                    .toDate()
                                    .toString()
                                    .substring(0, 10),
                              ),
                            ),
                            DataCell(
                              Text(payoutData.userUid),
                            ),
                            DataCell(
                              Text(payoutData.username),
                            ),
                            DataCell(
                              Text(payoutData.useremail),
                            ),
                            DataCell(
                              Text(payoutData.paypalLink),
                            ),
                            DataCell(
                              Text(payoutData.amountToTransfer),
                            ),
                            DataCell(
                              Text(payoutData.totalGeneratedForGd),
                            ),
                            DataCell(
                              Switch(
                                value: payoutData.transferred,
                                onChanged: (value) async {
                                  showAlertDialog(
                                    context: context,
                                    amount:
                                        int.parse(payoutData.amountToTransfer),
                                    username: payoutData.username,
                                    useruid: payoutData.userUid,
                                    value: value,
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ).toList(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  final FirebaseOperations firebaseService = FirebaseOperations();

  showAlertDialog({
    required BuildContext context,
    required int amount,
    required String username,
    required String useruid,
    required bool value,
  }) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("YES"),
      onPressed: () async {
        await firebaseService.transferredAmountTrue(
            useruid: useruid, value: value, amount: amount);

        Navigator.pop(context);
      },
    );
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Payment Confirmation"),
      content: Text(
          "Please Click 'YES' to confirm that you've transferred \$$amount to $username"),
      actions: [
        okButton,
        cancelButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
