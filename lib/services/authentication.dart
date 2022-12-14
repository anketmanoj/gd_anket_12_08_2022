// ignore_for_file: avoid_catches_without_on_clauses

import 'dart:convert';
import 'dart:developer';

import 'package:cool_alert/cool_alert.dart';
import 'package:diamon_rose_app/services/OTPModel.dart';
import 'package:diamon_rose_app/services/dbService.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:http/http.dart' as http;

class Authentication with ChangeNotifier {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  late bool isAnon;
  bool emailAuth = false;

  late String userUid,
      googleUsername,
      googleUseremail,
      googleUserImage,
      googlePhoneNo;

  late String appleUsername, appleUseremail, appleUserImage, applePhoneNo;
  late String facebookUsername,
      facebookUseremail,
      facebookUserImage,
      facebookPhoneNo;

  bool get getIsAnon => isAnon;
  bool get getEmailAuth => emailAuth;
  String get getUserId => userUid;
  String get getgoogleUsername => googleUsername;
  String get getgoogleUseremail => googleUseremail;
  String get getgoogleUserImage => googleUserImage;
  String get getgooglePhoneNo => googlePhoneNo;

  String get getappleUsername => appleUsername;
  String get getappleUseremail => appleUseremail;
  String get getappleUserImage => appleUserImage;
  String get getapplePhoneNo => applePhoneNo;

  String get getfacebookUsername => facebookUsername;
  String get getfacebookUseremail => facebookUseremail;
  String get getfacebookUserImage => facebookUserImage;
  String get getfacebookPhoneNo => facebookPhoneNo;

  Future returningUserLogin(String uid) async {
    userUid = uid;
    isAnon = false;
    log("ANKET logged in " + userUid);
    notifyListeners();
  }

  Future<bool> deleteUser(String email, String password) async {
    try {
      final User user = await firebaseAuth.currentUser!;
      final AuthCredential credentials =
          EmailAuthProvider.credential(email: email, password: password);
      print(user);
      final UserCredential result =
          await user.reauthenticateWithCredential(credentials);
      await DatabaseService(uid: result.user!.uid).deleteuser();
      await result.user!.delete();
      await FirebaseAuth.instance.signOut();
      return true;
    } catch (e) {
      return false;
    }
  }

  void setIsAnon(bool value) {
    isAnon = value;
    notifyListeners();
  }

  Future loginIntoAccount(String email, String password) async {
    UserCredential userCredential = await firebaseAuth
        .signInWithEmailAndPassword(email: email, password: password);

    User? user = userCredential.user;
    userUid = user!.uid;
    emailAuth = true;
    isAnon = false;
    print("logged in " + userUid);
    notifyListeners();
  }

  Future createAccount(String email, String password) async {
    UserCredential userCredential = await firebaseAuth
        .createUserWithEmailAndPassword(email: email, password: password);

    User? user = userCredential.user;
    userUid = user!.uid;
    emailAuth = true;
    isAnon = false;
    print(userUid);
    notifyListeners();
  }

  Future<User?> adminCreateAccount(String email, String password) async {
    final UserCredential userCredential = await firebaseAuth
        .createUserWithEmailAndPassword(email: email, password: password);

    final User? adminCreatedUser = userCredential.user;

    return adminCreatedUser;
  }

  Future logOutViaEmail() {
    emailAuth = false;
    notifyListeners();
    return firebaseAuth.signOut();
  }

  Future<bool> signInWithgoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;
      final AuthCredential authCredential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final UserCredential userCredential =
          await firebaseAuth.signInWithCredential(authCredential);

      final User? user = userCredential.user;
      assert(user!.uid != null);

