import 'package:flutter/material.dart';

class Education extends StatefulWidget {
  const Education({super.key});

  @override
  State<Education> createState() => _EducationState();
}

class _EducationState extends State<Education> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: const Border(
          bottom: BorderSide(
            color: Color.fromARGB(80, 0, 0, 0),
            width: 3,
          ),
        ),
        centerTitle: true,
        title: const Text(
          "Educational Resources",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Color.fromARGB(255, 2, 37, 66),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(children: const [
          Center(
            child: Text(
              "Tips on saving water\n",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Color.fromARGB(255, 2, 37, 66),
              ),
            ),
          ),
          Divider(),
          Row(
            children: [
              Text(
                "Indoors:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color.fromARGB(255, 2, 37, 66),
                ),
              ),
            ],
          ),
          Text(
            "\nFix leaky faucets and toilets: Even a small drip can waste a lot of water over time. Check your toilets for leaks by adding a few drops of food coloring to the tank. If the color appears in the bowl without flushing, you have a leak. \n\nInstall a water-efficient showerhead: Low-flow showerheads can reduce the amount of water you use without sacrificing water pressure.",
            style: TextStyle(
              fontSize: 13,
            ),
          ),
          Row(
            children: [
              Text(
                "\nOutdoors:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color.fromARGB(255, 2, 37, 66),
                ),
              ),
            ],
          ),
          Text(
            "\nUse a watering can for delicate plants: A hose can waste a lot of water.\n\nInstall a rain barrel to collect rainwater: You can then use this water to water your plants.\n",
            style: TextStyle(
              fontSize: 13,
            ),
          ),
          Divider()
        ]),
      ),
    );
  }
}
