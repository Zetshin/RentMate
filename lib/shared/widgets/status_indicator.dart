import 'package:flutter/material.dart';

Color statusColor(String status) => switch (status) {
  'ยังไม่ชำระ' => const Color(0xFFFCA5A5),
  'ชำระแล้ว' || 'อนุมัติแล้ว' => const Color(0xFF4ADE80),
  'หลักฐานไม่ถูกต้อง' || 'ไม่ผ่าน' => const Color(0xFFFCA5A5),
  _ => const Color(0xFFFACC15),
};

IconData statusIcon(String status) => switch (status) {
  'ยังไม่ชำระ' => Icons.error_outline,
  'ชำระแล้ว' || 'อนุมัติแล้ว' => Icons.check_circle_outline,
  'หลักฐานไม่ถูกต้อง' || 'ไม่ผ่าน' => Icons.cancel_outlined,
  _ => Icons.schedule_outlined,
};

class StatusIndicator extends StatelessWidget {
  const StatusIndicator(this.status, {super.key, this.prefix = 'สถานะ: '});
  final String status;
  final String prefix;
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(statusIcon(status), color: statusColor(status), size: 22),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          '$prefix$status',
          style: TextStyle(
            color: statusColor(status),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ],
  );
}
