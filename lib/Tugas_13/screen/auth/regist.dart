import 'package:flutter/material.dart';
import 'package:warung_app1/Tugas_13/Database/db_helper.dart';
import 'package:warung_app1/Tugas_13/model/user_model.dart';

class RegisterScreen extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final DbHelper dbHelper = DbHelper();

  RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50, // Consistent light blue background
      appBar: AppBar(
        title: const Text(
          'Daftar Akun Baru', // More descriptive title
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade700, // Darker blue app bar
        elevation: 0, // Remove shadow for a flatter look
        iconTheme: const IconThemeData(color: Colors.white), // White back arrow
      ),
      body: SingleChildScrollView(
        // Allows scrolling if keyboard appears
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24.0,
            vertical: 40.0,
          ), // Generous padding
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch, // Stretch children horizontally
            children: [
              // Welcome Text
              Text(
                'Buat Akun Anda',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800, // Darker blue for headings
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Bergabunglah dengan kami sekarang!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 40),

              // Username TextField
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'Nama Pengguna',
                  hintText: 'Pilih nama pengguna unik',
                  prefixIcon: Icon(
                    Icons.person_add_alt_1_outlined,
                    color: Colors.blue.shade600,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.blue.shade200,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.blue.shade700,
                      width: 2.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                ),
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 20),

              // Password TextField
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Kata Sandi',
                  hintText: 'Buat kata sandi yang kuat',
                  prefixIcon: Icon(
                    Icons.lock_open_outlined,
                    color: Colors.blue.shade600,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.blue.shade200,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.blue.shade700,
                      width: 2.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 30),

              // Register Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.blue.shade700, // Primary blue for the button
                  foregroundColor: Colors.white, // White text
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                  ), // Larger touch target
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      12,
                    ), // Matching rounded corners
                  ),
                  elevation: 8, // Add a subtle shadow
                  shadowColor: Colors.blue.shade700.withOpacity(0.4),
                ),
                child: const Text('DAFTAR'), // Uppercase for emphasis
                onPressed: () async {
                  if (usernameController.text.isEmpty ||
                      passwordController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Nama pengguna dan kata sandi tidak boleh kosong.',
                        ),
                        backgroundColor:
                            Colors.orange.shade600, // Orange for warning
                        behavior: SnackBarBehavior.floating,
                        margin: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                    return;
                  }

                  await dbHelper.registerUser(
                    User(
                      username: usernameController.text,
                      password: passwordController.text,
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Registrasi berhasil! Silakan masuk.',
                      ),
                      backgroundColor:
                          Colors.green.shade600, // Green for success
                      behavior: SnackBarBehavior.floating,
                      margin: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                  Navigator.pop(context); // Go back to login screen
                },
              ),
              const SizedBox(height: 20),

              // Back to Login button
              TextButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                  ); // Navigate back to the previous screen (Login)
                },
                child: Text.rich(
                  TextSpan(
                    text: 'Sudah punya akun? ',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
                    children: [
                      TextSpan(
                        text: 'Masuk di sini!',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