      userUid = user!.uid;
      isAnon = false;
      googleUseremail = user.email!;
      googleUsername = user.displayName ?? "Google";
      googleUserImage = user.photoURL ??
          "https://firebasestorage.googleapis.com/v0/b/gdfe-ac584.appspot.com/o/bgImagesAR%2FGDapplogo.png?alt=media&token=9a23d52a-2282-4eb7-a751-a8e4fc7b7f8f";
      googlePhoneNo = user.phoneNumber ?? "";
      print("Google sign in => ${userUid} || ${user.email}");
      notifyListeners();
    } catch (e) {
      log("Anket google error = ${e.toString()}");
      return false;
    }
    return true;
  }

  Future<User?> signInFacebook() async {
    final LoginResult result = await FacebookAuth.instance.login();
    if (result.status == LoginStatus.success) {
      // Create a credential from the access token
      final OAuthCredential credential =
          FacebookAuthProvider.credential(result.accessToken!.token);
      // Once signed in, return the UserCredential
      final userCredential =
          await firebaseAuth.signInWithCredential(credential);
      final firebaseUser = userCredential.user!;

      return firebaseUser;
    }
    return null;
  }

  Future<void> facebookLogOut() async {
    await FacebookAuth.instance.logOut();
  }

  Future<bool> signInWithFacebook() async {
    final user = await signInFacebook();
    if (user != null) {
      print(user.email);
      userUid = user.uid;
      isAnon = false;
      facebookUseremail = user.email!;
      facebookUsername = user.displayName!;
      facebookUserImage = user.photoURL ??
          "https://firebasestorage.googleapis.com/v0/b/gdfe-ac584.appspot.com/o/bgImagesAR%2FGDapplogo.png?alt=media&token=9a23d52a-2282-4eb7-a751-a8e4fc7b7f8f";
      facebookPhoneNo = user.phoneNumber ?? "";
      print("Facebook sign in => ${userUid} || ${user.email}");

      notifyListeners();
      return true;
    } else {
      log("Anket error facebook");
      return false;
    }
  }

  Future<User?> signInApple({List<Scope> scopes = const []}) async {
    // 1. perform the sign-in request
    final result = await TheAppleSignIn.performRequests(
        [AppleIdRequest(requestedScopes: scopes)]);
    // 2. check the result
    switch (result.status) {
      case AuthorizationStatus.authorized:
        final appleIdCredential = result.credential!;
        final oAuthProvider = OAuthProvider('apple.com');
        final credential = oAuthProvider.credential(
          idToken: String.fromCharCodes(appleIdCredential.identityToken!),
          accessToken:
              String.fromCharCodes(appleIdCredential.authorizationCode!),
        );
        final userCredential =
            await firebaseAuth.signInWithCredential(credential);
        final firebaseUser = userCredential.user!;

        if (scopes.contains(Scope.fullName)) {
          final fullName = appleIdCredential.fullName;
          final email = appleIdCredential.email;

          if (fullName != null &&
              fullName.givenName != null &&
              fullName.familyName != null) {
            final displayName = '${fullName.givenName} ${fullName.familyName}';

            await firebaseUser.updateDisplayName(displayName);
            await firebaseUser.updateEmail(email!);
          }
        }
        return firebaseUser;
      case AuthorizationStatus.error:
        throw PlatformException(
          code: 'ERROR_AUTHORIZATION_DENIED',
          message: result.error.toString(),
        );

      case AuthorizationStatus.cancelled:
        throw PlatformException(
          code: 'ERROR_ABORTED_BY_USER',
          message: 'Sign in aborted by user',
        );
      default:
        throw UnimplementedError();
    }
  }

  Future<bool> signInWithApple(BuildContext context) async {
    final user = await signInApple(scopes: [Scope.email, Scope.fullName]);
    if (user != null) {
      print(user.email);
      userUid = user.uid;
      isAnon = false;
      appleUseremail = user.email!;
      appleUsername = user.email!;
      appleUserImage =
          "https://firebasestorage.googleapis.com/v0/b/gdfe-ac584.appspot.com/o/bgImagesAR%2FGDapplogo.png?alt=media&token=9a23d52a-2282-4eb7-a751-a8e4fc7b7f8f";
      // "https://firebasestorage.googleapis.com/v0/b/maredsocial-79a7b.appspot.com/o/userProfileAvatar%2Fprivate%2Fvar%2Fmobile%2FContainers%2FData%2FApplication%2Ficon-mared.png?alt=media&token=eec2b470-f32e-4449-874a-e6929e210c6c";
      applePhoneNo = "";

      print("appleUsername == ${appleUsername}");

      notifyListeners();
      return true;
    } else {
      log("Anket Error apple");
      return false;
    }
  }

  Future signOutWithGoogle() async {
    return googleSignIn.signOut();
  }

  Future signInAnon() async {
    try {
      var userCredential = await firebaseAuth.signInAnonymously();

      User? user = userCredential.user;
      userUid = user!.uid;
      isAnon = true;
      print("logged in " + userUid);
      notifyListeners();
    } catch (e) {
      print("FAILED === ${e.toString()}");
    }
  }

  Future<void> changePassword(
      String currentPassword, String newPassword, BuildContext context) async {
    final user = await FirebaseAuth.instance.currentUser;
    final cred = EmailAuthProvider.credential(
        email: user!.email!, password: currentPassword);

    await user.reauthenticateWithCredential(cred).then((value) {
      user.updatePassword(newPassword).then((_) {
        Get.snackbar(
          'Password Updated!',
          "Your password has been successfully updated!",
          overlayColor: constantColors.navButton,
          colorText: constantColors.whiteColor,
          snackPosition: SnackPosition.TOP,
          forwardAnimationCurve: Curves.elasticInOut,
          reverseAnimationCurve: Curves.easeOut,
        );

        Navigator.pop(context);
        Navigator.pop(context);
      }).catchError((error) {
        Get.snackbar(
          'Error Updating',
          "Error: ${error.toString()}",
          overlayColor: constantColors.navButton,
          colorText: constantColors.whiteColor,
          snackPosition: SnackPosition.TOP,
          forwardAnimationCurve: Curves.elasticInOut,
          reverseAnimationCurve: Curves.easeOut,
        );
        Navigator.pop(context);
      });
    }).catchError((err) {
      Get.snackbar(
        'Incorrect Password',
        "Current password entered is incorrect",
        overlayColor: constantColors.navButton,
        colorText: constantColors.whiteColor,
        snackPosition: SnackPosition.TOP,
        forwardAnimationCurve: Curves.elasticInOut,
        reverseAnimationCurve: Curves.easeOut,
      );
      Navigator.pop(context);
    });
  }

  Future<void> changeEmail(
      {required String currentPassword,
      required String newEmail,
      required BuildContext context}) async {
    final user = await FirebaseAuth.instance.currentUser;
    final cred = EmailAuthProvider.credential(
        email: user!.email!, password: currentPassword);

    final String currentEmail = user.email!;

    await user.reauthenticateWithCredential(cred).then((value) {
      user.updateEmail(newEmail).then((_) {
        showTopSnackBar(
          context,
          CustomSnackBar.info(
            message: "Email changed successfully",
          ),
        );
      }).catchError((error) {
        showTopSnackBar(
          context,
          CustomSnackBar.error(
            message: "Error sending email",
          ),
        );
      });
    }).catchError((err) {
      showTopSnackBar(
        context,
        CustomSnackBar.error(
          message: "Invalid Password",
        ),
      );
    });
  }

  Future<OtpSecreteId?> sendEmailForOTPGeneration({
    required String otp_email,
  }) async {
    // ignore: unawaited_futures

    log("sending email OTP request");

    var response = await http.post(
      Uri.parse(
        "http://ALBforSeparateAPI-1104668696.us-east-1.elb.amazonaws.com/apiv6/generateotp/",
      ),
      headers: {"Content-Type": "application/json"},
      body: json.encode(
        {
          "email": otp_email,
        },
      ),
    );

    log("sent request");

    // log(response.statusCode)

    switch (response.statusCode) {
      case 200:
        log("Anket response OK");

        log("otp email response full = ${response.body}");
        final OtpSecreteId otpResponse = OtpSecreteId.fromJson(response.body);

        return otpResponse;
      case 500:
        log("######FAILED TO GENERATE OTP");
        Get.dialog(
          SimpleDialog(
            children: [
              Padding(
                padding: EdgeInsets.all(10),
                child: Text("Failed to generate OTP, please try again later!"),
              ),
            ],
          ),
        );
        break;
      case 406:
        log("######INVALID EMAIL ADDRESS");
        Get.dialog(
          SimpleDialog(
            children: [
              Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                    "Invalid email address entered, please check the entered email address!"),
              ),
            ],
          ),
        );
        break;
    }
  }

  Future<bool> verifyOtpFromUser({
    required String secretId,
    required String otp,
  }) async {
    // ignore: unawaited_futures

    log("verifying OTP");

    var response = await http.post(
      Uri.parse(
        "http://ALBforSeparateAPI-1104668696.us-east-1.elb.amazonaws.com/apiv6/verify/verifyotp/",
      ),
      headers: {"Content-Type": "application/json"},
      body: json.encode(
        {"secret_id": secretId, "enteredOTP": otp},
      ),
    );

    log("sent otp verification request");

    // log(response.statusCode)

    switch (response.statusCode) {
      case 200:
        log("Anket response OK");

        return true;
      case 500:
        log("######FAILED TO Connect to server");
        Get.dialog(
          SimpleDialog(
            children: [
              Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                    "Failed to connect to server, please try again later!"),
              ),
            ],
          ),
        );
        return false;
      case 406:
        log("######INCORRECT OTP ENTERED");
        Get.dialog(
          SimpleDialog(
            children: [
              Padding(
                padding: EdgeInsets.all(10),
                child: Text("OTP entered is incorrect"),
              ),
            ],
          ),
        );
        return false;
      default:
        log("######Unknown error");
        Get.dialog(
          SimpleDialog(
            children: [
              Padding(
                padding: EdgeInsets.all(10),
                child: Text("Unknown OTP Error"),
              ),
            ],
          ),
        );
        return false;
    }
  }
}
