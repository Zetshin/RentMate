import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../owner_demo.dart';
import '../../../shared/widgets/preview_page.dart';
import '../../../shared/widgets/status_indicator.dart';

class RoomBillHistoryScreen extends StatefulWidget {
  const RoomBillHistoryScreen({super.key, required this.room});
  final OwnerRoom room;
  @override
  State<RoomBillHistoryScreen> createState() => _BillHistoryState();
}

class _BillHistoryState extends State<RoomBillHistoryScreen> {
  RoomBill? _selected;
  @override
  Widget build(BuildContext context) {
    final bills = widget.room.bills;
    final bill = _selected ?? (bills.isEmpty ? null : bills.last);
    final status = bill == null
        ? ''
        : identical(bill, bills.last)
        ? widget.room.status
        : bill.status;
    final today = DateTime.now();
    final lateDays = bill == null || status == 'ชำระแล้ว'
        ? 0
        : DateTime(today.year, today.month, today.day)
              .difference(DateTime(bill.due.year, bill.due.month, bill.due.day))
              .inDays;
    return PreviewPage(
      title: 'ประวัติบิล • ห้อง ${widget.room.number}',
      children: [
        if (bill == null)
          const Text('ยังไม่มีบิลของห้องนี้')
        else ...[
          DropdownButtonFormField<RoomBill>(
            initialValue: bill,
            decoration: const InputDecoration(labelText: 'เลือกเดือนย้อนหลัง'),
            items: bills.reversed
                .map(
                  (b) => DropdownMenuItem(
                    value: b,
                    child: Text(billMonthLabel(b.month)),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => _selected = v),
          ),
          const SizedBox(height: 24),
          InfoCard(
            children: [
              Text(
                billMonthLabel(bill.month),
                style: const TextStyle(fontSize: 24),
              ),
              StatusIndicator(status),
              const SizedBox(height: 16),
              Text('ค่าเช่า ฿${bill.rent.toStringAsFixed(2)}'),
              const Divider(),
              Text('ค่าไฟ ฿${bill.electricity.toStringAsFixed(2)}'),
              Text(bill.electricityDetail),
              const Divider(),
              Text('ค่าน้ำ ฿${bill.water.toStringAsFixed(2)}'),
              Text(bill.waterDetail),
              const Divider(),
              Text(
                'ยอดบิล ฿${bill.total.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 24),
              ),
              Text(
                'ครบกำหนด ${bill.due.day}/${bill.due.month}/${bill.due.year + 543}',
              ),
              if (lateDays > 0)
                Text(
                  'เกินกำหนด $lateDays วัน',
                  style: const TextStyle(color: Color(0xFFFCA5A5)),
                ),
            ],
          ),
          const Text(
            'ยอดนี้เป็นยอดตอนออกบิล ค่าปรับยังไม่คำนวณอัตโนมัติในต้นแบบ',
          ),
        ],
      ],
    );
  }
}

Widget numberField(
  String label,
  double initial,
  ValueChanged<double> save, {
  ValueChanged<String>? onChanged,
}) => Padding(
  padding: const EdgeInsets.only(bottom: 20),
  child: TextFormField(
    initialValue: initial.toString(),
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    decoration: InputDecoration(labelText: label),
    validator: (v) {
      final n = double.tryParse(v ?? '');
      return n == null || !n.isFinite || n < 0
          ? 'กรอกจำนวนตั้งแต่ 0 ขึ้นไป'
          : null;
    },
    onSaved: (v) => save(double.parse(v!)),
    onChanged: onChanged,
  ),
);

class RoomRatesScreen extends StatefulWidget {
  const RoomRatesScreen({super.key, required this.owner, required this.room});
  final OwnerDemo owner;
  final OwnerRoom room;
  @override
  State<RoomRatesScreen> createState() => _RoomRatesState();
}

class _RoomRatesState extends State<RoomRatesScreen> {
  final _form = GlobalKey<FormState>();
  late bool _electricFlat = widget.room.electricityFlat;
  late bool _waterFlat = widget.room.waterFlat;
  late bool _penalty = widget.room.penalty > 0;
  late double _rent = widget.room.rent,
      _electric = widget.room.electricityRate,
      _water = widget.room.waterRate,
      _fine = widget.room.penalty;
  @override
  Widget build(BuildContext context) => PreviewPage(
    title: 'ตั้งค่าค่าเช่าและเรท',
    children: [
      const Text('ค่าที่บันทึกใช้กับบิลใหม่ บิลที่ออกแล้วไม่เปลี่ยนตาม'),
      const SizedBox(height: 24),
      Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            numberField('ค่าเช่ารายเดือน (บาท)', _rent, (v) => _rent = v),
            DropdownButtonFormField<bool>(
              initialValue: _electricFlat,
              decoration: const InputDecoration(labelText: 'วิธีคิดค่าไฟ'),
              items: const [
                DropdownMenuItem(value: false, child: Text('ตามหน่วย')),
                DropdownMenuItem(value: true, child: Text('เหมาจ่าย')),
              ],
              onChanged: (v) => setState(() => _electricFlat = v!),
            ),
            const SizedBox(height: 20),
            numberField(
              'ค่าไฟ (บาท${_electricFlat ? '/เดือน' : '/หน่วย'})',
              _electric,
              (v) => _electric = v,
            ),
            DropdownButtonFormField<bool>(
              initialValue: _waterFlat,
              decoration: const InputDecoration(labelText: 'วิธีคิดค่าน้ำ'),
              items: const [
                DropdownMenuItem(value: false, child: Text('ตามหน่วย')),
                DropdownMenuItem(value: true, child: Text('เหมาจ่าย')),
              ],
              onChanged: (v) => setState(() => _waterFlat = v!),
            ),
            const SizedBox(height: 20),
            numberField(
              'ค่าน้ำ (บาท${_waterFlat ? '/เดือน' : '/หน่วย'})',
              _water,
              (v) => _water = v,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('คิดค่าปรับรายวัน'),
              value: _penalty,
              onChanged: (v) => setState(() => _penalty = v),
            ),
            if (_penalty)
              numberField('ค่าปรับ (บาท/วัน)', _fine, (v) => _fine = v),
            FilledButton(
              onPressed: () {
                if (!_form.currentState!.validate()) return;
                _form.currentState!.save();
                widget.room.rent = _rent;
                widget.room.electricityRate = _electric;
                widget.room.waterRate = _water;
                widget.room.electricityFlat = _electricFlat;
                widget.room.waterFlat = _waterFlat;
                widget.room.penalty = _penalty ? _fine : 0;
                widget.owner.update();
                Navigator.pop(context);
              },
              child: const Text('บันทึกเรท'),
            ),
          ],
        ),
      ),
    ],
  );
}

