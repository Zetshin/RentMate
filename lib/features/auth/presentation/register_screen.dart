import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  bool _hidePassword = true;
  bool _hideConfirmation = true;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ข้อมูลผ่านการตรวจสอบแล้ว ยังไม่ได้สร้างบัญชีจริง'),
      ),
    );
  }

  Widget _visibilityButton(bool hidden, VoidCallback onPressed, String field) =>
      IconButton(
        tooltip: hidden ? 'แสดง$field' : 'ซ่อน$field',
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        onPressed: onPressed,
        icon: Icon(
          hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('สร้างบัญชี'),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    ),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: AutofillGroup(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'สร้างบัญชีสำหรับเข้าใช้งาน',
                      style: TextStyle(fontSize: 16, color: Color(0xFFB5B5BF)),
                    ),
                    const SizedBox(height: 32),
                    const Text('ชื่อผู้ใช้', style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    TextFormField(
                      key: const Key('register_username'),
                      autofillHints: const [AutofillHints.newUsername],
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                      enableSuggestions: false,
                      autovalidateMode: AutovalidateMode.onUnfocus,
                      decoration: const InputDecoration(
                        hintText: 'กรอกชื่อผู้ใช้',
                        helperText:
                            'อังกฤษเท่านั้น ไม่มีตัวเลข ช่องว่าง หรืออักขระพิเศษ',
                        helperMaxLines: 3,
                        errorMaxLines: 3,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'กรุณากรอกชื่อผู้ใช้';
                        }
                        if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
                          return 'ใช้ตัวอักษรอังกฤษเท่านั้น ไม่มีตัวเลข ช่องว่าง หรืออักขระพิเศษ';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    const Text('รหัสผ่าน', style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    TextFormField(
                      key: const Key('register_password'),
                      controller: _password,
                      obscureText: _hidePassword,
                      autofillHints: const [AutofillHints.newPassword],
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                      enableSuggestions: false,
                      decoration: InputDecoration(
                        hintText: 'กรอกรหัสผ่าน',
                        helperText: 'อย่างน้อย 8 ตัวอักษร',
                        suffixIcon: _visibilityButton(
                          _hidePassword,
                          () => setState(() => _hidePassword = !_hidePassword),
                          'รหัสผ่าน',
                        ),
                      ),
                      validator: (value) => value == null || value.length < 8
                          ? 'กรุณากรอกรหัสผ่านอย่างน้อย 8 ตัวอักษร'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'ยืนยันรหัสผ่าน',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      key: const Key('register_confirmation'),
                      obscureText: _hideConfirmation,
                      autofillHints: const [AutofillHints.newPassword],
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      autocorrect: false,
                      enableSuggestions: false,
                      decoration: InputDecoration(
                        hintText: 'กรอกรหัสผ่านอีกครั้ง',
                        suffixIcon: _visibilityButton(
                          _hideConfirmation,
                          () => setState(
                            () => _hideConfirmation = !_hideConfirmation,
                          ),
                          'การยืนยันรหัสผ่าน',
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'กรุณายืนยันรหัสผ่าน';
                        }
                        return value != _password.text
                            ? 'รหัสผ่านไม่ตรงกัน'
                            : null;
                      },
                    ),
                    const SizedBox(height: 32),
                    FilledButton(
                      onPressed: _submit,
                      child: const Text('สร้างบัญชี'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
