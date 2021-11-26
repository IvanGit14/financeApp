import 'package:flutter/material.dart';

class tabselected extends ChangeNotifier {
  int _selected = 0;

  int get selected {
    return this._selected;
  }

  set selected(int i) {
    this._selected = i;
    notifyListeners();
  }
}