class OwnerBillScreen extends StatefulWidget {
  const OwnerBillScreen({super.key, required this.owner, required this.room});
  final OwnerDemo owner;
  final OwnerRoom room;
  @override
  State<OwnerBillScreen> createState() => _OwnerBillState();
}

class _OwnerBillState extends State<OwnerBillScreen> {
  final _form = GlobalKey<FormState>();
  late double _electric = widget.room.previousElectricity,
      _water = widget.room.previousWater;
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime? _due;
  Widget _meterSummary(bool electricity) {
    final room = widget.room;
    final previous = electricity
        ? room.previousElectricity
        : room.previousWater;
    final reading = electricity ? _electric : _water;
    final rate = electricity ? room.electricityRate : room.waterRate;
    final valid = reading.isFinite && reading >= previous;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Text(
        valid
            ? 'ใช้ ${(reading - previous).toStringAsFixed(2)} หน่วย × $rate บาท = ฿${((reading - previous) * rate).toStringAsFixed(2)}'
            : 'มิเตอร์ใหม่ต้องเป็นตัวเลขและไม่น้อยกว่ามิเตอร์เดิม',
        style: TextStyle(
          color: valid ? const Color(0xFF4ADE80) : const Color(0xFFFCA5A5),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => PreviewPage(
    title: 'ออกบิล • ห้อง ${widget.room.number}',
    children: [
      Text(
        'บิล${billMonthLabel(_month)}',
        style: const TextStyle(fontSize: 24),
      ),
      const SizedBox(height: 24),
      DropdownButtonFormField<DateTime>(
        initialValue: _month,
        decoration: const InputDecoration(labelText: 'เดือนของบิล'),
        items: List.generate(13, (i) {
          final now = DateTime.now();
          final month = DateTime(now.year, now.month + i);
          return DropdownMenuItem(
            value: month,
            child: Text(billMonthLabel(month)),
          );
        }),
        onChanged: (v) => setState(() => _month = v!),
      ),
      const SizedBox(height: 24),
      Text('ค่าเช่า ฿${widget.room.rent.toStringAsFixed(2)}'),
      const SizedBox(height: 24),
      Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!widget.room.electricityFlat) ...[
              Text('มิเตอร์ไฟเดิม ${widget.room.previousElectricity}'),
              const SizedBox(height: 20),
              numberField(
                'มิเตอร์ไฟใหม่',
                widget.room.previousElectricity,
                (v) => _electric = v,
                onChanged: (v) => setState(
                  () => _electric = double.tryParse(v) ?? double.nan,
                ),
              ),
              _meterSummary(true),
            ] else
              Text('ค่าไฟเหมาจ่าย ฿${widget.room.electricityRate}'),
            if (!widget.room.waterFlat) ...[
              Text('มิเตอร์น้ำเดิม ${widget.room.previousWater}'),
              const SizedBox(height: 20),
              numberField(
                'มิเตอร์น้ำใหม่',
                widget.room.previousWater,
                (v) => _water = v,
                onChanged: (v) =>
                    setState(() => _water = double.tryParse(v) ?? double.nan),
              ),
              _meterSummary(false),
            ] else
              Text('ค่าน้ำเหมาจ่าย ฿${widget.room.waterRate}'),
            const SizedBox(height: 24),
            Text(
              'ค่าปรับ ${widget.room.penalty} บาท/วัน • บิลใหม่นี้ค่าปรับ 0 บาท',
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              icon: const Icon(Icons.calendar_month),
              label: Text(
                _due == null
                    ? 'เลือกวันครบกำหนด'
                    : '${_due!.day}/${_due!.month}/${_due!.year + 543}',
              ),
              onPressed: () async {
                final now = DateTime.now();
                final date = await showDatePicker(
                  context: context,
                  initialDate: now,
                  firstDate: DateTime(now.year - 1),
                  lastDate: DateTime(now.year + 2),
                );
                if (date != null && mounted) setState(() => _due = date);
              },
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () async {
                if (!_form.currentState!.validate()) return;
                _form.currentState!.save();
                if (widget.room.bills.any((b) => b.month == _month) ||
                    (widget.room.bills.isNotEmpty &&
                        _month.isBefore(widget.room.bills.last.month))) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'เดือนนี้มีบิลแล้ว หรือเก่ากว่าบิลล่าสุด กรุณาเลือกเดือนถัดไป',
                      ),
                    ),
                  );
                  return;
                }
                if (_due == null ||
                    (!widget.room.electricityFlat &&
                        _electric < widget.room.previousElectricity) ||
                    (!widget.room.waterFlat &&
                        _water < widget.room.previousWater)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'เลือกวันครบกำหนด และกรอกมิเตอร์ใหม่ไม่น้อยกว่าเดิม',
                      ),
                    ),
                  );
                  return;
                }
                final electricity = widget.room.electricityFlat
                    ? widget.room.electricityRate
                    : (_electric - widget.room.previousElectricity) *
                          widget.room.electricityRate;
                final water = widget.room.waterFlat
                    ? widget.room.waterRate
                    : (_water - widget.room.previousWater) *
                          widget.room.waterRate;
                final total = widget.room.rent + electricity + water;
                if (await confirmAction(
                      context,
                      'ตรวจสอบบิลก่อนออก',
                      '${billMonthLabel(_month)}\nค่าเช่า ฿${widget.room.rent}\nค่าไฟ ฿$electricity\nค่าน้ำ ฿$water\nรวม ฿${total.toStringAsFixed(2)}\nครบกำหนด ${_due!.day}/${_due!.month}/${_due!.year + 543}',
                    ) &&
                    context.mounted) {
                  widget.room.billTotal = total;
                  if (widget.room.bills.isNotEmpty) {
                    widget.room.bills.last.status = widget.room.status;
                  }
                  widget.room.bills.add(
                    RoomBill(
                      month: _month,
                      rent: widget.room.rent,
                      electricity: electricity,
                      water: water,
                      due: _due!,
                      electricityDetail: widget.room.electricityFlat
                          ? 'เหมาจ่าย'
                          : '${widget.room.previousElectricity} → $_electric • ${_electric - widget.room.previousElectricity} หน่วย × ${widget.room.electricityRate} บาท',
                      waterDetail: widget.room.waterFlat
                          ? 'เหมาจ่าย'
                          : '${widget.room.previousWater} → $_water • ${_water - widget.room.previousWater} หน่วย × ${widget.room.waterRate} บาท',
                    ),
                  );
                  widget.room.status = 'ยังไม่ชำระ';
                  widget.room.dueDate =
                      '${_due!.day}/${_due!.month}/${_due!.year + 543}';
                  widget.room.previousElectricity = _electric;
                  widget.room.previousWater = _water;
                  widget.owner.update();
                  Navigator.pop(context);
                }
              },
              child: const Text('ตรวจสอบบิลก่อนออก'),
            ),
          ],
        ),
      ),
    ],
  );
}

