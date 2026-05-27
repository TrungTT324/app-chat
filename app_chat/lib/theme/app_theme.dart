import 'package:flutter/material.dart';

class AppTheme extends ChangeNotifier {
  Color _primary = Colors.blue;
  double _textScale = 1.0;

  Color get primary => _primary;
  double get textScale => _textScale;

  void updatePrimary(Color c) {
    _primary = c;
    notifyListeners();
  }

  void updateTextScale(double s) {
    _textScale = s.clamp(0.7, 1.6);
    notifyListeners();
  }
}
