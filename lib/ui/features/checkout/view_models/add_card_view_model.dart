import 'package:flutter/foundation.dart';

class AddCardViewModel extends ChangeNotifier {
  bool _saveForFuture = true;

  bool get saveForFuture => _saveForFuture;

  void toggleSaveForFuture() {
    _saveForFuture = !_saveForFuture;
    notifyListeners();
  }
}