class PaymentSettingsScreen extends StatefulWidget {
  const PaymentSettingsScreen({super.key, required this.owner});
  final OwnerDemo owner;
  @override
  State<PaymentSettingsScreen> createState() => _PaymentSettingsState();
}

class _PaymentSettingsState extends State<PaymentSettingsScreen> {
  final _form = GlobalKey<FormState>();
  late String _bank = widget.owner.bank,
      _name = widget.owner.accountName,
      _number = widget.owner.accountNumber;
  late bool _qr = widget.owner.sampleQr;
  @override
  Widget build(BuildContext context) => PreviewPage(
    title: 'ช่องทางรับเงิน',
    children: [
      Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              initialValue: _bank,
              decoration: const InputDecoration(labelText: 'ธนาคาร'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'กรุณากรอกธนาคาร' : null,
              onSaved: (v) => _bank = v!.trim(),
            ),
            const SizedBox(height: 24),
            TextFormField(
              initialValue: _name,
              decoration: const InputDecoration(labelText: 'ชื่อบัญชี'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'กรุณากรอกชื่อบัญชี' : null,
              onSaved: (v) => _name = v!.trim(),
            ),
            const SizedBox(height: 24),
            TextFormField(
              initialValue: _number,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'เลขบัญชี'),
              validator: (v) => v == null || !RegExp(r'^[0-9-]+$').hasMatch(v)
                  ? 'กรอกเลขบัญชีเป็นตัวเลข'
                  : null,
              onSaved: (v) => _number = v!,
            ),
            const SizedBox(height: 24),
            if (_qr) const Icon(Icons.qr_code_2, size: 120),
            OutlinedButton.icon(
              onPressed: () => setState(() => _qr = !_qr),
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: Text(_qr ? 'ลบ QR ตัวอย่าง' : 'เพิ่ม QR ตัวอย่าง'),
            ),
            const Text(
              'ต้นแบบใช้รูป QR จำลอง ยังไม่เปิดคลังภาพหรือใช้รับเงินจริง',
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                if (!_form.currentState!.validate()) return;
                _form.currentState!.save();
                widget.owner.bank = _bank;
                widget.owner.accountName = _name;
                widget.owner.accountNumber = _number;
                widget.owner.sampleQr = _qr;
                widget.owner.update();
                Navigator.pop(context);
              },
              child: const Text('บันทึกช่องทางรับเงิน'),
            ),
          ],
        ),
      ),
    ],
  );
}

