import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

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
  late String PrivatyKey;
  late String walletAddress;
  final String network = 'mainnet';
  late Web3Client web3client;
  late Timer timer;
  double balance = 0.0;
  List transactions = [];
  Map<String, double> positions = {};
  String selectedCurrency = 'USD';
  Map<String, double> exchangeRates = {};
  Map<String, double> tokenPrices = {};

  @override
  void initState() {
    super.initState();
    walletAddress = widget.address;
    walletAddress = widget.privateKey;
    web3client = Web3Client('https://mainnet.infura.io/v3/SuietWallet_IOS', http.Client());
    fetchWalletData();
    fetchExchangeRates();
    fetchTokenPrices();
    timer = Timer.periodic(Duration(minutes: 5), (Timer t) => fetchWalletData());
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  Future<void> fetchWalletData() async {
    try {
      EtherAmount balanceAmount = await web3client.getBalance(EthereumAddress.fromHex(walletAddress));
      double updatedBalance = balanceAmount.getValueInUnit(EtherUnit.ether).toDouble();

      setState(() {
        balance = updatedBalance;
        // Update with fetched transactions and positions
      });
    } catch (e) {
      print('Error fetching wallet data: $e');
    }
  }

  Future<void> fetchExchangeRates() async {
    try {
      final response = await http.get(Uri.parse('https://api.exchangerate-api.com/v4/latest/USD'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          exchangeRates = Map<String, double>.from(data['rates']);
        });
      }
    } catch (e) {
      print('Error fetching exchange rates: $e');
    }
  }

  Future<void> fetchTokenPrices() async {
    try {
      final response = await http.get(Uri.parse('https://api.coingecko.com/api/v3/simple/price?ids=bitcoin,ethereum&vs_currencies=usd'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          tokenPrices = {
            'bitcoin': data['bitcoin']['usd'].toDouble(),
            'ethereum': data['ethereum']['usd'].toDouble(),
          };
        });
      } else {
        throw Exception('Failed to load token prices');
      }
    } catch (e) {
      print('Error fetching token prices: $e');
    }
  }

  void _copyAddressToClipboard() {
    Clipboard.setData(ClipboardData(text: walletAddress));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Address copied to clipboard!')),
    );
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
                            Row(
                              children: [
                                const Text(
                                  'Wallet #1',
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
                            Row(
                              children: [
                                const SizedBox(width: 8),
                                Text(
                                  formatAddress(walletAddress),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
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
                                const SizedBox(width: 8),
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
                                        '${NumberFormat.currency(name: selectedCurrency).format(balance)}',
                                        style: const TextStyle(
                                          fontSize: 30,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        selectedCurrency,
                                        style: const TextStyle(
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
                                        formatAddress(walletAddress),
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.copy, color: Colors.black54, size: 16),
                                        onPressed: _copyAddressToClipboard,
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
                                                title: const Text('Receive'),
                                                content: SizedBox(
                                                  width: 200.0,
                                                  height: 200.0,
                                                  child: QrImageView(
                                                    data: walletAddress,
                                                    version: QrVersions.auto,
                                                    size: 200.0,
                                                  ),
                                                ),
                                                actions: <Widget>[
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context).pop();
                                                    },
                                                    child: const Text('Close'),
                                                  ),
                                                ],
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
                                        onPressed: () {},
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
                              right: 0,
                              top: 0,
                              bottom: 0,
                              child: Container(
                                width: screenWidth * 0.4,
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage('assets/images/background.png'),
                                    fit: BoxFit.cover,
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
                children: positions.entries.map((entry) {
                  final token = entry.key;
                  final amount = entry.value;
                  final price = tokenPrices[token] ?? 0.0;
                  final valueInCurrency = amount * price;
                  final percentageChange = 0.0; // Implement percentage change if available

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.transparent,
                        child: Image.asset(
                          'assets/images/${token.toLowerCase()}.png',
                          width: 50,
                          height: 50,
                        ),
                      ),
                      title: Text(
                        token,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                      ),
                      subtitle: Text(
                        '$amount $token',
                        style: TextStyle(fontSize: 16, color: Color(0xFF8E8E93)),
                      ),
                      trailing: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${NumberFormat.currency(name: selectedCurrency).format(valueInCurrency)}',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                          ),
                          Text(
                            '${percentageChange.toStringAsFixed(2)}%',
                            style: TextStyle(fontSize: 14, color: Color(0xFF007AFF)),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
