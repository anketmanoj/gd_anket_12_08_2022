import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:diamon_rose_app/providers/caratsProvider.dart';
import 'package:diamon_rose_app/screens/ProfilePage/consumableStore.dart';
import 'package:diamon_rose_app/services/FirebaseOperations.dart';
import 'package:diamon_rose_app/services/PurchaseCaratsModel.dart';
import 'package:diamon_rose_app/services/authentication.dart';
import 'package:diamon_rose_app/services/shared_preferences_helper.dart';
import 'package:diamon_rose_app/translations/locale_keys.g.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class BuyCaratScreen extends StatefulWidget {
  BuyCaratScreen({Key? key, this.showAppBar = true}) : super(key: key);
  final bool showAppBar;

  @override
  State<BuyCaratScreen> createState() => _BuyCaratScreenState();
}

class _BuyCaratScreenState extends State<BuyCaratScreen> {
  final GlobalKey webViewKey = GlobalKey();
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  List<String> _notFoundIds = <String>[];
  List<ProductDetails> _products = <ProductDetails>[];
  List<PurchaseDetails> _purchases = <PurchaseDetails>[];
  List<String> _consumables = <String>[];
  bool _isAvailable = true;
  bool _purchasePending = false;
  bool _loading = true;
  String? _queryProductError;

  Card _buildConnectionCheckTile() {
    if (_loading) {
      return const Card(child: ListTile(title: Text('Trying to connect...')));
    }
    final Widget storeHeader = ListTile(
      leading: Icon(_isAvailable ? Icons.check : Icons.block,
          color: _isAvailable
              ? Colors.green
              : ThemeData.light().colorScheme.error),
      title:
          Text('The store is ${_isAvailable ? 'available' : 'unavailable'}.'),
    );
    final List<Widget> children = <Widget>[storeHeader];

    if (!_isAvailable) {
      children.addAll(<Widget>[
        const Divider(),
        ListTile(
          title: Text('Not connected',
              style: TextStyle(color: ThemeData.light().colorScheme.error)),
          subtitle: const Text(
              'Unable to connect to the payments processor. Has this app been configured correctly? See the example README for instructions.'),
        ),
      ]);
    }
    return Card(child: Column(children: children));
  }

