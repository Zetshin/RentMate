import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _hidePassword = true;

  void _message(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));

  void _submit() {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      _message('หน้าตัวอย่าง: ยังไม่ได้เชื่อมระบบเข้าสู่ระบบ');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: (constraints.maxHeight - 64).clamp(0, double.infinity),
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: AutofillGroup(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'RentMate',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B2635),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'จัดการเรื่องเช่าให้ง่ายขึ้น',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFFB5B5BF),
                          ),
                        ),
                        const SizedBox(height: 48),
                        const Text(
                          'ชื่อผู้ใช้',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          key: const Key('username'),
                          style: const TextStyle(fontSize: 16),
                          decoration: const InputDecoration(
                            hintText: 'กรอกชื่อผู้ใช้',
                          ),
                          autofillHints: const [AutofillHints.username],
                          autocorrect: false,
                          enableSuggestions: false,
                          textInputAction: TextInputAction.next,
                          autovalidateMode: AutovalidateMode.onUnfocus,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'กรุณากรอกชื่อผู้ใช้';
                            }
                            if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
                              return 'ใช้ตัวอักษรอังกฤษเท่านั้น ไม่มีช่องว่าง';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        const Text('รหัสผ่าน', style: TextStyle(fontSize: 16)),
                        const SizedBox(height: 8),
                        TextFormField(
                          key: const Key('password'),
                          style: const TextStyle(fontSize: 16),
                          obscureText: _hidePassword,
                          autofillHints: const [AutofillHints.password],
                          autocorrect: false,
                          enableSuggestions: false,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submit(),
                          decoration: InputDecoration(
                            hintText: 'กรอกรหัสผ่าน',
                            suffixIcon: IconButton(
                              tooltip: _hidePassword
                                  ? 'แสดงรหัสผ่าน'
                                  : 'ซ่อนรหัสผ่าน',
                              constraints: const BoxConstraints(
                                minWidth: 48,
                                minHeight: 48,
                              ),
                              onPressed: () => setState(
                                () => _hidePassword = !_hidePassword,
                              ),
                              icon: Icon(
                                _hidePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: const Color(0xFFB5B5BF),
                              ),
                            ),
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? 'กรุณากรอกรหัสผ่าน'
                              : null,
                        ),
                        const SizedBox(height: 32),
                        FilledButton(
                          onPressed: _submit,
                          child: const Text('เข้าสู่ระบบ'),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Text(
                              'ยังไม่มีบัญชี?',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFFB5B5BF),
                              ),
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFFF5F5F4),
                                minimumSize: const Size(48, 48),
                              ),
                              onPressed: () =>
                                  Navigator.of(context).pushNamed('/register'),
                              child: const Text(
                                'สมัครสมาชิก',
                                style: TextStyle(
                                  fontSize: 16,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
