import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/demo_session.dart';
import '../../../shared/widgets/preview_page.dart';
import '../../../shared/widgets/status_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.session});
  final DemoSession session;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.session,
    builder: (context, _) => Scaffold(
      appBar: AppBar(title: Text(['หน้าหลัก', 'ประวัติ', 'บัญชี'][_tab])),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'โหมดทดลอง • ข้อมูลจำลอง',
                    style: TextStyle(color: Color(0xFFB5B5BF)),
                  ),
                  const SizedBox(height: 24),
                  if (_tab == 0) ...[
                    Text(
                      'สวัสดี คุณ${widget.session.firstName}',
                      style: const TextStyle(fontSize: 26),
                    ),
                    const SizedBox(height: 24),
                    const InfoCard(
                      children: [
                        Text('ห้องของฉัน', style: TextStyle(fontSize: 18)),
                        SizedBox(height: 12),
                        Text('หอพักสุขใจ • ห้อง 204 • ชั้น 2'),
                      ],
                    ),
                    InfoCard(
                      children: [
                        const Text('บิลประจำเดือนพฤศจิกายน 2569'),
                        const SizedBox(height: 16),
                        const Text('ยอดที่ต้องชำระ'),
                        const Text(
                          '฿3,850.00',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text('ครบกำหนด 5 พ.ย. 2569'),
                        const SizedBox(height: 12),
                        StatusIndicator(widget.session.paymentStatus),
                        const Divider(height: 32),
                        const BillLine('ค่าเช่า', '฿3,000.00'),
                        const BillLine('ค่าไฟ', '฿600.00'),
                        const BillLine('ค่าน้ำ', '฿250.00'),
                        TextButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/bill'),
                          child: const Text('ดูรายละเอียดบิล'),
                        ),
                      ],
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        widget.session.paymentStatus == 'ยังไม่ชำระ' ||
                                widget.session.paymentStatus ==
                                    'หลักฐานไม่ถูกต้อง'
                            ? '/payment'
                            : '/payment-status',
                      ),
                      child: Text(
                        widget.session.paymentStatus == 'ยังไม่ชำระ' ||
                                widget.session.paymentStatus ==
                                    'หลักฐานไม่ถูกต้อง'
                            ? 'ชำระเงิน'
                            : 'ดูสถานะการชำระเงิน',
                      ),
                    ),
                  ],
                  if (_tab == 1) ...[
                    const Text('ประวัติบิล', style: TextStyle(fontSize: 24)),
                    const SizedBox(height: 24),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.receipt_long_outlined),
                      title: const Text('พฤศจิกายน 2569 • ฿3,850.00'),
                      subtitle: StatusIndicator(
                        widget.session.paymentStatus,
                        prefix: '',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.pushNamed(context, '/bill'),
                    ),
                    const Text('ข้อมูลตัวอย่างมีบิล 1 รายการ'),
                  ],
                  if (_tab == 2) ...[
                    const Icon(Icons.account_circle_outlined, size: 72),
                    const SizedBox(height: 24),
                    Text(
                      '${widget.session.firstName} ${widget.session.lastName}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(height: 24),
                    const InfoCard(
                      children: [
                        Text('หอพักสุขใจ'),
                        Text('ห้อง 204 • อนุมัติแล้ว'),
                      ],
                    ),
                    OutlinedButton(
                      onPressed: () async {
                        if (await confirmAction(
                              context,
                              'ออกจากโหมดทดลอง?',
                              'ข้อมูลทดลองจะถูกรีเซ็ต',
                            ) &&
                            context.mounted) {
                          widget.session.reset();
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/login',
                            (_) => false,
                          );
                        }
                      },
                      child: const Text('ออกจากระบบทดลอง'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (value) => setState(() => _tab = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'หน้าหลัก',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'ประวัติ',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'บัญชี',
          ),
        ],
      ),
    ),
  );
}

class BillLine extends StatelessWidget {
  const BillLine(this.label, this.amount, {super.key});
  final String label;
  final String amount;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(label)),
        const SizedBox(width: 16),
        Text(amount),
      ],
    ),
  );
}

