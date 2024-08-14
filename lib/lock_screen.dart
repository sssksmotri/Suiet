
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _unlock() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedPassword = prefs.getString('userPassword');

    if (savedPassword != null && savedPassword == _passwordController.text) {
      // Если пароль совпадает, всегда переходим на экран кошелька
      Navigator.pushReplacementNamed(context, '/wallet');
    } else {
      // Вы можете показать сообщение об ошибке, если пароль неверен
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incorrect password')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  const SizedBox(height: 100),
                  Image.asset(
                    'assets/images/logo.png',
                    width: 110,
                    height: 110,
                  ),
                  const SizedBox(height: 20),
                  const GradientText(
                    'Back to Suiet',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                    gradient: LinearGradient(
                      colors: [Color(0xFF015FDF), Color(0xFF1ED2FC)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'The wallet for everyone.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF8E8E93),
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.zero,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: EdgeInsets.zero,
                    child: Container(
                      width: double.infinity,
                      height: 400,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF015FDF), Color(0xFF1ED2FC)],
                          begin: Alignment.centerRight,
                          end: Alignment.centerLeft,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Password',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 6),
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
                                child: TextField(
                                  controller: _passwordController,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 10),
                                    hintText: 'Please enter the password',
                                    hintStyle: TextStyle(
                                        color: Colors.white.withOpacity(0.7)),
                                    filled: true,
                                    fillColor: Colors.transparent,
                                    border: InputBorder.none,
                                  ),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              const SizedBox(height: 15),
                              ElevatedButton.icon(
                                onPressed: _unlock,
                                label: const Text(
                                  'Unlock',
                                  style: TextStyle(color: Color(0xFF007AFF), fontSize: 16),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  side: const BorderSide(
                                      color: Color(0xFF007AFF)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  minimumSize: const Size(double.infinity, 45),
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Center(
                                child: Text(
                                  'Forget Password?',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                            bottom: 16,
                            right: 5,
                            child: Padding(
                              padding:
                              const EdgeInsets.only(right: 5, bottom: 16),
                              child: FittedBox(
                                fit: BoxFit.none,
                                child: Image.asset(
                                  'assets/images/logo2.png',
                                  width:
                                  MediaQuery.of(context).size.width * 0.4,
                                  height:
                                  MediaQuery.of(context).size.width * 0.4,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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
}

class GradientText extends StatelessWidget {
  const GradientText(
      this.text, {
        super.key,
        required this.gradient,
        this.style,
      });

  final String text;
  final TextStyle? style;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) {
        return gradient.createShader(
          Rect.fromLTWH(0, 0, bounds.width, bounds.height),
        );
      },
      child: Text(
        text,
        style: style,
      ),
    );
  }
}