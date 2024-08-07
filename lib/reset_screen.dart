import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Для работы с SharedPreferences
import 'main.dart';

class ResetScreen extends StatefulWidget {
  const ResetScreen({super.key});

  @override
  _ResetScreenState createState() => _ResetScreenState();
}

class _ResetScreenState extends State<ResetScreen> {
  final TextEditingController _resetController = TextEditingController();
  bool _isResetValid = false;

  Future<void> _resetApp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Очистка всех данных
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const WelcomeScreen()));
  }

  void _validateResetInput(String input) {
    setState(() {
      _isResetValid = input == 'RESET';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF8E8E93)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Settings',
          style: TextStyle(color: Color(0xFF8E8E93), fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: const Text(
                    'Reset Suiet',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: const Text(
                    'Be careful! You may reset your app here.',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8E8E93),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Password',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Suiet will clear all the data and you need to re-import wallets. Input RESET to confirm and reset.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF8E8E93),
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
                        'Please enter RESET to confirm',
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
                          TextField(
                            controller: _resetController,
                            onChanged: _validateResetInput,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                              hintText: 'Enter RESET',
                              hintStyle: TextStyle(color: Colors.black.withOpacity(0.4)),
                              filled: true,
                              fillColor: Colors.transparent,
                              border: InputBorder.none,
                            ),
                            style: const TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 80), // Отступ для размещения кнопки
              ],
            ),
          ),
          Positioned(
            bottom: 30, // Отступ снизу
            left: 16,
            right: 16,
            child: Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isResetValid ? _resetApp : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isResetValid ? Colors.blue : Colors.grey,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text(
                  'Reset Suiet',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}