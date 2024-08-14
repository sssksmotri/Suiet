import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';
import 'wallet_selection.dart';
import 'selection_token_screen.dart';
import 'dart:convert';
import 'main_net_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WalletScreen extends StatefulWidget {
  final String privateKey;
  final String address;
  final String portfolioId;

  const WalletScreen({
    Key? key,
    required this.privateKey,
    required this.address,
    required this.portfolioId,
  }) : super(key: key);

  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  int _selectedIndex = 0;
  String balance = '0.00'; // Example balance in dollars
  double ethToUsd = 0.0; // ETH/USD rate
  Timer? _timer;
  late Web3Client _client;
  late String _walletAddress;
  String _walletName = 'Wallet #1'; // Default name
  List<String> walletKeys = []; // List to store wallet keys

  @override
  void initState() {
    super.initState();
    _client = Web3Client('https://mainnet.infura.io/v3/YOUR_INFURA_PROJECT_ID', http.Client());
    _walletAddress = widget.address;
    _fetchWalletName();
    _fetchEthToUsd();
    _updateBalance();
    _timer = Timer.periodic(Duration(minutes: 5), (Timer timer) {
      _updateBalance();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _client.dispose();
    super.dispose();
  }

  Future<void> _fetchWalletName() async {
    final prefs = await SharedPreferences.getInstance();
    walletKeys = prefs.getStringList('walletKeys') ?? [];

    final walletData = walletKeys
        .map((key) => prefs.getString(key))
        .firstWhere(
          (data) => data != null && jsonDecode(data!)['address'] == _walletAddress,
      orElse: () => null,
    );

    if (walletData != null) {
      final wallet = jsonDecode(walletData) as Map<String, dynamic>;
      setState(() {
        _walletName = wallet['name'] ?? 'Wallet';
      });
    }
  }

  Future<void> _fetchEthToUsd() async {
    try {
      final response = await http.get(Uri.parse('https://api.coingecko.com/api/v3/simple/price?ids=ethereum&vs_currencies=usd'));
      if (response.statusCode == 200) {
        final data = response.body;
        final price = RegExp(r'"ethereum":{"usd":(\d+\.\d+)}').firstMatch(data)?.group(1);
        if (price != null) {
          setState(() {
            ethToUsd = double.parse(price);
          });
        }
      } else {
        throw Exception('Failed to load ETH price');
      }
    } catch (e) {
      print('Error fetching ETH price: $e');
    }
  }

  Future<void> _updateBalance() async {
    try {
      final address = EthereumAddress.fromHex(_walletAddress);
      final result = await _client.getBalance(address);
      final balanceInEther = result.getValueInUnit(EtherUnit.ether);
      setState(() {
        balance = (balanceInEther * ethToUsd).toStringAsFixed(2);
      });
    } catch (e) {
      print('Error fetching balance: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home', arguments: {
          'privateKey': widget.privateKey,
          'address': widget.address,
          'portfolioId': widget.portfolioId,
          'walletKeys': walletKeys,
        });
        break;
      case 1:
        Navigator.pushNamed(
          context,
          '/dApps',
          arguments: {
            'privateKey': widget.privateKey,
            'address': widget.address,
            'portfolioId': widget.portfolioId,
            'walletKeys': walletKeys,
          },
        );
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/history', arguments: {
          'privateKey': widget.privateKey,
          'address': widget.address,
          'portfolioId': widget.portfolioId,
          'walletKeys': walletKeys,
        });
        break;
    }
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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15),
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
                                        Text(
                                          _walletName, // Display wallet name here
                                          style: const TextStyle(
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
                                        formatAddress(widget.address),
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
                                                address:widget.address,
                                            )),
                                          );
                                        },
                                        child: Container(
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
                              const SizedBox(height: 40),
                              Stack(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    margin: const EdgeInsets.symmetric(horizontal: 1),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Image.asset(
                                              'assets/images/logo1.png',
                                              width: 35,
                                              height: 35,
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              '$balance ', // Отображаем баланс в долларах
                                              style: const TextStyle(
                                                fontSize: 30,
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const Text(
                                              'USD',
                                              style: TextStyle(
                                                fontSize: 24,
                                                color: Color(0xFF007AFF),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              formatAddress(widget.address),
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.black54,
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.copy, color: Colors.black54, size: 16),
                                              onPressed: () {
                                                Clipboard.setData(ClipboardData(text: widget.address));
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Address copied to clipboard')),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 20),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            ElevatedButton(
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return AlertDialog(
                                                      contentPadding: const EdgeInsets.all(20.0),
                                                      title: Column(
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              const Text(
                                                                'Receive',
                                                                style: TextStyle(
                                                                  fontSize: 25,
                                                                  fontWeight: FontWeight.bold,
                                                                ),
                                                              ),
                                                              const SizedBox(width: 8),
                                                              Image.asset(
                                                                'assets/images/sui_original.png',
                                                                width: 32,
                                                                height: 32,
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(height: 20),
                                                          SizedBox(
                                                            width: 200.0,
                                                            height: 200.0,
                                                            child: QrImageView(
                                                              data: widget.address,
                                                              version: QrVersions.auto,
                                                              size: 200.0,
                                                            ),
                                                          ),
                                                          const SizedBox(height: 10),
                                                          const Text(
                                                            'Scan to receive',
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              color: Colors.grey,
                                                            ),
                                                          ),
                                                          const SizedBox(height: 2),
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              Padding(
                                                                padding: const EdgeInsets.only(left: 30), // Отступ слева
                                                                child: Text(
                                                                  formatAddress(widget.address),
                                                                  style: const TextStyle(
                                                                    fontSize: 14,
                                                                    color: Colors.black,
                                                                  ),
                                                                  textAlign: TextAlign.center,
                                                                ),
                                                              ),
                                                              IconButton(
                                                                icon: const Icon(Icons.copy, color: Colors.black54, size: 14),
                                                                onPressed: () {
                                                                  Clipboard.setData(ClipboardData(text: widget.address));
                                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                                    const SnackBar(content: Text('Address copied to clipboard')),
                                                                  );
                                                                },
                                                                padding: EdgeInsets.zero,
                                                              ),
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xFF007AFF),
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                minimumSize: const Size(110, 50),
                                              ),
                                              child: const Text('Receive'),
                                            ),
                                            const SizedBox(width: 10),
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => const SelectTokenScreen(),
                                                  ),
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xFF007AFF),
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                minimumSize: const Size(90, 50),
                                              ),
                                              child: const Text('Send'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    right: -screenWidth * 0.1,
                                    top: 0,
                                    bottom: 0,
                                    child: Container(
                                      width: screenWidth * 0.4,
                                      decoration: const BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage('assets/images/logo3.png'),
                                          fit: BoxFit.contain,
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
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    child: Column(
                      children: [
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.transparent,
                              child: Image.asset(
                                'assets/images/sui.png',
                                width: 50,
                                height: 50,
                              ),
                            ),
                            title: const Text(
                              'SUI',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                            ),
                            subtitle: const Text(
                              '0 SUI',
                              style: TextStyle(fontSize: 16, color: Color(0xFF8E8E93)),
                            ),
                            trailing: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  '243.094\$',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                                ),
                                Text(
                                  '+2.08%',
                                  style: TextStyle(fontSize: 14, color: Color(0xFF007AFF)),
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
          ),
        ],
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
            selectedLabelStyle: const TextStyle(
              fontSize: 12,
              height: 1,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 12,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}

