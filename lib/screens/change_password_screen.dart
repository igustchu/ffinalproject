import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final supabase = Supabase.instance.client;

  final passwordController = TextEditingController();

  final confirmPasswordController = TextEditingController();

  bool hidePassword = true;

  bool hideConfirm = true;

  bool loading = false;

  Future<void> changePassword() async {
    final password = passwordController.text.trim();

    final confirm = confirmPasswordController.text.trim();

    if (password.isEmpty || confirm.isEmpty) {
      showMessage("กรุณากรอกรหัสผ่าน");

      return;
    }

    if (password.length < 8) {
      showMessage("รหัสผ่านต้องมีอย่างน้อย 8 ตัวอักษร");

      return;
    }

    if (password != confirm) {
      showMessage("รหัสผ่านไม่ตรงกัน");

      return;
    }

    setState(() {
      loading = true;
    });

    try {
      await supabase.auth.updateUser(UserAttributes(password: password));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("เปลี่ยนรหัสผ่านเรียบร้อย")),
        );

        Navigator.pop(context);
      }
    } on AuthException catch (e) {
      showMessage(e.message);
    } catch (e) {
      showMessage("เกิดข้อผิดพลาด กรุณาลองใหม่");
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffD8EEFF),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, size: 30),

                onPressed: () {
                  Navigator.pop(context);
                },
              ),

              const SizedBox(height: 20),

              const Center(
                child: Text(
                  "เปลี่ยนรหัสผ่าน",

                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 40),

              buildPasswordField(
                "รหัสผ่านใหม่",

                passwordController,

                hidePassword,

                () {
                  setState(() {
                    hidePassword = !hidePassword;
                  });
                },
              ),

              const SizedBox(height: 20),

              buildPasswordField(
                "ยืนยันรหัสผ่าน",

                confirmPasswordController,

                hideConfirm,

                () {
                  setState(() {
                    hideConfirm = !hideConfirm;
                  });
                },
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,

                height: 55,

                child: ElevatedButton(
                  onPressed: loading ? null : changePassword,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff5189C9),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),

                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "บันทึกรหัสผ่านใหม่",

                          style: TextStyle(
                            color: Colors.white,

                            fontSize: 18,

                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPasswordField(
    String label,

    TextEditingController controller,

    bool hide,

    VoidCallback toggle,
  ) {
    return TextField(
      controller: controller,

      obscureText: hide,

      decoration: InputDecoration(
        labelText: label,

        prefixIcon: const Icon(Icons.lock_outline),

        suffixIcon: IconButton(
          icon: Icon(hide ? Icons.visibility : Icons.visibility_off),

          onPressed: toggle,
        ),

        filled: true,

        fillColor: Colors.white,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),

          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
