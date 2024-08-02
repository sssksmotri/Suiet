import 'package:flutter/material.dart';
class WalletDetailsScreen extends StatelessWidget {
  const WalletDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Wallet #1'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {},
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('mainnet', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning, size: 50, color: Colors.grey),
            const SizedBox(height: 20),
            const Text(
              'No NFT in your wallet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            const Text(
              'You will see your NFT here once you have one.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('Get SUI First'),
            ),
          ],
        ),
      ),
    );
  }
}