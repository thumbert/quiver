library models.homepage.homepage_model.dart;

import 'package:flutter/material.dart';

class MenuItem {
  MenuItem(
      {required this.title,
      required this.url,
      this.isHighlighted = false,
      this.icon});

  final String title;
  final Icon? icon;
  final String url;
  bool isHighlighted;
}
