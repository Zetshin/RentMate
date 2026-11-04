import 'dart:math';
import 'package:flutter/foundation.dart';

class OwnerRoom {
  OwnerRoom(this.number, this.code);
  final String number;
  final String code;
  String? tenant;
  String? requestName;
  String status = 'ยังไม่มีบิล';
  double rent = 3000, electricityRate = 8, waterRate = 250, penalty = 20;
  bool electricityFlat = false, waterFlat = true;
  double previousElectricity = 0, previousWater = 0;
  double? billTotal;
  String dueDate = '';
  final List<RoomBill> bills = [];
}

class RoomBill {
  RoomBill({
    required this.month,
    required this.rent,
    required this.electricity,
    required this.water,
    required this.due,
    required this.electricityDetail,
    required this.waterDetail,
  });
  final DateTime month;
  final double rent, electricity, water;
  final DateTime due;
  final String electricityDetail, waterDetail;
  String status = 'ยังไม่ชำระ';
  double get total => rent + electricity + water;
}

String billMonthLabel(DateTime month) {
  const names = [
    'มกราคม',
    'กุมภาพันธ์',
    'มีนาคม',
    'เมษายน',
    'พฤษภาคม',
    'มิถุนายน',
    'กรกฎาคม',
    'สิงหาคม',
    'กันยายน',
    'ตุลาคม',
    'พฤศจิกายน',
    'ธันวาคม',
  ];
  return '${names[month.month - 1]} ${month.year + 543}';
}

/// Owner prototype data, cleared when the application restarts.
class OwnerDemo extends ChangeNotifier {
  String propertyName = '';
  String bank = '', accountName = '', accountNumber = '';
  bool sampleQr = false;
  final List<OwnerRoom> rooms = [];

  void update() => notifyListeners();
  OwnerRoom addRoom(String number) {
    const alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random.secure();
    String code;
    do {
      final chars = List.generate(
        8,
        (_) => alphabet[random.nextInt(alphabet.length)],
      ).join();
      code = '${chars.substring(0, 4)}-${chars.substring(4)}';
    } while (rooms.any((room) => room.code == code));
    final room = OwnerRoom(number, code);
    rooms.add(room);
    notifyListeners();
    return room;
  }
}
