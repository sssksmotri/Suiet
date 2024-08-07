import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'wallet_selection.dart';

class MainNetScreen extends StatefulWidget {
  final String address; // Убираем инициализацию здесь
  const MainNetScreen({
    Key? key,
    required this.address,
  }) : super(key: key);

  @override
  _MainNetScreenState createState() => _MainNetScreenState();
}

class _MainNetScreenState extends State<MainNetScreen> {
  int _selectedNetworkIndex = 0; // Индекс выбранного поля
  String _displayedNetworkName = 'mainnet'; // Текущая отображаемая сеть
  String _pendingNetworkName = 'mainnet'; // Сеть, выбранная пользователем
  late String _walletAddress;
  @override
  void initState() {
    super.initState();
    _loadSavedNetwork(); // Загружаем сохраненную сеть при инициализации
    _walletAddress = widget.address;
  }

  // Загрузка сохраненной сети из SharedPreferences
  Future<void> _loadSavedNetwork() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedNetworkName = prefs.getString('selectedNetworkName');

    if (savedNetworkName != null) {
      setState(() {
        _displayedNetworkName = savedNetworkName;
        _pendingNetworkName = savedNetworkName;
        _selectedNetworkIndex = _getNetworkIndex(savedNetworkName);
      });
      print('Loaded network: $_displayedNetworkName');
    } else {
      print('No saved network found, using default.');
    }
  }

  String formatAddress(String address) {
    if (address.length > 10) {
      return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
    } else {
      return address;
    }
  }

  // Сохранение выбранной сети в SharedPreferences
  Future<void> _saveNetwork() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedNetworkName', _displayedNetworkName);
    print('Saved network: $_displayedNetworkName'); // Отладочный вывод
  }

  // Получение индекса сети по имени
  int _getNetworkIndex(String networkName) {
    switch (networkName) {
      case 'mainnet':
        return 0;
      case 'testnet':
        return 1;
      case 'devnet':
        return 2;
      default:
        return 0;
    }
  }

  void _onNetworkSelected(int index, String name) {
    setState(() {
      _selectedNetworkIndex = index;
      _pendingNetworkName = name;
    });
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
                                   formatAddress(_walletAddress),
                                    style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () {
                                    // Действие при нажатии на выбранную сеть (если нужно)
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _displayedNetworkName, // Отображение текущей сети
                                      style: const TextStyle(
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
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context); // Возврат назад при нажатии на стрелку
                    },
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.black,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Network',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildNetworkOption(0, 'mainnet', 'assets/images/vec1.png'),
            _buildNetworkOption(1, 'testnet', 'assets/images/vec2.png'),
            _buildNetworkOption(2, 'devnet', 'assets/images/vec3.png'),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 30, right: 30, bottom: 16),
        child: ElevatedButton(
          onPressed: () {
            // Обновление текста на экране после нажатия на кнопку "Save"
            setState(() {
              _displayedNetworkName = _pendingNetworkName;
              _saveNetwork(); // Сохранение выбранной сети
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Save',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // Метод для создания пункта выбора сети
  Widget _buildNetworkOption(int index, String name, String assetPath) {
    final isSelected = _selectedNetworkIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: GestureDetector(
        onTap: () => _onNetworkSelected(index, name),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: isSelected ? Border.all(color: Colors.blue) : Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                assetPath,
                color: isSelected ? Colors.blue : Colors.black,
                height: 24,
                width: 24,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    name,
                    style: TextStyle(
                      color: isSelected ? Colors.blue : Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Checkbox(
                value: isSelected,
                onChanged: (bool? value) {
                  _onNetworkSelected(index, name);
                },
                checkColor: Colors.white,
                activeColor: Colors.blue,
                side: BorderSide(color: isSelected ? Colors.blue : Colors.grey.shade300, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