class ReviewReceiptScreen extends StatelessWidget {
  const ReviewReceiptScreen({
    super.key,
    required this.owner,
    required this.room,
  });
  final OwnerDemo owner;
  final OwnerRoom room;
  @override
  Widget build(BuildContext context) => PreviewPage(
    title: 'ตรวจหลักฐาน • ห้อง ${room.number}',
    children: [
      Text(room.tenant ?? '', style: const TextStyle(fontSize: 24)),
      Text('ยอดบิล ฿${room.billTotal?.toStringAsFixed(2)}'),
      const SizedBox(height: 24),
      const InfoCard(
        children: [
          Icon(Icons.receipt_long, size: 120),
          Text('หลักฐานจำลอง ไม่ใช่สลิปจริง'),
        ],
      ),
      const Text('ตรวจชื่อผู้รับ ยอดเงิน และวันเวลาโอนก่อนยืนยัน'),
      const SizedBox(height: 24),
      FilledButton(
        onPressed: () async {
          if (await confirmAction(
                context,
                'ยืนยันรับชำระ?',
                'เปลี่ยนบิลห้อง ${room.number} เป็นชำระแล้ว',
              ) &&
              context.mounted) {
            room.status = 'ชำระแล้ว';
            owner.update();
            Navigator.pop(context);
          }
        },
        child: const Text('ยืนยันรับชำระ'),
      ),
      const SizedBox(height: 16),
      OutlinedButton(
        onPressed: () async {
          final form = GlobalKey<FormState>();
          String reason = '';
          final rejected = await showDialog<bool>(
            context: context,
            builder: (c) => AlertDialog(
              title: const Text('เหตุผลที่ไม่อนุมัติ'),
              content: Form(
                key: form,
                child: TextFormField(
                  decoration: const InputDecoration(labelText: 'เหตุผล'),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'กรุณาระบุเหตุผล' : null,
                  onSaved: (v) => reason = v!.trim(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(c, false),
                  child: const Text('กลับ'),
                ),
                TextButton(
                  onPressed: () {
                    if (form.currentState!.validate()) {
                      form.currentState!.save();
                      Navigator.pop(c, true);
                    }
                  },
                  child: const Text('ปฏิเสธหลักฐาน'),
                ),
              ],
            ),
          );
          if (rejected == true && context.mounted) {
            room.status = 'หลักฐานไม่ถูกต้อง';
            owner.update();
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('ไม่อนุมัติ: $reason')));
            Navigator.pop(context);
          }
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFFCA5A5),
        ),
        child: const Text('หลักฐานไม่ถูกต้อง'),
      ),
    ],
  );
}

