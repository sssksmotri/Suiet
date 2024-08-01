import 'package:flutter/material.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:web3dart/web3dart.dart'; // Ensure web3dart is included in pubspec.yaml
import 'dart:typed_data';
import 'package:wallet/wallet.dart' as wallet;
import 'edit_screen.dart';

class NextScreen extends StatelessWidget {
  final String mnemonic;
  final String password;

  const NextScreen({required this.mnemonic, required this.password, super.key});

  @override
  Widget build(BuildContext context) {
    final mnemonicWords = mnemonic.split(' ');

    // Log wallet information when the widget is built
    print('Mnemonic: $mnemonic');
    print('Private Key: ${_privateKeyToHex(_generatePrivateKey())}');
    print('Public Key: ${_generatePublicKey()}');
    print('Address: ${_generateAddress()}');

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
                width: MediaQuery.of(context).size.width * 0.4,
                height: MediaQuery.of(context).size.width * 0.4,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Backup Your Wallet',
                style: TextStyle(
                  fontSize: 30,
                  color: Color(0xFF007AFF),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'Copy and save your recovery phrase.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF8E8E93),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
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
                                itemCount: mnemonicWords.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      '${index + 1}. ${mnemonicWords[index]}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 15),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          // Add functionality to copy to clipboard
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(6),
                                            side: BorderSide(color: Colors.white),
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
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => EditScreen(
                                              mnemonic: mnemonic,
                                              password: password,
                                              privateKey: _privateKeyToHex(_generatePrivateKey()),
                                              publicKey: _generatePublicKey(),
                                              address: _generateAddress(),
                                            ),
                                          ),
                                        );
                                      },
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

  Uint8List _generatePrivateKey() {
    final seed = bip39.mnemonicToSeed(mnemonic);
    final masterKey = wallet.ExtendedPrivateKey.master(seed, wallet.xprv);
    final derivedKey = masterKey.forPath("m/44'/60'/0'/0/0") as wallet.ExtendedPrivateKey;
    final privateKey = _bigIntToUint8List(derivedKey.key);

    print('Generated Private Key: ${_privateKeyToHex(privateKey)}'); // Log private key
    print('Generated Seed: ${_seedToHex(seed)}'); // Log private key
    return privateKey;
  }
  String _seedToHex(Uint8List seed) {
    return seed.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  }
  String _generatePublicKey() {
    final privateKey = EthPrivateKey.fromHex(_privateKeyToHex(_generatePrivateKey()));
    final publicKey = privateKey.publicKey;

    print('Generated Public Key: $publicKey'); // Log public key
    return publicKey.toString();
  }

  String _generateAddress() {
    final privateKey = EthPrivateKey.fromHex(_privateKeyToHex(_generatePrivateKey()));
    final address = privateKey.address.hex;

    print('Generated Address: $address'); // Log address
    return address;
  }

  String _privateKeyToHex(Uint8List privateKey) {
    final hex = privateKey.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
    return hex;
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
}