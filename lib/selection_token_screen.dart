import 'package:flutter/material.dart';
import 'stake_send_screen.dart';
class SelectTokenScreen extends StatefulWidget {
  const SelectTokenScreen({super.key});

  @override
  _SelectTokenScreenState createState() => _SelectTokenScreenState();
}
class _SelectTokenScreenState extends State<SelectTokenScreen> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

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
          'Select Token',
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
                width: screenWidth * 0.4,
                height: screenWidth * 0.4,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              const Text(
                'Select Token',
                style: TextStyle(
                  fontSize: 30,
                  color: Color(0xFF007AFF),
                  fontWeight: FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'Choose the token you want to send',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF8E8E93),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Container(
                height: 400,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF015FDF), Color(0xFF1ED2FC)],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 280,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    child: Image.asset(
                                      'assets/images/sui.png',
                                      width: 60,
                                      height: 60,
                                    ),
                                    backgroundColor: Colors.transparent,
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        'SUI',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 18,
                                        ),
                                      ),
                                      // Белый текст
                                      Text(
                                        '0 SUI',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Theme(
                                data: ThemeData(
                                  unselectedWidgetColor: Color(0xFF007AFF),
                                  checkboxTheme: CheckboxThemeData(
                                    side: MaterialStateBorderSide.resolveWith(
                                          (states) => BorderSide(
                                        color: Colors.white,
                                        width: 2.0,
                                      ),
                                    ),
                                    checkColor: MaterialStateProperty.all(Colors.white),
                                    fillColor: MaterialStateProperty.all(Colors.transparent),
                                  ),
                                ),
                                child: Checkbox(
                                  value: isChecked,
                                  onChanged: (value) {
                                    setState(() {
                                      isChecked = value!;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: isChecked ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const StakeSendScreen(),
                            ),
                          );} : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isChecked ? Colors.blue : Colors.white.withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          minimumSize: Size(MediaQuery.of(context).size.width * 0.6, 55),
                        ),
                        child: const Text(
                          'Insufficient Balance',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}