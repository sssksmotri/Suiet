import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:web3dart/web3dart.dart';
import 'package:wallet/wallet.dart' as wallet;
import 'package:flutter/services.dart';
import 'edit_screen.dart';
import 'package:web3dart/crypto.dart' as crypto;

class NextScreen extends StatelessWidget {
  final String mnemonic;
  final String password;

  const NextScreen({required this.mnemonic, required this.password, super.key});

  @override
  Widget build(BuildContext context) {
    final mnemonicWords = mnemonic.split(' ');
    final privateKey = _generatePrivateKey();
    final publicKey = _generatePublicKey(privateKey);
    final address = _generateAddress(publicKey);

    // Логируем значения
    print('Mnemonic: $mnemonic');
    print('Private Key (Hex): ${_privateKeyToHex(privateKey)}');
    print('Public Key (Hex): ${_publicKeyToHex(publicKey)}');
    print('Address: $address');

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
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 20),
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
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
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
                                          Clipboard.setData(
                                              ClipboardData(text: mnemonic));
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(content: Text(
                                                'Mnemonic copied to clipboard')),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                6),
                                            side: BorderSide(
                                                color: Colors.white),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12, horizontal: 16),
                                        ),
                                        icon: const Icon(
                                            Icons.copy, color: Colors.white,
                                            size: 16),
                                        label: const Text(
                                          'Copy',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14),
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
                                            builder: (context) =>
                                                EditScreen(
                                                  mnemonic: mnemonic,
                                                  password: password,
                                                  privateKey: _privateKeyToHex(
                                                      privateKey),
                                                  publicKey: _publicKeyToHex(
                                                      publicKey),
                                                  address: address,
                                                ),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: const Color(
                                            0xFF007AFF),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              6),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
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
    if (!bip39.validateMnemonic(mnemonic)) {
      throw FormatException("Invalid mnemonic phrase.");
    }

    final seed = bip39.mnemonicToSeed(mnemonic);
    try {
      final masterKey = wallet.ExtendedPrivateKey.master(seed, wallet.xprv);
      final derivedKey = masterKey.forPath("m/44'/60'/0'/0/0") as wallet
          .ExtendedPrivateKey;
      final privateKey = _bigIntToUint8List(derivedKey.key);
      return privateKey;
    } catch (e) {
      if (e is FormatException) {
        throw FormatException("Failed to generate private key: ${e.message}");
      } else {
        throw Exception("An unexpected error occurred: ${e.toString()}");
      }
    }
  }

  Uint8List _generatePublicKey(Uint8List privateKey) {
    try {
      final ethPrivateKey = EthPrivateKey(privateKey);
      final publicKey = ethPrivateKey.publicKey;
      final publicKeyBytes = publicKey.getEncoded(
          false); // Generate uncompressed public key
      if (publicKeyBytes.length !=
          65) { // Uncompressed public key should be 65 bytes including the prefix
        throw FormatException("Invalid public key length. Expected 65 bytes.");
      }
      return publicKeyBytes.sublist(1); // Remove the prefix byte
    } catch (e) {
      throw Exception("Failed to generate public key: ${e.toString()}");
    }
  }

  String _generateAddress(Uint8List publicKey) {
    try {
      if (publicKey.length != 64) {
        throw FormatException("Invalid public key length. Expected 64 bytes.");
      }

      // Generate the address from the public key (last 20 bytes of the keccak256 hash)
      final addressBytes = crypto.keccak256(publicKey).sublist(12);
      return EthereumAddress(addressBytes).hex;
    } catch (e) {
      throw Exception("Failed to generate address: ${e.toString()}");
    }
  }

  String _privateKeyToHex(Uint8List privateKey) {
    return privateKey.map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
  }

  String _publicKeyToHex(Uint8List publicKey) {
    return publicKey.map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
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