class BillScreen extends StatelessWidget {
  const BillScreen({super.key});
  @override
  Widget build(BuildContext context) => const PreviewPage(
    title: 'รายละเอียดบิล',
    children: [
      Text('พฤศจิกายน 2569 • ห้อง 204', style: TextStyle(fontSize: 22)),
      SizedBox(height: 24),
      InfoCard(
        children: [
          BillLine('ค่าเช่ารายเดือน', '฿3,000.00'),
          Divider(),
          Text('ค่าไฟตามหน่วย'),
          Text('มิเตอร์เดิม 1,200 → ใหม่ 1,275'),
          BillLine('75 หน่วย × 8 บาท', '฿600.00'),
          Divider(),
          BillLine('ค่าน้ำเหมาจ่าย', '฿250.00'),
          BillLine('ค่าปรับ (ยังไม่เกินกำหนด)', '฿0.00'),
          Divider(),
          BillLine('รวมทั้งสิ้น', '฿3,850.00'),
        ],
      ),
      Text(
        'ครบกำหนด 5 พ.ย. 2569\nตัวอย่างนี้คิดค่าปรับ 20 บาทต่อวันเมื่อเกินกำหนด',
      ),
    ],
  );
}

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});
  @override
  Widget build(BuildContext context) => PreviewPage(
    title: 'ชำระเงิน',
    children: [
      const InfoCard(
        children: [
          Text('พฤศจิกายน 2569 • ห้อง 204'),
          Text(
            '฿3,850.00',
            style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
          ),
          Text('ครบกำหนด 5 พ.ย. 2569'),
        ],
      ),
      const Text('สแกน QR เพื่อชำระเงิน', style: TextStyle(fontSize: 20)),
      const SizedBox(height: 16),
      const InfoCard(
        children: [
          Icon(
            Icons.qr_code_2,
            size: 160,
            semanticLabel: 'พื้นที่ตัวอย่าง QR ยังใช้ชำระเงินไม่ได้',
          ),
          Text(
            'QR ตัวอย่าง • ใช้โอนเงินจริงไม่ได้',
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Text('ยอดเงิน ฿3,850.00', textAlign: TextAlign.center),
          Text('ชื่อผู้รับ นายสมชาย ใจดี (สมมติ)', textAlign: TextAlign.center),
        ],
      ),
      OutlinedButton(
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('โหมดทดลอง: ยังไม่มี QR จริงให้บันทึก')),
        ),
        child: const Text('บันทึก QR ลงเครื่อง'),
      ),
      const SizedBox(height: 24),
      const Text('หรือโอนผ่านบัญชีธนาคาร', style: TextStyle(fontSize: 20)),
      const SizedBox(height: 16),
      InfoCard(
        children: [
          const Text('ธนาคารกสิกรไทย (ข้อมูลสมมติ)'),
          const Text('ชื่อบัญชี นายสมชาย ใจดี'),
          const Text('123-4-56789-0', style: TextStyle(fontSize: 22)),
          TextButton.icon(
            onPressed: () async {
              await Clipboard.setData(const ClipboardData(text: '1234567890'));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('คัดลอกเลขบัญชีตัวอย่างแล้ว ห้ามโอนเงินจริง'),
                  ),
                );
              }
            },
            icon: const Icon(Icons.copy),
            label: const Text('คัดลอกเลขบัญชีตัวอย่าง'),
          ),
        ],
      ),
      const Text(
        'ตรวจสอบชื่อผู้รับและยอดเงินก่อนยืนยันการโอน\nหน้านี้เป็นการจำลอง ห้ามโอนเงินจริง',
      ),
      const SizedBox(height: 24),
      FilledButton(
        onPressed: () => Navigator.pushNamed(context, '/receipt'),
        child: const Text('ชำระแล้ว แนบสลิป'),
      ),
    ],
  );
}

