import 'package:flutter/material.dart';
import 'package:warung_app1/Tugas_13/database/db_helper.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final DbHelper dbHelper = DbHelper();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50, // Very light blue background
      body: SingleChildScrollView(
        // Allows scrolling if keyboard appears
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24.0,
          ), // More generous padding
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch, // Stretch children horizontally
            children: [
              const SizedBox(height: 80), // Space from top
              // Animated Phone (or static icon for simplicity if animation not available)
              Center(
                child: Container(
                  height: 180, // Slightly larger phone area
                  width: 180,
                  decoration: BoxDecoration(
                    color:
                        Colors
                            .blue
                            .shade100, // Light blue background for icon/animation
                    shape: BoxShape.circle, // Circular background
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.shade100.withOpacity(0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Image.network(
                    'http://googleusercontent.com/image_generation_content/0', // Your animated phone image
                    fit: BoxFit.contain, // Ensure the whole image fits
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.phone_android, // Fallback icon if image fails
                        size: 100,
                        color: Colors.blue.shade600,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Welcome Text
              Text(
                'Selamat Datang Kembali!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800, // Darker blue for headings
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Silakan masuk untuk melanjutkan.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 40),

              // Username TextField
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'Nama Pengguna',
                  hintText: 'Masukkan nama pengguna Anda',
                  prefixIcon: Icon(
                    Icons.person_outline,
                    color: Colors.blue.shade600,
                  ), // Icon
                  filled: true,
                  fillColor: Colors.white, // White fill for input fields
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      12,
                    ), // More rounded corners
                    borderSide: BorderSide.none, // No default border
                  ),
                  enabledBorder: OutlineInputBorder(
                    // Border when not focused
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.blue.shade200,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    // Border when focused
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
                keyboardType:
                    TextInputType.emailAddress, // Suggest email keyboard
              ),
              const SizedBox(height: 20),

              // Password TextField
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Kata Sandi',
                  hintText: 'Masukkan kata sandi Anda',
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: Colors.blue.shade600,
                  ), // Icon
                  filled: true,
                  fillColor: Colors.white, // White fill for input fields
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

              // Login Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700, // Dulu 'primary'
                  foregroundColor: Colors.white, // Dulu 'onPrimary'
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
                child: const Text('MASUK'), // Uppercase for emphasis
                onPressed: () async {
                  final user = await dbHelper.loginUser(
                    usernameController.text,
                    passwordController.text,
                  );
                  if (user != null) {
                    Navigator.pushReplacementNamed(context, '/home');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Login gagal! Nama pengguna atau kata sandi salah.',
                        ),
                        backgroundColor: Colors.red.shade600, // Red for error
                        behavior:
                            SnackBarBehavior.floating, // Floating snackbar
                        margin: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 20),

              // Register Button (TextButton)
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: Text.rich(
                  // Use Text.rich for mixed styles
                  TextSpan(
                    text: 'Belum punya akun? ',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
                    children: [
                      TextSpan(
                        text: 'Daftar Sekarang!',
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
              const SizedBox(height: 40), // Space at the bottom
            ],
          ),
        ),
      ),
    );
  }
}
