import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'create_new.dart';
import 'import_screen.dart';
import 'wallet_screen.dart';
import 'history_screen.dart';
import 'dApps_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isWalletCreated = false;
  String _privateKey = '';
  String _address = '';
  String _portfolioId = '';

  @override
  void initState() {
    super.initState();
    _loadWalletData();
  }

  Future<void> _loadWalletData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Получение списка ключей для кошельков
    List<String>? walletKeys = prefs.getStringList('walletKeys');

    if (walletKeys != null && walletKeys.isNotEmpty) {
      // Загрузка данных первого кошелька
      String walletKey = walletKeys.first;
      String? walletDataJson = prefs.getString(walletKey);

      if (walletDataJson != null) {
        Map<String, dynamic> walletData = jsonDecode(walletDataJson);

        setState(() {
          _isWalletCreated = true;
          _privateKey = walletData['privateKey'] ?? '';
          _address = walletData['address'] ?? '';
          _portfolioId = walletData['portfolioId'] ?? '';
        });
        return;
      }
    }

    setState(() {
      _isWalletCreated = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: _isWalletCreated
          ? WalletScreen(
        privateKey: _privateKey,
        address: _address,
        portfolioId: _portfolioId,
      )
          : const WelcomeScreen(),
      routes: {
        '/wallet': (context) => WalletScreen(
          privateKey: _privateKey,
          address: _address,
          portfolioId: _portfolioId,
        ),
        '/create_new': (context) => const CreateNewScreen(),
        '/history': (context) => const HistoryScreen(),
        '/dApps': (context) => const dApps_screen(),
      },
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
                  'Welcome to Suiet',
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
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const CreateNewScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.add, color: Color(0xFF007AFF)),
                              label: const Text(
                                'Create New',
                                style: TextStyle(color: Color(0xFF007AFF)),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                side: const BorderSide(color: Color(0xFF007AFF)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                minimumSize: Size(double.infinity, 45),
                              ),
                            ),
                            const SizedBox(height: 15),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ImportScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.add, color: Colors.white),
                              label: const Text(
                                'Import Wallet',
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                side: const BorderSide(color: Colors.white),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                minimumSize: Size(double.infinity, 45),
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          bottom: 10,
                          right: -30,
                          child: Image.asset(
                            'assets/images/logo2.png',
                            width: 200,
                            height: 200,
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
