import 'package:flutter/widgets.dart';

class IndexPageVM extends ChangeNotifier {
  bool inlineadLoaded = false;
  void setInlineadLoaded() {
    inlineadLoaded = true;
    notifyListeners();
  }
}