class ReceiptScreen extends StatefulWidget {
  const ReceiptScreen({super.key, required this.session});
  final DemoSession session;
  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  bool _selected = false;
  @override
  Widget build(BuildContext context) => PreviewPage(
    title: 'แนบหลักฐาน',
    children: [
      const Text('ห้อง 204 • พฤศจิกายน 2569'),
      const Text('ยอดบิล ฿3,850.00', style: TextStyle(fontSize: 26)),
      const SizedBox(height: 24),
      InfoCard(
        children: [
          Icon(
            _selected ? Icons.receipt_long : Icons.add_photo_alternate_outlined,
            size: 88,
          ),
          const SizedBox(height: 16),
          Text(
            _selected
                ? 'slip-demo.png • หลักฐานจำลอง'
                : 'ยังไม่ได้เลือกหลักฐาน',
            textAlign: TextAlign.center,
          ),
          TextButton(
            onPressed: () => setState(() => _selected = true),
            child: Text(
              _selected ? 'เปลี่ยนเป็นสลิปตัวอย่าง' : 'เลือกสลิปตัวอย่าง',
            ),
          ),
        ],
      ),
      const Text(
        'ต้นแบบนี้ใช้สลิปจำลอง ยังไม่ได้เปิดคลังภาพหรืออัปโหลดไฟล์จริง',
      ),
      const SizedBox(height: 24),
      FilledButton(
        onPressed: !_selected
            ? null
            : () async {
                final confirmed = await showModalBottomSheet<bool>(
                  context: context,
                  isScrollControlled: true,
                  builder: (sheetContext) => SafeArea(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'ยืนยันการส่งหลักฐาน',
                            style: TextStyle(fontSize: 24),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'ยอดบิล ฿3,850.00\nพฤศจิกายน 2569 • ห้อง 204',
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'หลังส่งจะอยู่ในสถานะรอตรวจสอบ',
                            style: TextStyle(color: Color(0xFFFCA5A5)),
                          ),
                          const SizedBox(height: 24),
                          FilledButton(
                            onPressed: () => Navigator.pop(sheetContext, true),
                            child: const Text('ยืนยันการส่ง'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(sheetContext, false),
                            child: const Text('กลับไปตรวจสอบ'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
                if (confirmed == true && context.mounted) {
                  widget.session.paymentStatus = 'รอตรวจสอบ';
                  widget.session.update();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/payment-status',
                    ModalRoute.withName('/home'),
                  );
                }
              },
        child: const Text('ส่งหลักฐาน'),
      ),
    ],
  );
}

class PaymentStatusScreen extends StatelessWidget {
  const PaymentStatusScreen({super.key, required this.session});
  final DemoSession session;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: session,
    builder: (context, _) => PreviewPage(
      title: 'สถานะการชำระเงิน',
      children: [
        Icon(
          statusIcon(session.paymentStatus),
          color: statusColor(session.paymentStatus),
          size: 72,
        ),
        const SizedBox(height: 24),
        Text(
          session.paymentStatus,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            color: statusColor(session.paymentStatus),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 24),
        InfoCard(
          children: [
            const Text('พฤศจิกายน 2569 • ห้อง 204'),
            const Text('ยอดบิล ฿3,850.00'),
            StatusIndicator(session.paymentStatus),
            if (session.paymentStatus == 'หลักฐานไม่ถูกต้อง')
              const Text('เหตุผลตัวอย่าง: ยอดเงินไม่ตรงกับยอดบิล'),
          ],
        ),
        TextButton(
          onPressed: () => showDialog<void>(
            context: context,
            builder: (c) => AlertDialog(
              title: const Text('หลักฐานที่ส่ง (จำลอง)'),
              content: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.receipt_long, size: 96),
                  Text('slip-demo.png'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(c),
                  child: const Text('ปิด'),
                ),
              ],
            ),
          ),
          child: const Text('ดูหลักฐานที่ส่ง'),
        ),
        if (session.paymentStatus == 'หลักฐานไม่ถูกต้อง') ...[
          FilledButton(
            onPressed: () => Navigator.pushNamed(context, '/receipt'),
            child: const Text('แนบหลักฐานใหม่'),
          ),
          const SizedBox(height: 16),
        ],
        OutlinedButton(
          onPressed: () =>
              Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false),
          child: const Text('กลับหน้าหลัก'),
        ),
        if (session.paymentStatus == 'รอตรวจสอบ') ...[
          const SizedBox(height: 32),
          const Text('เครื่องมือทดลองสถานะเจ้าของ'),
          TextButton(
            onPressed: () {
              session.paymentStatus = 'ชำระแล้ว';
              session.update();
            },
            child: const Text('จำลองอนุมัติหลักฐาน'),
          ),
          TextButton(
            onPressed: () {
              session.paymentStatus = 'หลักฐานไม่ถูกต้อง';
              session.update();
            },
            child: const Text('จำลองปฏิเสธหลักฐาน'),
          ),
        ],
      ],
    ),
  );
}
