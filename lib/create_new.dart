import 'package:flutter/material.dart';
import 'next_screen.dart';
class CreateNewScreen extends StatelessWidget {
  const CreateNewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF8E8E93)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Create New',
          style: TextStyle(color: Color(0xFF8E8E93), fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Изображение на заднем плане
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 5, bottom: 16),
              child: Image.asset(
                'assets/images/logo3.png',
                width: screenWidth * 0.4,
                height: screenWidth * 0.4,
                fit: BoxFit.contain,
              ),
            ),
          ),
          // Основное содержимое экрана
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              const Text(
                'Set wallet password',
                style: TextStyle(
                  fontSize: 30,
                  color: Color(0xFF007AFF),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'Used to unlock your wallet',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF8E8E93),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                        color: Colors.transparent,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF015FDF), Color(0xFF1ED2FC)],
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Password',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
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
                                          color: Colors.white,
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                  TextField(
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                                      hintText: 'Please enter the password',
                                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                                      filled: true,
                                      fillColor: Colors.transparent,
                                      border: InputBorder.none,
                                    ),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Confirm Password',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
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
                                          color: Colors.white,
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                  TextField(
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                                      hintText: 'Re-enter the same password',
                                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                                      filled: true,
                                      fillColor: Colors.transparent,
                                      border: InputBorder.none,
                                    ),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 40),
                              Center(
                                child: SizedBox(
                                  width: screenWidth * 0.5,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const NextScreen(),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: const Color(0xFF007AFF),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      minimumSize: const Size(double.infinity, 45),
                                      side: const BorderSide(color: Color(0xFF007AFF)),
                                    ),
                                    child: const Text(
                                      'Next Step',
                                      style: TextStyle(color: Color(0xFF007AFF)),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ],
      ),
    );
  }
}