import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Для работы с Clipboard
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suite/warning_screen.dart'; // Для работы с SharedPreferences

class SecurityScreen extends StatefulWidget {
  final String walletKey;
  const SecurityScreen({super.key, required this.walletKey});

  @override
  _SecurityScreenState createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  String? _privateKey;
  String? _mnemonic;
  String? _address;

  @override
  void initState() {
    super.initState();
    _loadWalletData();
  }

  Future<void> _loadWalletData() async {
    final prefs = await SharedPreferences.getInstance();
    final walletData = prefs.getString(widget.walletKey);

    if (walletData != null) {
      try {
        final wallet = jsonDecode(walletData) as Map<String, dynamic>;
        setState(() {
          _address = wallet['address'] ?? 'No address available';
          _privateKey = wallet['privateKey'] ?? 'No private key available';
          _mnemonic = wallet['mnemonic'] ?? 'No mnemonic available';
        });
      } catch (e) {
        print('Error decoding wallet data for key ${widget.walletKey}: $e');
      }
    }
  }

  void _showPrivateKey() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(child: Text('Private Key')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: SelectableText(
                  _privateKey ?? 'No private key available',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_privateKey != null) {
                      Clipboard.setData(ClipboardData(text: _privateKey!));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Private key copied to clipboard')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    backgroundColor: Colors.red.shade100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                  ),
                  child: const Text(
                    'Copy Private Key',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showMnemonic() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(child: Text('Recovery Phrases')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: SelectableText(
                  _mnemonic ?? 'No mnemonic available',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_mnemonic != null) {
                      Clipboard.setData(ClipboardData(text: _mnemonic!));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Mnemonic copied to clipboard')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    backgroundColor: Colors.red.shade100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                  ),
                  child: const Text(
                    'Copy Mnemonic',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: const Text(
                'Settings',
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
                'The security settings of your wallet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8E8E93),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [

                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Password',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Change your wallet login password',
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF8E8E93),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => WarningScreen(),
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.blue.shade100,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6.0),
                              ),
                            ),
                            child: const Text(
                              'Update Password',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Recovery Phrases',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'A recovery phrase grants full access to all wallets generated by it. You can manage and export your recovery phrases.',
                          style: TextStyle(
                            color: Color(0xFF8E8E93),
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: _showMnemonic,
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.red.shade100,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6.0),
                              ),
                            ),
                            child: const Text(
                              'Show the Phrases',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Private Key',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'A private key grants full access to the wallet. Be sure to keep it secure.',
                          style: TextStyle(
                            color: Color(0xFF8E8E93),
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: _showPrivateKey,
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.red.shade100,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6.0),
                              ),
                            ),
                            child: const Text(
                              'Show the Private Key',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
