import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suite/stake.dart';
import 'wallet_screen.dart';  // Импортируем WalletScreen
import 'setting_screen.dart';
import 'import_screen.dart';

class WalletSelectionScreen extends StatefulWidget {
  const WalletSelectionScreen({super.key});

  @override
  _WalletSelectionScreenState createState() => _WalletSelectionScreenState();
}

class _WalletSelectionScreenState extends State<WalletSelectionScreen> {
  List<Map<String, String>> _wallets = [];
  String? _selectedWalletKey;

  @override
  void initState() {
    super.initState();
    _loadWallets();
  }

  Future<void> _loadWallets() async {
    final prefs = await SharedPreferences.getInstance();
    final walletKeys = prefs.getStringList('walletKeys') ?? [];
    final savedWalletKey = prefs.getString('selectedWalletKey');

    if (walletKeys.isNotEmpty) {
      final List<Map<String, String>> wallets = [];

      for (final key in walletKeys) {
        final walletData = prefs.getString(key);

        if (walletData != null) {
          try {
            final wallet = jsonDecode(walletData) as Map<String, dynamic>;
            wallets.add({
              'address': wallet['address'] ?? '',
              'walletKey': key,
              'name': wallet['name'] ?? 'Wallet',
              'privateKey': wallet['privateKey'] ?? '',  // Добавьте privateKey
              'portfolioId': wallet['portfolioId'] ?? '',  // Добавьте portfolioId
            });
          } catch (e) {
            print('Error decoding wallet data for key $key: $e');
          }
        }
      }

      setState(() {
        _wallets = wallets;
        if (savedWalletKey != null && wallets.any((wallet) => wallet['walletKey'] == savedWalletKey)) {
          _selectedWalletKey = savedWalletKey;
        } else if (_wallets.isNotEmpty) {
          _selectedWalletKey = _wallets[0]['walletKey'];
        }
      });
    }
  }

  Future<void> _saveSelectedWalletKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedWalletKey', key);
  }

  String _formatAddress(String address) {
    if (address.length > 10) {
      return '${address.substring(0, 6)}...${address.substring(address.length - 2)}';
    }
    return address;
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.5,
      widthFactor: 1.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Stack(
              children: [
                const Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Suite',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () {
                      if (_selectedWalletKey != null) {
                        final selectedWallet = _wallets.firstWhere(
                                (wallet) => wallet['walletKey'] == _selectedWalletKey);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SettingsScreen(
                              walletKey: selectedWallet['walletKey']!,
                              address: selectedWallet['address']!,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              '${_wallets.length} Wallet${_wallets.length == 1 ? '' : 's'}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _wallets.length,
                itemBuilder: (context, index) {
                  final wallet = _wallets[index];
                  return ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.blue,
                    ),
                    title: Text('Wallet #${index + 1}'),
                    subtitle: Text(_formatAddress(wallet['address'] ?? '')),
                    trailing: _selectedWalletKey == wallet['walletKey']
                        ? const Icon(Icons.check, color: Colors.blue)
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedWalletKey = wallet['walletKey'];
                      });
                      _saveSelectedWalletKey(wallet['walletKey']!);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WalletScreen(
                            privateKey: wallet['privateKey']!,
                            address: wallet['address']!,
                            portfolioId: wallet['portfolioId']!,

                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                            builder: (context) => Stake(),
                        ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text(
                        'Stake',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImportScreen(),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.blue),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text(
                        'Import',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
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
    );
  }
}
