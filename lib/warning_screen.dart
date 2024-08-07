import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Для хранения данных в локальном хранилище

class WarningScreen extends StatefulWidget {
  const WarningScreen({super.key});

  @override
  _WarningScreenState createState() => _WarningScreenState();
}

class _WarningScreenState extends State<WarningScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Метод для сохранения пароля в локальном хранилище
  Future<void> _savePassword(String password) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_password', password);
  }

  // Метод для обработки подтверждения
  void _onConfirm() {
    if (_formKey.currentState?.validate() ?? false) {
      final newPassword = _passwordController.text;
      _savePassword(newPassword).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated successfully')),
        );
        Navigator.pop(context); // Возвращаемся на предыдущий экран
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving password: $error')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Icon(
          Icons.warning,
          color: Colors.red,
          size: 26,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: const Text(
                  'Warning',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.red,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Full control of your wallet',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Anyone with the private key or recovery phrases can have full control of your wallet funds and assets.',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF8E8E93),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Never share with anyone',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const Text(
                'Anyone with the private key or recovery phrases can have full control of your wallet funds and assets.',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF8E8E93),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Suit will never ask for it',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                width: MediaQuery.of(context).size.width - 32,
                decoration: BoxDecoration(
                  color: const Color(0x1A007AFF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Password',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.normal,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Stack(
                      children: [
                        Container(
                          height: 50,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(8),
                            ),
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.blue,
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                            hintText: 'Please enter the password',
                            hintStyle: TextStyle(color: Colors.black.withOpacity(0.4)),
                            filled: true,
                            fillColor: Colors.transparent,
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(color: Colors.black),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password cannot be empty';
                            }
                            // Дополнительные проверки, если необходимо
                            return null;
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context); // Возвращаемся на предыдущий экран
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.blue),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _onConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text(
                        'Confirm',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40), // Отступ от нижнего края экрана
            ],
          ),
        ),
      ),
    );
  }
}
