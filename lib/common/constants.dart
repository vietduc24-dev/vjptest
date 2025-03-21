import 'package:flutter/material.dart';

import 'colors.dart';

class AppConstants {
  AppConstants._();

  static const int pageSize = 20;
  static const double projectHomeLayoutPadding = 40;
  static const double projectHomeItemPadding = 5;

  static const String vndCurrencySymbol = ' đ'; //"\u20ab";

  static const String phoneKey = 'phone';
  static const String otpKey = 'otp';
  static const String passwordKey = 'password';
  static const String emailKey = 'email';
  static const String confirmPasswordKey = 'confirmPassword';
  static const String referralCodeKey = 'referralCode';
  static const String provinceKey = 'province';
  static const String districtKey = 'district';
  static const String wardKey = 'ward';
  static const String houseNumberKey = 'street';
  static const String fullNameKey = 'fullName';
  static const String genderKey = 'gender';
  static const String dobKey = 'dob';
  static const String addressKey = 'address';
  static const String taxCodeKey = 'taxCode';
  static const String idNumberKey = 'idNumber';
  static const String oldIdNumberKey = 'oldIdNumber';
  static const String bankKey = 'bank';
  static const String bankBranchKey = 'bankBranch';
  static const String accountNumberKey = 'accountNumber';
  static const String policyKey = 'policy';
  static const String withdrawAmountKey = 'withdrawAmount';
  static const String projectSchemeKey = 'projectScheme';

  static List<BoxShadow> boxShadow = [
    BoxShadow(
      color: UIColors.black.withOpacity(0.05),
      spreadRadius: 0,
      blurRadius: 2,
      offset: const Offset(1, 1),
    ),
  ];

  static List<BoxShadow> boxShadow44 = [
    BoxShadow(
      color: UIColors.black.withOpacity(0.1),
      spreadRadius: 0,
      blurRadius: 4,
      offset: const Offset(4, 4),
    ),
  ];

  static List<BoxShadow> layoutShadow = [
    BoxShadow(
      color: UIColors.black.withOpacity(0.25),
      spreadRadius: 0,
      blurRadius: 50,
      offset: const Offset(0, -4),
    ),
  ];

  static List<BoxShadow> componentShadow = [
    BoxShadow(
      color: UIColors.black.withOpacity(0.1),
      spreadRadius: 0,
      blurRadius: 4,
      offset: const Offset(2, 4),
    ),
  ];

  static List<BoxShadow> itemExtraShadow = [
    BoxShadow(
      color: UIColors.black.withOpacity(0.25),
      spreadRadius: 0,
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> itemShadow = [
    BoxShadow(
      color: UIColors.black.withOpacity(0.05),
      spreadRadius: 0,
      blurRadius: 2,
      offset: const Offset(1, 1),
    ),
  ];

  static const ScrollPhysics physics = AlwaysScrollableScrollPhysics(
    parent: BouncingScrollPhysics(),
  );
}
