import 'package:flutter/material.dart';
import 'stake.dart';
class StakeSendScreen extends StatelessWidget {
  const StakeSendScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                child: Container(
                  width: 70,
                  height: 70,
                  margin: const EdgeInsets.only(right: 40),
                  child: Image.asset('assets/images/log.png'),
                ),
              ),
              Positioned(
                child: Container(
                  width: 70,
                  height: 70,
                  margin: const EdgeInsets.only(left: 40),
                  child: Image.asset('assets/images/log1.png'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),
          // Row for Available and Staked text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Available',
                  style: TextStyle(
                    color: Color(0xFF8E8E93),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  'Staked',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8E8E93),
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          // Gradient card with a white loading line
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 65, // Height of the card
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1ED2FC), Color(0xFF015FDF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              children: [
                // White loading line
                Positioned(
                  bottom: 10, // Position the white line close to the bottom
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                // Numbers above the white line
                Positioned(
                  bottom: 25,
                  left: 1,
                  child: const Text(
                    '0',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),

                Positioned(
                  bottom: 25,
                  right: 1,
                  child: const Text(
                    '0',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,

                    ),
                  ),
                ),
                // Center text
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Text below the card
          const Text(
            'Staking on 0 validators',
            style: TextStyle(
              color: Color(0xFF8E8E93),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const Spacer(),
          // Buttons at the bottom
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      minimumSize: const Size(0, 40),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Stake',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Stake(),
                        ),
                      );},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                        side: const BorderSide(color: Colors.blue),
                      ),
                      minimumSize: const Size(0, 40),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Send',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
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
    );
  }
}