// lib/utils/platform_utils.dart
import 'package:flutter/material.dart';

bool isIOS(BuildContext context) {
  return Theme.of(context).platform == TargetPlatform.iOS;
}