class StartScreen extends StatelessWidget {
  const StartScreen({super.key, required this.owner});
  final OwnerDemo owner;
  @override
  Widget build(BuildContext context) => PreviewPage(
    title: 'เริ่มต้นใช้งาน RentMate',
    children: [
      const InfoCard(
        children: [
          Icon(Icons.key_outlined, size: 48),
          SizedBox(height: 16),
          Text('ฉันเป็นผู้เช่า', style: TextStyle(fontSize: 24)),
          Text('มีรหัสเชิญจากเจ้าของที่พัก'),
        ],
      ),
      FilledButton(
        onPressed: () => Navigator.pushNamed(context, '/join'),
        child: const Text('เข้าร่วมห้องพัก'),
      ),
      const SizedBox(height: 32),
      const InfoCard(
        children: [
          Icon(Icons.apartment, size: 48),
          SizedBox(height: 16),
          Text('ฉันเป็นเจ้าของที่พัก', style: TextStyle(fontSize: 24)),
          Text('เพิ่มห้องและจัดการบิลของผู้เช่า'),
        ],
      ),
      FilledButton(
        onPressed: () => Navigator.pushNamed(
          context,
          owner.propertyName.isEmpty ? '/create-property' : '/owner',
        ),
        child: Text(
          owner.propertyName.isEmpty
              ? 'สร้างที่พักของฉัน'
              : 'จัดการที่พักของฉัน',
        ),
      ),
    ],
  );
}