  Card _buildProductList(BuildContext context) {
    if (_loading) {
      return const Card(
          child: ListTile(
              leading: CircularProgressIndicator(),
              title: Text('Fetching products...')));
    }
    if (!_isAvailable) {
      return Card(
          child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
                "Error Getting Products from ${Platform.isIOS ? 'Apple App Store' : 'Google Play Store'}"),
            ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => this.widget));
                },
                child: Text("Retry")),
          ],
        ),
      ));
    }
    const ListTile productHeader = ListTile(title: Text('Products for Sale'));
    final List<ListTile> productList = <ListTile>[];
    if (_notFoundIds.isNotEmpty) {
      productList.add(ListTile(
          title: Text('[${_notFoundIds.join(", ")}] not found',
              style: TextStyle(color: ThemeData.light().colorScheme.error)),
          subtitle: const Text(
              'This app needs special configuration to run. Please see example/README.md for instructions.')));
    }

    // This loading previous purchases code is just a demo. Please do not use this as it is.
    // In your app you should always verify the purchase data using the `verificationData` inside the [PurchaseDetails] object before trusting it.
    // We recommend that you use your own server to verify the purchase data.
    final Map<String, PurchaseDetails> purchases =
        Map<String, PurchaseDetails>.fromEntries(
            _purchases.map((PurchaseDetails purchase) {
      if (purchase.pendingCompletePurchase) {
        _inAppPurchase.completePurchase(purchase);
      }
      return MapEntry<String, PurchaseDetails>(purchase.productID, purchase);
    }));
    _products.sort(((a, b) => a.rawPrice.compareTo(b.rawPrice)));

    productList.addAll(_products.map(
      (ProductDetails productDetails) {
        final PurchaseDetails? previousPurchase = purchases[productDetails.id];
        return ListTile(
          minVerticalPadding: 25,
          onTap: () {
            // Get.back();
            late PurchaseParam purchaseParam;

            if (Platform.isAndroid) {
              // NOTE: If you are making a subscription purchase/upgrade/downgrade, we recommend you to
              // verify the latest status of you your subscription by using server side receipt validation
              // and update the UI accordingly. The subscription purchase status shown
              // inside the app may not be accurate.
              final GooglePlayPurchaseDetails? oldSubscription =
                  _getOldSubscription(productDetails, purchases);

              purchaseParam = GooglePlayPurchaseParam(
                  productDetails: productDetails,
                  changeSubscriptionParam: (oldSubscription != null)
                      ? ChangeSubscriptionParam(
                          oldPurchaseDetails: oldSubscription,
                          prorationMode:
                              ProrationMode.immediateWithTimeProration,
                        )
                      : null);
            } else {
              purchaseParam = PurchaseParam(
                productDetails: productDetails,
              );
            }

            if (productDetails.id == kConsumableId0) {
              _inAppPurchase.buyConsumable(
                  purchaseParam: purchaseParam, autoConsume: kAutoConsume);
            } else {
              _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
            }
            // Get.bottomSheet(
            //   Container(
            //     height: 30.h,
            //     width: 100.w,
            //     padding: EdgeInsets.all(10),
            //     decoration: BoxDecoration(
            //       color: constantColors.navButton,
            //       borderRadius: BorderRadius.only(
            //         topLeft: Radius.circular(20),
            //         topRight: Radius.circular(20),
            //       ),
            //     ),
            //     child: Column(
            //       children: [
            //         Padding(
            //           padding: const EdgeInsets.symmetric(horizontal: 150),
            //           child: Divider(
            //             thickness: 4,
            //             color: constantColors.whiteColor,
            //           ),
            //         ),
            //         Padding(
            //           padding: const EdgeInsets.only(top: 10),
            //           child: Text(
            //             "Purchase ${productDetails.id.split("_")[2]} Carats",
            //             style: TextStyle(
            //               color: constantColors.bioBg,
            //               fontSize: 16,
            //             ),
            //           ),
            //         ),
            //         Padding(
            //           padding: const EdgeInsets.only(top: 20),
            //           child: Container(
            //             height: 50,
            //             width: 100.w,
            //             child: ElevatedButton(
            //               style: ButtonStyle(
            //                 foregroundColor:
            //                     MaterialStateProperty.all<Color>(Colors.white),
            //                 backgroundColor: MaterialStateProperty.all<Color>(
            //                     constantColors.bioBg),
            //                 shape: MaterialStateProperty.all<
            //                     RoundedRectangleBorder>(
            //                   RoundedRectangleBorder(
            //                     borderRadius: BorderRadius.circular(20),
            //                   ),
            //                 ),
            //               ),
            //               onPressed: () {
            //                 Get.back();
            //                 late PurchaseParam purchaseParam;

            //                 if (Platform.isAndroid) {
            //                   // NOTE: If you are making a subscription purchase/upgrade/downgrade, we recommend you to
            //                   // verify the latest status of you your subscription by using server side receipt validation
            //                   // and update the UI accordingly. The subscription purchase status shown
            //                   // inside the app may not be accurate.
            //                   final GooglePlayPurchaseDetails? oldSubscription =
            //                       _getOldSubscription(
            //                           productDetails, purchases);

            //                   purchaseParam = GooglePlayPurchaseParam(
            //                       productDetails: productDetails,
            //                       changeSubscriptionParam: (oldSubscription !=
            //                               null)
            //                           ? ChangeSubscriptionParam(
            //                               oldPurchaseDetails: oldSubscription,
            //                               prorationMode: ProrationMode
            //                                   .immediateWithTimeProration,
            //                             )
            //                           : null);
            //                 } else {
            //                   purchaseParam = PurchaseParam(
            //                     productDetails: productDetails,
            //                   );
            //                 }

            //                 if (productDetails.id == _kConsumableId0) {
            //                   _inAppPurchase.buyConsumable(
            //                       purchaseParam: purchaseParam,
            //                       autoConsume: _kAutoConsume);
            //                 } else {
            //                   _inAppPurchase.buyNonConsumable(
            //                       purchaseParam: purchaseParam);
            //                 }
            //               },
            //               child: Text(
            //                 "Apple App Store",
            //                 style: TextStyle(
            //                   color: constantColors.navButton,
            //                 ),
            //               ),
            //             ),
            //           ),
            //         ),
            //         Padding(
            //           padding: const EdgeInsets.only(top: 20),
            //           child: Container(
            //             height: 50,
            //             width: 100.w,
            //             child: ElevatedButton(
            //               style: ButtonStyle(
            //                 foregroundColor:
            //                     MaterialStateProperty.all<Color>(Colors.white),
            //                 backgroundColor: MaterialStateProperty.all<Color>(
            //                     constantColors.bioBg),
            //                 shape: MaterialStateProperty.all<
            //                     RoundedRectangleBorder>(
            //                   RoundedRectangleBorder(
            //                     borderRadius: BorderRadius.circular(20),
            //                   ),
            //                 ),
            //               ),
            //               onPressed: () {
            //                 final String paymentUrl =
            //                     "https://gdfe-ac584.firebaseapp.com/#/payment/${productDetails.id.split("_")[2]}";
            //                 log("price = ${productDetails.id.split("_")[2]}");
            //                 log(paymentUrl);
            //                 ViewMenuWebApp(
            //                     caratValue:
            //                         int.parse(productDetails.id.split("_")[2]),
            //                     context: context,
            //                     menuUrl: paymentUrl,
            //                     auth: context.read<Authentication>(),
            //                     firebaseOperations:
            //                         context.read<FirebaseOperations>(),
            //                     key: webViewKey);
            //               },
            //               child: Text(
            //                 "Glamorous Diastation Direct Payment",
            //                 style: TextStyle(
            //                   color: constantColors.navButton,
            //                 ),
            //               ),
            //             ),
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // );
          },
          leading: Image.asset(
              "assets/carats/${productDetails.id.split("_")[2]}.png"),
          title: Text(
            "${productDetails.id.split("_")[2]} Carats",
          ),
          trailing: Text(productDetails.price),
        );
      },
    ));

    return Card(child: Column(children: productList), elevation: 0);
  }

  Card _buildConsumableBox() {
    if (_loading) {
      return const Card(
          child: ListTile(
              leading: CircularProgressIndicator(),
              title: Text('Fetching consumables...')));
    }
    if (!_isAvailable || _notFoundIds.contains(kConsumableId0)) {
      return Card(
          child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
                "Error Getting Products from ${Platform.isIOS ? 'Apple App Store' : 'Google Play Store'}"),
            ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => this.widget));
                },
                child: Text("Retry")),
          ],
        ),
      ));
    }
    const ListTile consumableHeader =
        ListTile(title: Text('Purchased consumables'));
    final List<Widget> tokens = _consumables.map((String id) {
      return GridTile(
        child: IconButton(
          icon: const Icon(
            Icons.stars,
            size: 42.0,
            color: Colors.orange,
          ),
          splashColor: Colors.yellowAccent,
          onPressed: () => consume(id),
        ),
      );
    }).toList();
    return Card(
        child: Column(children: <Widget>[
      consumableHeader,
      const Divider(),
      GridView.count(
        crossAxisCount: 5,
        shrinkWrap: true,
        padding: const EdgeInsets.all(16.0),
        children: tokens,
      )
    ]));
  }

  Widget _buildRestoreButton() {
    if (_loading) {
      return Container();
    }

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              // TODO(darrenaustin): Migrate to new API once it lands in stable: https://github.com/flutter/flutter/issues/105724
              // ignore: deprecated_member_use
              primary: Colors.white,
            ),
            onPressed: () => _inAppPurchase.restorePurchases(),
            child: const Text('Restore purchases'),
          ),
        ],
      ),
    );
  }

  Future<void> consume(String id) async {
    await ConsumableStore.consume(id);
    final List<String> consumables = await ConsumableStore.load();
    setState(() {
      _consumables = consumables;
    });
  }

  void showPendingUI() {
    setState(() {
      _purchasePending = true;
    });
  }

  Future<void> deliverProduct(PurchaseDetails purchaseDetails) async {
    // IMPORTANT!! Always verify purchase details before delivering the product.
    if (purchaseDetails.productID == kConsumableId0) {
      await ConsumableStore.save(purchaseDetails.purchaseID!);
      final List<String> consumables = await ConsumableStore.load();
      setState(() {
        _purchasePending = false;
        _consumables = consumables;
      });
    } else {
      setState(() {
        _purchases.add(purchaseDetails);
        _purchasePending = false;
      });
    }
  }

  void handleError(IAPError error) {
    setState(() {
      _purchasePending = false;
    });
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) {
    // IMPORTANT!! Always verify a purchase before delivering the product.
    // For the purpose of an example, we directly return true.
    if (purchaseDetails.status == PurchaseStatus.purchased) {
      log("true");
      return Future<bool>.value(true);
    }
    log("false");
    return Future<bool>.value(false);
  }

  void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
    // handle invalid purchase here if  _verifyPurchase` failed.
    setState(() {
      _purchasePending = false;
    });
    log("FAILURE");
  }

  Future<void> _listenToPurchaseUpdated(
      List<PurchaseDetails> purchaseDetailsList,
      CaratProvider caratProvider,
      FirebaseOperations firebaseOperations,
      Authentication authentication) async {
    log("we're here");
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        log("we're pending");
        showPendingUI();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          log("got an error");
          handleError(purchaseDetails.error!);
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          log("we're verifying");
          final bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            log("done verifying");
            deliverProduct(purchaseDetails);
          } else {
            log("invalid purchase");
            _handleInvalidPurchase(purchaseDetails);
            return;
          }
        }
        if (Platform.isAndroid) {
          if (!kAutoConsume && purchaseDetails.productID == kConsumableId0) {
            final InAppPurchaseAndroidPlatformAddition androidAddition =
                _inAppPurchase.getPlatformAddition<
                    InAppPurchaseAndroidPlatformAddition>();
            await androidAddition.consumePurchase(purchaseDetails);
          }
        }
        if (purchaseDetails.pendingCompletePurchase) {
          if (purchaseDetails.status != PurchaseStatus.purchased) {
            await _inAppPurchase.completePurchase(purchaseDetails);
            _handleInvalidPurchase(purchaseDetails);
            return;
          }
          log("Successful! Now just add carats to users profile!");

          caratProvider.setCarats(caratProvider.getCarats +
              int.parse(purchaseDetails.productID.split("_")[2]));

          await firebaseOperations.addCaratsToUser(
            userid: authentication.getUserId,
            caratValue: caratProvider.getCarats,
          );

          log("done setting ${caratProvider.getCarats} to user ${authentication.getUserId}");

          await _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    }
  }

  Future<void> confirmPriceChange(BuildContext context) async {
    if (Platform.isAndroid) {
      final InAppPurchaseAndroidPlatformAddition androidAddition =
          _inAppPurchase
              .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
      final BillingResultWrapper priceChangeConfirmationResult =
          await androidAddition.launchPriceChangeConfirmationFlow(
        sku: 'purchaseId',
      );
      if (priceChangeConfirmationResult.responseCode == BillingResponse.ok) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Price change accepted'),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            priceChangeConfirmationResult.debugMessage ??
                'Price change failed with code ${priceChangeConfirmationResult.responseCode}',
          ),
        ));
      }
    }
    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iapStoreKitPlatformAddition =
          _inAppPurchase
              .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iapStoreKitPlatformAddition.showPriceConsentIfNeeded();
    }
  }

  GooglePlayPurchaseDetails? _getOldSubscription(
      ProductDetails productDetails, Map<String, PurchaseDetails> purchases) {
    // This is just to demonstrate a subscription upgrade or downgrade.
    // This method assumes that you have only 2 subscriptions under a group, 'subscription_silver' & 'subscription_gold'.
    // The 'subscription_silver' subscription can be upgraded to 'subscription_gold' and
    // the 'subscription_gold' subscription can be downgraded to 'subscription_silver'.
    // Please remember to replace the logic of finding the old subscription Id as per your app.
    // The old subscription is only required on Android since Apple handles this internally
    // by using the subscription group feature in iTunesConnect.
    GooglePlayPurchaseDetails? oldSubscription;

    return oldSubscription;
  }

  late CaratProvider caratProvider;
  late FirebaseOperations firebaseOperations;
  late Authentication authentication;

  @override
  void initState() {
    caratProvider = context.read<CaratProvider>();
    final FirebaseOperations firebaseOperations =
        context.read<FirebaseOperations>();
    final Authentication authentication = context.read<Authentication>();
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _inAppPurchase.purchaseStream;
    _subscription =
        purchaseUpdated.listen((List<PurchaseDetails> purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList, caratProvider,
          firebaseOperations, authentication);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (Object error) {
      // handle error here.
    });
    initStoreInfo();
    super.initState();
  }

  Future<void> initStoreInfo() async {
    final bool isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      setState(() {
        _isAvailable = isAvailable;
        _products = <ProductDetails>[];
        _purchases = <PurchaseDetails>[];
        _notFoundIds = <String>[];
        _consumables = <String>[];
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
          _inAppPurchase
              .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iosPlatformAddition.setDelegate(ExamplePaymentQueueDelegate());
    }

    final ProductDetailsResponse productDetailResponse =
        await _inAppPurchase.queryProductDetails(
            Platform.isIOS ? kProductIdiOS : kProductIdAndroid.toSet());
    if (productDetailResponse.error != null) {
      log("anket eeror here == ${productDetailResponse.error!.message}");
      setState(() {
        _queryProductError = productDetailResponse.error!.message;
        _isAvailable = isAvailable;
        _products = productDetailResponse.productDetails;
        _purchases = <PurchaseDetails>[];
        _notFoundIds = productDetailResponse.notFoundIDs;
        _consumables = <String>[];
        _purchasePending = false;
        _loading = false;
      });

      return;
    }

    if (productDetailResponse.productDetails.isEmpty) {
      setState(() {
        _queryProductError = null;
        _isAvailable = isAvailable;
        _products = productDetailResponse.productDetails;
        _purchases = <PurchaseDetails>[];
        _notFoundIds = productDetailResponse.notFoundIDs;
        _consumables = <String>[];
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    final List<String> consumables = await ConsumableStore.load();
    setState(() {
      _isAvailable = isAvailable;
      _products = productDetailResponse.productDetails;
      _notFoundIds = productDetailResponse.notFoundIDs;
      _consumables = consumables;
      _purchasePending = false;
      _loading = false;
    });
  }

  @override
  void dispose() {
    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
          _inAppPurchase
              .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      iosPlatformAddition.setDelegate(null);
    }
    _subscription.cancel();
    super.dispose();
  }

  final List<PurchaseCarats> carats = [
    PurchaseCarats(price: 1.99, name: "1 Carat"),
    PurchaseCarats(price: 7.99, name: "5 Carats"),
    PurchaseCarats(price: 13.99, name: "10 Carats"),
    PurchaseCarats(price: 39.99, name: "30 Carats"),
    PurchaseCarats(price: 74.99, name: "55 Carats"),
    PurchaseCarats(price: 99.99, name: "80 Carats"),
  ];

  @override
  Widget build(BuildContext context) {
    final CaratProvider caratProvider =
        Provider.of<CaratProvider>(context, listen: false);
    final List<Widget> stack = <Widget>[];
    if (_queryProductError == null) {
      stack.add(
        ListView(
          children: <Widget>[
            // _buildConnectionCheckTile(),
            _buildProductList(context),
            // _buildConsumableBox(),
            // _buildRestoreButton(),
          ],
        ),
      );
    } else {
      stack.add(Center(
        child: Text(_queryProductError!),
      ));
    }
    if (_purchasePending) {
      stack.add(
        Stack(
          children: const <Widget>[
            Opacity(
              opacity: 0.3,
              child: ModalBarrier(dismissible: false, color: Colors.grey),
            ),
            Center(
              child: CircularProgressIndicator(),
            ),
          ],
        ),
      );
    }
    return Scaffold(
      backgroundColor: constantColors.whiteColor,
      appBar: widget.showAppBar == true
          ? AppBarWidget(
              text: LocaleKeys.collectcarats.tr(),
              context: context,
            )
          : null,
      body: Stack(
        children: stack,
      ),
      // body: Padding(
      //   padding: const EdgeInsets.all(10),
      //   child: ListView.builder(
      //     shrinkWrap: true,
      //     itemCount: 9,
      //     itemBuilder: (context, index) {
      //       return Padding(
      //         padding: const EdgeInsets.only(bottom: 10),
      //         child: ListTile(
      //           onTap: () {
      //             Get.bottomSheet(
      //               Container(
      //                 height: 25.h,
      //                 width: 100.w,
      //                 padding: EdgeInsets.all(10),
      //                 decoration: BoxDecoration(
      //                   color: constantColors.navButton,
      //                   borderRadius: BorderRadius.only(
      //                     topLeft: Radius.circular(20),
      //                     topRight: Radius.circular(20),
      //                   ),
      //                 ),
      //                 child: Column(
      //                   children: [
      //                     Padding(
      //                       padding:
      //                           const EdgeInsets.symmetric(horizontal: 150),
      //                       child: Divider(
      //                         thickness: 4,
      //                         color: constantColors.whiteColor,
      //                       ),
      //                     ),
      //                     Padding(
      //                       padding: const EdgeInsets.only(top: 20),
      //                       child: Container(
      //                         height: 50,
      //                         width: 100.w,
      //                         child: ElevatedButton(
      //                           style: ButtonStyle(
      //                             foregroundColor:
      //                                 MaterialStateProperty.all<Color>(
      //                                     Colors.white),
      //                             backgroundColor:
      //                                 MaterialStateProperty.all<Color>(
      //                                     constantColors.bioBg),
      //                             shape: MaterialStateProperty.all<
      //                                 RoundedRectangleBorder>(
      //                               RoundedRectangleBorder(
      //                                 borderRadius: BorderRadius.circular(20),
      //                               ),
      //                             ),
      //                           ),
      //                           onPressed: () {
      //                             Get.dialog(
      //                               SimpleDialog(
      //                                 backgroundColor:
      //                                     constantColors.whiteColor,
      //                                 title: Text(
      //                                   "Pending in-app purchase approval",
      //                                   textAlign: TextAlign.center,
      //                                   style: TextStyle(
      //                                     color: constantColors.black,
      //                                   ),
      //                                 ),
      //                                 children: [
      //                                   Padding(
      //                                     padding: const EdgeInsets.all(10),
      //                                     child: Text(
      //                                       "We've submitted our in-app purchase approval request for all the Carat tiers shown",
      //                                       textAlign: TextAlign.center,
      //                                       style: TextStyle(
      //                                           color: constantColors.black),
      //                                     ),
      //                                   ),
      //                                   Padding(
      //                                     padding: EdgeInsets.all(10),
      //                                     child: Row(
      //                                       children: [
      //                                         Expanded(
      //                                           child: ElevatedButton(
      //                                             style: ButtonStyle(
      //                                               foregroundColor:
      //                                                   MaterialStateProperty
      //                                                       .all<Color>(
      //                                                           Colors.white),
      //                                               backgroundColor:
      //                                                   MaterialStateProperty
      //                                                       .all<Color>(
      //                                                           constantColors
      //                                                               .navButton),
      //                                               shape: MaterialStateProperty
      //                                                   .all<
      //                                                       RoundedRectangleBorder>(
      //                                                 RoundedRectangleBorder(
      //                                                   borderRadius:
      //                                                       BorderRadius
      //                                                           .circular(20),
      //                                                 ),
      //                                               ),
      //                                             ),
      //                                             onPressed: Get.back,
      //                                             child: Text(
      //                                               "Understood!",
      //                                               style:
      //                                                   TextStyle(fontSize: 12),
      //                                             ),
      //                                           ),
      //                                         ),
      //                                         SizedBox(
      //                                           width: 10,
      //                                         ),
      //                                         Expanded(
      //                                           child: ElevatedButton(
      //                                             style: ButtonStyle(
      //                                               foregroundColor:
      //                                                   MaterialStateProperty
      //                                                       .all<Color>(
      //                                                           Colors.white),
      //                                               backgroundColor:
      //                                                   MaterialStateProperty
      //                                                       .all<Color>(
      //                                                           constantColors
      //                                                               .navButton),
      //                                               shape: MaterialStateProperty
      //                                                   .all<
      //                                                       RoundedRectangleBorder>(
      //                                                 RoundedRectangleBorder(
      //                                                   borderRadius:
      //                                                       BorderRadius
      //                                                           .circular(20),
      //                                                 ),
      //                                               ),
      //                                             ),
      //                                             onPressed: Get.back,
      //                                             child: Text(
      //                                               "View Items",
      //                                             ),
      //                                           ),
      //                                         ),
      //                                       ],
      //                                     ),
      //                                   ),
      //                                 ],
      //                               ),
      //                               barrierDismissible: false,
      //                             );
      //                           },
      //                           child: Text(
      //                             "Apple App Store",
      //                             style: TextStyle(
      //                               color: constantColors.navButton,
      //                             ),
      //                           ),
      //                         ),
      //                       ),
      //                     ),
      //                     Padding(
      //                       padding: const EdgeInsets.only(top: 20),
      //                       child: Container(
      //                         height: 50,
      //                         width: 100.w,
      //                         child: ElevatedButton(
      //                           style: ButtonStyle(
      //                             foregroundColor:
      //                                 MaterialStateProperty.all<Color>(
      //                                     Colors.white),
      //                             backgroundColor:
      //                                 MaterialStateProperty.all<Color>(
      //                                     constantColors.bioBg),
      //                             shape: MaterialStateProperty.all<
      //                                 RoundedRectangleBorder>(
      //                               RoundedRectangleBorder(
      //                                 borderRadius: BorderRadius.circular(20),
      //                               ),
      //                             ),
      //                           ),
      //                           onPressed: () async {},
      //                           child: Text(
      //                             "Glamorous Diastation Direct Payment",
      //                             style: TextStyle(
      //                               color: constantColors.navButton,
      //                             ),
      //                           ),
      //                         ),
      //                       ),
      //                     ),
      //                   ],
      //                 ),
      //               ),
      //             );
      //           },
      //           leading: Image.asset("assets/carats/${index}.png"),
      //           title: Text(carats[index].name),
      //           trailing: Text("\$${carats[index].price}"),
      //         ),
      //       );
      //     },
      //   ),
      // ),
    );
  }
}

class ExamplePaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
      SKPaymentTransactionWrapper transaction, SKStorefrontWrapper storefront) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
}
