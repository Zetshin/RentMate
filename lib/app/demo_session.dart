import 'package:flutter/foundation.dart';

/// Preview state only. Nothing is sent to a server or persisted.
class DemoSession extends ChangeNotifier {
  String firstName = 'อาร์ต';
  String lastName = 'ใจดี';
  String paymentStatus = 'ยังไม่ชำระ';
  bool approved = false;

  void update() => notifyListeners();

  void reset() {
    firstName = 'อาร์ต';
    lastName = 'ใจดี';
    paymentStatus = 'ยังไม่ชำระ';
    approved = false;
    notifyListeners();
  }
}