class CreatePropertyScreen extends StatefulWidget {
  const CreatePropertyScreen({super.key, required this.owner});
  final OwnerDemo owner;
  @override
  State<CreatePropertyScreen> createState() => _CreatePropertyState();
}

class _CreatePropertyState extends State<CreatePropertyScreen> {
  final _form = GlobalKey<FormState>();
  String _name = '';
  @override
  Widget build(BuildContext context) => PreviewPage(
    title: 'สร้างที่พักของฉัน',
    children: [
      Form(
        key: _form,
        child: TextFormField(
          key: const Key('property_name'),
          decoration: const InputDecoration(labelText: 'ชื่อที่พัก'),
          validator: (v) =>
              v == null || v.trim().isEmpty ? 'กรุณากรอกชื่อที่พัก' : null,
          onSaved: (v) => _name = v!.trim(),
        ),
      ),
      const SizedBox(height: 32),
      FilledButton(
        onPressed: () {
          if (!_form.currentState!.validate()) return;
          _form.currentState!.save();
          widget.owner.propertyName = _name;
          Navigator.pushNamedAndRemoveUntil(context, '/owner', (_) => false);
        },
        child: const Text('สร้างที่พัก'),
      ),
    ],
  );
}

class OwnerHomeScreen extends StatefulWidget {
  const OwnerHomeScreen({super.key, required this.owner});
  final OwnerDemo owner;
  @override
  State<OwnerHomeScreen> createState() => _OwnerHomeState();
}

