import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const TextStyle h1 = TextStyle(
    fontFamily: 'PlayfairDisplay',
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.cacao,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: 'PlayfairDisplay',
    fontSize: 26,
    fontWeight: FontWeight.w600,
    color: AppColors.cacao,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: 'Epilogue',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.cacao,
  );

  static const TextStyle body = TextStyle(
    fontFamily: 'Epilogue',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.cacao,
  );

  static const TextStyle bodySecondary = TextStyle(
    fontFamily: 'Epilogue',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.grisTexte,
  );

  static const TextStyle button = TextStyle(
    fontFamily: 'Epilogue',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.blanc,
  );

  static const TextStyle hash = TextStyle(
    fontFamily: 'JetBrainsMono',
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.cacao,
  );

  static const TextStyle hashBlockchain = hash;
}
