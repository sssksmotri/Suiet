import 'package:flutter/material.dart';
import 'wallet_selection.dart';
import 'main_net_screen.dart';

class dApps_screen extends StatefulWidget {
  const dApps_screen({super.key});

  @override
  _dApps_screen createState() => _dApps_screen();
}

class _dApps_screen extends State<dApps_screen> {
  int _selectedIndex = 1;
  bool _isFeaturedSelected = true;
  String _address = '';
  String? _privateKey; // Добавьте другие переменные, если нужно
  String? _portfolioId;
  List<String>? _walletKeys;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Map<String, dynamic>? args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      setState(() {
        _address = args['address'] ?? '';
        _privateKey = args['privateKey'];
        _portfolioId = args['portfolioId'];
        _walletKeys = args['walletKeys'];
      });
    }
  }

  String formatAddress(String address) {
    if (address.length > 10) {
      return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
    } else {
      return address;
    }
  }

  void _onItemTapped(int index) {
    final Map<String, dynamic> arguments = {
      'privateKey': _privateKey,
      'address': _address,
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

  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.blue,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget buildAppCard(String name, String description, String imagePath) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
          color: Colors.white,
        ),
        child: ListTile(
          leading: Image.asset(imagePath, width: 40, height: 40),
          title: Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(description),
        ),
      ),
    );
  }

  Widget buildCarouselAppCard(String name, String description, String imagePath) {
    return Card(
      elevation: 0.0,
      color: Colors.blue.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(imagePath, width: 60, height: 60, fit: BoxFit.cover),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  SizedBox(height: 5),
                  Text(description, style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFeaturedSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    final List<Map<String, String>> featuredItems = [
      {'name': 'ABEX', 'description': 'One-click Perpetual on Sui', 'image': 'assets/images/abex.png'},
      {'name': 'Cetus', 'description': 'DEX and concentrated liquidity', 'image': 'assets/images/cetus.png'},
      {'name': 'ABEX', 'description': 'One-stop Liquidity Protocol', 'image': 'assets/images/abex2.png'},
      {'name': 'ABEX', 'description': 'One-stop Liquidity Protocol', 'image': 'assets/images/abex2.png'},
    ];

    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          height: 200,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: GridView.builder(
            scrollDirection: Axis.horizontal,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
              childAspectRatio: (screenWidth * 0.7) / 900,
            ),
            itemCount: featuredItems.length,
            itemBuilder: (context, index) {
              final item = featuredItems[index];
              return Container(
                margin: EdgeInsets.all(4),
                child: buildCarouselAppCard(
                  item['name']!,
                  item['description']!,
                  item['image']!,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Finance',
          style: TextStyle(
            color: Colors.blue,
            fontSize: 24,
            fontWeight: FontWeight.normal,
          ),
        ),
        buildAppCard('Suiswap', 'DEX on Sui', 'assets/images/suiswap.png'),
        buildAppCard('Suiswap', 'DEX on Sui', 'assets/images/suiswap.png'),
        buildAppCard('Suiswap', 'DEX on Sui', 'assets/images/suiswap.png'),
        buildAppCard('Suiswap', 'DEX on Sui', 'assets/images/suiswap.png'),
        buildAppCard('Suiswap', 'DEX on Sui', 'assets/images/suiswap.png'),
        const SizedBox(height: 20),
        const Text(
          'NFT Marketplace',
          style: TextStyle(
            color: Colors.blue,
            fontSize: 24,
            fontWeight: FontWeight.normal,
          ),
        ),
        buildAppCard('Clutchy', 'Gaming and NFT Marketplace', 'assets/images/clutchy.png'),
        buildAppCard('Clutchy', 'Gaming and NFT Marketplace', 'assets/images/clutchy.png'),
      ],
    );
  }

  Widget buildPopularSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    final List<Map<String, String>> featuredItems = [
      {'name': 'Clutchy', 'description': 'One-click Perpetual on Sui', 'image': 'assets/images/clutchy.png'},
    ];

    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          height: 100,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: GridView.builder(
            scrollDirection: Axis.horizontal,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
              childAspectRatio: (screenWidth * 0.7) / 900,
            ),
            itemCount: featuredItems.length,
            itemBuilder: (context, index) {
              final item = featuredItems[index];
              return Container(
                margin: EdgeInsets.all(4),
                child: buildCarouselAppCard(
                  item['name']!,
                  item['description']!,
                  item['image']!,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Finance',
          style: TextStyle(
            color: Colors.blue,
            fontSize: 24,
            fontWeight: FontWeight.normal,
          ),
        ),
        buildAppCard('Suiswap', 'DEX on Sui', 'assets/images/suiswap.png'),
        buildAppCard('Suiswap', 'DEX on Sui', 'assets/images/suiswap.png'),
        buildAppCard('Suiswap', 'DEX on Sui', 'assets/images/suiswap.png'),
        buildAppCard('Suiswap', 'DEX on Sui', 'assets/images/suiswap.png'),
        buildAppCard('Suiswap', 'DEX on Sui', 'assets/images/suiswap.png'),
        const SizedBox(height: 20),
        const Text(
          'NFT Marketplace',
          style: TextStyle(
            color: Colors.blue,
            fontSize: 24,
            fontWeight: FontWeight.normal,
          ),
        ),
        buildAppCard('Clutchy', 'Gaming and NFT Marketplace', 'assets/images/clutchy.png'),
        buildAppCard('Clutchy', 'Gaming and NFT Marketplace', 'assets/images/clutchy.png'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(top: 150.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const Text(
                        'DApps',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 24,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isFeaturedSelected = true;
                              });
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: _isFeaturedSelected ? Colors.blue : Colors.blue.withOpacity(0.1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: Text(
                              'Featured',
                              style: TextStyle(color: _isFeaturedSelected ? Colors.white : Colors.blue),
                            ),
                          ),
                          const SizedBox(width: 10),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isFeaturedSelected = false;
                              });
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: !_isFeaturedSelected ? Colors.blue : Colors.blue.withOpacity(0.1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: Text(
                              'Popular',
                              style: TextStyle(color: !_isFeaturedSelected ? Colors.white : Colors.blue),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _isFeaturedSelected ? buildFeaturedSection() : buildPopularSection(),
              ],
            ),
          ),
          // Закрепленный контейнер
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              width: screenWidth,
              padding: const EdgeInsets.only(bottom: 5),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF015FDF), Color(0xFF1ED2FC)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
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
                                  'Wallet', // Используем адрес
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
                                formatAddress(_address),
                                style: TextStyle(
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
                                      address:_address,
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
        ],
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(bottom: 30, right: 20, left: 20),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
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
