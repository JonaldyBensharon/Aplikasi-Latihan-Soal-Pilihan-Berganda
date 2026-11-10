import 'package:flutter/widgets.dart';

// Skala untuk mengatur komponen berdasarkan sisi terpendek layar.
// Ukuran <= 430 = 1.0 
class Responsive {
  static const double _baseSide = 430;
  static const double _range = 670;
  static const double maxScale = 1.6;

  static double scaleFor(Size size) {
    final extra = ((size.shortestSide - _baseSide) / _range).clamp(0.0, 1.0);
    return 1 + extra * (maxScale - 1);
  }
}

extension ResponsiveContext on BuildContext {
  // skala untuk ukuran komponen
  double get rs => Responsive.scaleFor(MediaQuery.sizeOf(this));
}