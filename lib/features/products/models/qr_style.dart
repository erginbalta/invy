import 'package:flutter/material.dart';

class ProductQrStyle {
  const ProductQrStyle({
    required this.foreground,
    required this.background,
    required this.rounded,
  });

  final Color foreground;
  final Color background;
  final bool rounded;

  ProductQrStyle copyWith({
    Color? foreground,
    Color? background,
    bool? rounded,
  }) {
    return ProductQrStyle(
      foreground: foreground ?? this.foreground,
      background: background ?? this.background,
      rounded: rounded ?? this.rounded,
    );
  }
}