class _OwnerHomeState extends State<OwnerHomeScreen> {
  int _tab = 0;
  String _filter = 'ทั้งหมด';
  void _open(OwnerRoom room) => Navigator.push(
    context,
    MaterialPageRoute<void>(
      builder: (_) => OwnerRoomScreen(owner: widget.owner, room: room),
    ),
  );
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.owner,
    builder: (context, _) {
      final rooms = widget.owner.rooms
          .where(
            (r) => _tab == 1
                ? r.status == 'รอตรวจสอบ'
                : _filter == 'รอตรวจ'
                ? r.status == 'รอตรวจสอบ'
                : _filter == 'ยังไม่ชำระ'
                ? r.status == 'ยังไม่ชำระ'
                : true,
          )
          .toList();
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.owner.propertyName),
          actions: [
            IconButton(
              tooltip: 'ช่องทางรับเงิน',
              icon: const Icon(Icons.account_balance_outlined),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => PaymentSettingsScreen(owner: widget.owner),
                ),
              ),
            ),
          ],
        ),
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
                      'โหมดทดลอง • เจ้าของที่พัก • ข้อมูลไม่บันทึกถาวร',
                    ),
                    const SizedBox(height: 24),
                    if (_tab < 2) ...[
                      Text(
                        _tab == 0
                            ? 'ห้องพัก • พฤศจิกายน 2569'
                            : 'หลักฐานรอตรวจ',
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          Text('ยังไม่ชำระ ${widget.owner.rooms.where((r) => r.status == 'ยังไม่ชำระ').length}',
                            style: const TextStyle(color: Color(0xFFFCA5A5))),
                          Text('รอตรวจ ${widget.owner.rooms.where((r) => r.status == 'รอตรวจสอบ').length}',
                            style: const TextStyle(color: Color(0xFFFACC15))),
                          Text('ชำระแล้ว ${widget.owner.rooms.where((r) => r.status == 'ชำระแล้ว').length}',
                            style: const TextStyle(color: Color(0xFF4ADE80))),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_tab == 0) ...[
                        Wrap(
                          spacing: 8,
                          children: ['ทั้งหมด', 'รอตรวจ', 'ยังไม่ชำระ']
                              .map(
                                (f) => ChoiceChip(
                                  label: Text(f),
                                  selected: _filter == f,
                                  onSelected: (_) =>
                                      setState(() => _filter = f),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  AddRoomScreen(owner: widget.owner),
                            ),
                          ),
                          icon: const Icon(Icons.add),
                          label: const Text('เพิ่มห้อง'),
                        ),
                        const SizedBox(height: 24),
                      ],
                      if (rooms.isEmpty)
                        Text(
                          _tab == 1
                              ? 'ไม่มีหลักฐานรอตรวจ'
                              : 'ไม่มีห้องในรายการนี้ เพิ่มห้องเพื่อเริ่มต้น',
                        ),
                      ...rooms.map(
                        (r) => Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => _open(r),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'ห้อง ${r.number}',
                                          style: const TextStyle(fontSize: 22),
                                        ),
                                      ),
                                      const Icon(Icons.chevron_right),
                                    ],
                                  ),
                                  Text(r.tenant ?? 'ยังไม่มีผู้เช่า'),
                                  if (r.requestName != null)
                                    const StatusIndicator('รออนุมัติ'),
                                  if (r.billTotal != null)
                                    Text('฿${r.billTotal!.toStringAsFixed(2)}'),
                                  if (r.billTotal != null)
                                    StatusIndicator(r.status)
                                  else
                                    const Text('ยังไม่มีบิล'),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      const Icon(Icons.apartment, size: 72),
                      const SizedBox(height: 24),
                      const Text(
                        'เจ้าของที่พัก',
                        style: TextStyle(fontSize: 24),
                      ),
                      Text(widget.owner.propertyName),
                      const SizedBox(height: 24),
                      OutlinedButton(
                        onPressed: () => Navigator.pushNamed(context, '/start'),
                        child: const Text('สลับบทบาท'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/login',
                          (_) => false,
                        ),
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
          onDestinationSelected: (v) => setState(() => _tab = v),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'หน้าหลัก',
            ),
            NavigationDestination(
              icon: Icon(Icons.fact_check_outlined),
              selectedIcon: Icon(Icons.fact_check),
              label: 'ตรวจสลิป',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'บัญชี',
            ),
          ],
        ),
      );
    },
  );
}

class AddRoomScreen extends StatefulWidget {
  const AddRoomScreen({super.key, required this.owner});
  final OwnerDemo owner;
  @override
  State<AddRoomScreen> createState() => _AddRoomState();
}

class _AddRoomState extends State<AddRoomScreen> {
  final _form = GlobalKey<FormState>();
  String _number = '';
  @override
  Widget build(BuildContext context) => PreviewPage(
    title: 'เพิ่มห้อง',
    children: [
      Form(
        key: _form,
        child: TextFormField(
          key: const Key('room_number'),
          decoration: const InputDecoration(labelText: 'เลขห้อง / ชื่อห้อง'),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'กรุณากรอกเลขห้อง';
            return widget.owner.rooms.any(
                  (r) => r.number.toLowerCase() == v.trim().toLowerCase(),
                )
                ? 'มีห้องนี้แล้ว'
                : null;
          },
          onSaved: (v) => _number = v!.trim(),
        ),
      ),
      const SizedBox(height: 32),
      FilledButton(
        onPressed: () {
          if (!_form.currentState!.validate()) return;
          _form.currentState!.save();
          final room = widget.owner.addRoom(_number);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute<void>(
              builder: (_) => OwnerRoomScreen(owner: widget.owner, room: room),
            ),
          );
        },
        child: const Text('เพิ่มห้อง'),
      ),
    ],
  );
}

