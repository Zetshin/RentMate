import 'package:flutter/material.dart';
import '../../../app/demo_session.dart';
import '../../../shared/widgets/preview_page.dart';
import '../../../shared/widgets/status_indicator.dart';

class JoinRoomScreen extends StatefulWidget {
  const JoinRoomScreen({super.key});
  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  final _form = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) => PreviewPage(
    title: 'เข้าร่วมห้องพักของคุณ',
    children: [
      const Icon(Icons.meeting_room_outlined, size: 64),
      const SizedBox(height: 24),
      const Text(
        'ขอรหัสเชิญจากเจ้าของห้อง แล้วกรอกด้านล่าง',
        style: TextStyle(fontSize: 18),
      ),
      const SizedBox(height: 24),
      Form(
        key: _form,
        child: TextFormField(
          key: const Key('invite_code'),
          decoration: const InputDecoration(
            labelText: 'รหัสเชิญ',
            helperText: 'รหัสทดลอง: AB12-CD34',
          ),
          textCapitalization: TextCapitalization.characters,
          validator: (value) => value?.trim().toUpperCase() == 'AB12-CD34'
              ? null
              : 'ไม่พบรหัสนี้ ลองใช้ AB12-CD34',
        ),
      ),
      const SizedBox(height: 32),
      FilledButton(
        onPressed: () {
          if (_form.currentState!.validate()) {
            Navigator.pushNamed(context, '/occupant');
          }
        },
        child: const Text('ตรวจสอบรหัส'),
      ),
      const SizedBox(height: 24),
      const Text(
        'ยังไม่มีรหัส? ติดต่อเจ้าของห้อง',
        textAlign: TextAlign.center,
      ),
    ],
  );
}

class OccupantScreen extends StatefulWidget {
  const OccupantScreen({super.key, required this.session});
  final DemoSession session;
  @override
  State<OccupantScreen> createState() => _OccupantScreenState();
}

class _OccupantScreenState extends State<OccupantScreen> {
  final _form = GlobalKey<FormState>();
  String _first = '';
  String _last = '';
  @override
  Widget build(BuildContext context) => PreviewPage(
    title: 'ยืนยันข้อมูลผู้เข้าพัก',
    children: [
      const InfoCard(
        children: [
          Text('หอพักสุขใจ', style: TextStyle(fontSize: 22)),
          Text('ห้อง 204 • ชั้น 2'),
        ],
      ),
      Form(
        key: _form,
        child: Column(
          children: [
            TextFormField(
              key: const Key('first_name'),
              decoration: const InputDecoration(labelText: 'ชื่อจริง'),
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'กรุณากรอกชื่อจริง' : null,
              onSaved: (v) => _first = v!.trim(),
            ),
            const SizedBox(height: 24),
            TextFormField(
              key: const Key('last_name'),
              decoration: const InputDecoration(labelText: 'นามสกุล'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'กรุณากรอกนามสกุล' : null,
              onSaved: (v) => _last = v!.trim(),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      const Text('กรุณากรอกชื่อให้ตรงกับข้อมูลที่แจ้งเจ้าของห้อง'),
      const SizedBox(height: 32),
      FilledButton(
        onPressed: () {
          if (!_form.currentState!.validate()) return;
          _form.currentState!.save();
          widget.session.firstName = _first;
          widget.session.lastName = _last;
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/pending-room',
            (_) => false,
          );
        },
        child: const Text('ส่งคำขอเข้าร่วม'),
      ),
    ],
  );
}

class PendingRoomScreen extends StatelessWidget {
  const PendingRoomScreen({super.key, required this.session});
  final DemoSession session;
  @override
  Widget build(BuildContext context) => PreviewPage(
    title: 'รออนุมัติ',
    children: [
      const Icon(Icons.schedule_outlined, size: 72, color: Color(0xFFFACC15)),
      const SizedBox(height: 24),
      const Text(
        'กำลังรอการอนุมัติ',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 24, color: Color(0xFFFACC15)),
      ),
      const SizedBox(height: 24),
      InfoCard(
        children: [
          Text('${session.firstName} ${session.lastName}'),
          const Text('หอพักสุขใจ • ห้อง 204'),
          const StatusIndicator('รออนุมัติ'),
        ],
      ),
      const Text(
        'เจ้าของห้องจะตรวจสอบคำขอ เมื่ออนุมัติแล้วจึงเริ่มใช้งานได้',
        style: TextStyle(color: Color(0xFFFCA5A5)),
      ),
      const SizedBox(height: 24),
      FilledButton(
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'คำขอยังอยู่ระหว่างรออนุมัติ',
              style: TextStyle(color: Color(0xFFFACC15)),
            ),
            backgroundColor: Color(0xFF202024),
          ),
        ),
        child: const Text('ตรวจสอบสถานะ'),
      ),
      const SizedBox(height: 16),
      OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFFCA5A5),
          side: const BorderSide(color: Color(0xFFFCA5A5)),
          minimumSize: const Size(0, 52),
        ),
        onPressed: () async {
          if (await confirmAction(
                context,
                'ยกเลิกคำขอ?',
                'ต้องการยกเลิกคำขอเข้าห้อง 204 หรือไม่',
              ) &&
              context.mounted) {
            Navigator.pushNamedAndRemoveUntil(context, '/join', (_) => false);
          }
        },
        icon: const Icon(Icons.close),
        label: const Text('ยกเลิกคำขอ'),
      ),
      const SizedBox(height: 24),
      TextButton(
        onPressed: () {
          session.approved = true;
          Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
        },
        child: const Text('เครื่องมือทดลอง: จำลองเจ้าของอนุมัติ'),
      ),
    ],
  );
}
