import 'package:diamon_rose_app/share/localizations/l10n/localy.dart';
import 'package:diamon_rose_app/widgets/regexp_pattern.dart';
import 'package:diamon_rose_app/widgets/validation_result.dart';

import 'package:flutter/cupertino.dart';

class ValidateUtils {
  ValidateUtils(BuildContext context) {
    this.context = context;
  }
  late BuildContext context;

  /// check if string [str] is Email
  static bool validateEmail(String value) {
    final regex = RegExp(RegExpPattern.emailRegExpPattern.toString());
    if (regex.hasMatch(value)) {
      return true;
    }
    return false;
  }

  /// check if string [str] is null or whitespace
  static bool isNullEmptyOrWhitespace(String value) {
    if (value.isEmpty || value.trim().isEmpty) {
      return true;
    }
    return false;
  }

  /// check if string [str] is phone number
  static bool validatePhone(String value) {
    final regex = RegExp(RegExpPattern.mobileRegExpPattern.toString());
    if (regex.hasMatch(value)) {
      return true;
    }
    return false;
  }

  /// check if the string contains the seed
  static bool contains(String str, dynamic seed) {
    return str.indexOf(seed.toString()) >= 0;
  }

  /// check if string [str] matches the [pattern].
  static bool matches(String str, String pattern) {
    final re = new RegExp(pattern);
    return re.hasMatch(str);
  }

  /// check if the string matches the comparison
  static bool equals(String? str, dynamic comparison) {
    return str == comparison.toString();
  }

  /// check if the string [str] is null
  static bool isNull(String? str) {
    return str == null || str.isEmpty;
  }

  /// check if the string [str] is lowercase
  static bool isLowercase(String str) {
    return str == str.toLowerCase();
  }

  /// check if the string [str] is uppercase
  static bool isUppercase(String str) {
    return str == str.toUpperCase();
  }

  /// check if the string [str] contains only letters (a-zA-Z).
  static bool isAlpha(String str) {
    return RegExp(RegExpPattern.alpha.toString()).hasMatch(str);
  }

  /// check if the string [str] is an integer
  static bool isInt(String str) {
    return RegExp(RegExpPattern.int.toString()).hasMatch(str);
  }

  /// check if the string [str] is a float
  static bool isFloat(String str) {
    return RegExp(RegExpPattern.float.toString()).hasMatch(str);
  }

  /// check if the string [str] contains only numbers
  static bool isNumeric(String str) {
    return RegExp(RegExpPattern.numeric.toString()).hasMatch(str);
  }

  /// check if the string [str] contains only letters and numbers
  static bool isAlphanumeric(String str) {
    return RegExp(RegExpPattern.alphanumeric.toString()).hasMatch(str);
  }

  /// check if a string [str] is base64 encoded
  static bool isBase64(String str) {
    return RegExp(RegExpPattern.base64.toString()).hasMatch(str);
  }

  /// check if a string [str] is url
  static bool isUrl(String value) {
    return RegExp(RegExpPattern.url.toString()).hasMatch(value);
  }

  /// Returns true String or List or Map is empty.
  static bool isEmpty(Object? object) {
    if (object == null) {
      return true;
    }
    if (object is String && object.isEmpty) {
      return true;
    } else if (object is Iterable && object.isEmpty) {
      return true;
    } else if (object is Map && object.isEmpty) {
      return true;
    }
    return false;
  }

  /// Returns true String or List or Map is not empty.
  static bool isNotEmpty(Object? object) {
    return !isEmpty(object);
  }

  /// check if string [str] contain Number
  static bool isContainedNumberOrNonWord(String value) {
    final regexNumber = RegExp(RegExpPattern.containNumber.toString());
    final regexNonWord = RegExp(RegExpPattern.containNonWord.toString());
    if (regexNumber.hasMatch(value) || regexNonWord.hasMatch(value)) {
      return true;
    }
    return false;
  }

  /// check if string [str] contain UpperCase
  static bool isContainedLowerUpperCase(String value) {
    final regexUpper = RegExp(RegExpPattern.containUpperCase.toString());
    final regexLower = RegExp(RegExpPattern.containLowerCase.toString());
    if (regexUpper.hasMatch(value) && regexLower.hasMatch(value)) {
      return true;
    }
    return false;
  }

  /// check if string [str] contain LowerCase
  static bool isContainedLowerCase(String value) {
    final regex = RegExp(RegExpPattern.containLowerCase.toString());
    if (regex.hasMatch(value)) {
      return true;
    }
    return false;
  }

  /// check if string [str] contain Non-word
  static bool isContainedNonWord(String value) {
    final regex = RegExp(RegExpPattern.containLowerCase.toString());
    if (regex.hasMatch(value)) {
      return true;
    }
    return false;
  }

  /// check if string [str] between 8-20 characters
  static bool isBetween8to20(String value) {
    if (value.length >= 8 && value.length <= 20) {
      return true;
    }
    return false;
  }

  /// check if password condition
  ValidationResult validatePassword(String password) {
    if (ValidateUtils.isNullEmptyOrWhitespace(password)) {
      return ValidationResult.error("passwordEmptyLabel");
    }
    if (!ValidateUtils.isContainedNumberOrNonWord(password)) {
      return ValidationResult.error("numberNonWordError");
    }
    if (!ValidateUtils.isContainedLowerUpperCase(password)) {
      return ValidationResult.error("alphaError");
    }
    if (!ValidateUtils.isBetween8to20(password)) {
      return ValidationResult.error("lengthError");
    }

    return ValidationResult.ok();
  }

  /// check password confirm is correct
  ValidationResult validateConfirmPassword(
      String password, String confirmPassword) {
    if (password != confirmPassword) {
      return ValidationResult.error("incorrectConfirmPass");
    }

    return ValidationResult.ok();
  }

  /// check password and confirm password validity
  bool validateForm(
      {required String password, required String confirmPassword}) {
    final passwordValid = validatePassword(password).isValid;
    final confirmPasswordValid = validatePassword(confirmPassword).isValid;

    return passwordValid && confirmPasswordValid;
  }

  /// check if string [str] is not contain space
  static bool containSpace(String value) {
    final regex = RegExp(RegExpPattern.notContainSpace.toString());
    if (regex.hasMatch(value)) {
      return true;
    }
    return false;
  }

  /// check if string [str] between 8-13 characters
  static bool isBetween8to13(String value) {
    if (!(value.length >= 8)) {
      return true;
    }
    return false;
  }

  static bool isPercentValid(String value) {
    if (!RegExp(RegExpPattern.numeric.toString()).hasMatch(value)) {
      return false;
    }
    if (int.parse(value) < 0 || int.parse(value) > 100) {
      return false;
    }
    return true;
  }

  /// check if image size [int] is bigger than regular size
  static bool capacityIsTooBig(int value, int sizeInKB) {
    return value >= sizeInKB * 1000;
  }

  /// check if [int] is greater than zero
  static bool isGreaterThanZero(int value) {
    return value > 0;
  }
}