class OwnerRoomScreen extends StatelessWidget {
  const OwnerRoomScreen({super.key, required this.owner, required this.room});
  final OwnerDemo owner;
  final OwnerRoom room;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: owner,
    builder: (context, _) => PreviewPage(
      title: 'ห้อง ${room.number}',
      children: [
        if (room.tenant == null) ...[
          const Text('ยังไม่มีผู้เช่า', style: TextStyle(fontSize: 24)),
          const SizedBox(height: 24),
          InfoCard(
            children: [
              const Text('รหัสเชิญผู้เช่า'),
              Row(
                children: [
                  Expanded(
                    child: SelectableText(
                      room.code,
                      style: const TextStyle(fontSize: 26),
                    ),
                  ),
                  IconButton(
                    tooltip: 'คัดลอกรหัสเชิญ',
                    icon: const Icon(Icons.copy),
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: room.code));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('คัดลอกรหัสเชิญแล้ว')),
                        );
                      }
                    },
                  ),
                ],
              ),
              const Text(
                'รหัสสำหรับทดลองในแอปนี้ ยังส่งให้ผู้เช่าใช้งานจริงไม่ได้',
              ),
            ],
          ),
          if (room.requestName == null)
            TextButton(
              onPressed: () {
                room.requestName = 'สมชาย ใจดี';
                owner.update();
              },
              child: const Text('เครื่องมือทดลอง: จำลองคำขอเข้าห้อง'),
            ),
          if (room.requestName != null)
            InfoCard(
              children: [
                Text(room.requestName!),
                const StatusIndicator('รออนุมัติ'),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () async {
                    if (await confirmAction(
                          context,
                          'อนุมัติผู้เช่า?',
                          'ยืนยันให้ ${room.requestName} เข้าห้อง ${room.number}',
                        ) &&
                        context.mounted) {
                      room.tenant = room.requestName;
                      room.requestName = null;
                      owner.update();
                    }
                  },
                  child: const Text('อนุมัติผู้เช่า'),
                ),
                TextButton(
                  onPressed: () {
                    room.requestName = null;
                    owner.update();
                  },
                  child: const Text('ปฏิเสธคำขอ'),
                ),
              ],
            ),
        ] else ...[
          Text(room.tenant!, style: const TextStyle(fontSize: 24)),
          const Text(
            'อนุมัติแล้ว • รหัสเชิญปิดใช้งาน',
            style: TextStyle(color: Color(0xFF4ADE80)),
          ),
          const SizedBox(height: 24),
          InfoCard(
            children: [
              Text(
                room.bills.isEmpty
                    ? 'บิลรายเดือน'
                    : 'บิล${billMonthLabel(room.bills.last.month)}',
              ),
              if (room.billTotal == null)
                const Text('ยังไม่มีบิล')
              else ...[
                Text(
                  '฿${room.billTotal!.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 30),
                ),
                StatusIndicator(room.status),
                Text('ครบกำหนด ${room.dueDate}'),
              ],
            ],
          ),
          if (room.billTotal == null || room.status == 'ชำระแล้ว')
            FilledButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => OwnerBillScreen(owner: owner, room: room),
                ),
              ),
              child: const Text('กรอกมิเตอร์และออกบิล'),
            ),
          if (room.status == 'ยังไม่ชำระ')
            TextButton(
              onPressed: () {
                room.status = 'รอตรวจสอบ';
                owner.update();
              },
              child: const Text('เครื่องมือทดลอง: จำลองผู้เช่าส่งสลิป'),
            ),
          if (room.status == 'รอตรวจสอบ')
            FilledButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => ReviewReceiptScreen(owner: owner, room: room),
                ),
              ),
              child: const Text('ตรวจหลักฐาน'),
            ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => RoomBillHistoryScreen(room: room),
              ),
            ),
            icon: const Icon(Icons.history),
            label: const Text('ประวัติบิลของห้อง'),
          ),
          const SizedBox(height: 16),
        ],
        OutlinedButton.icon(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => RoomRatesScreen(owner: owner, room: room),
            ),
          ),
          icon: const Icon(Icons.tune),
          label: const Text('ตั้งค่าค่าเช่าและเรท'),
        ),
      ],
    ),
  );
}
