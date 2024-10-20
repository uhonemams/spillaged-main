import 'package:flutter/material.dart';

class pg1 extends StatelessWidget {
  const pg1({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.asset(
        "images/brix1.jpg",
        height: 250,
        width: 335,
        fit: BoxFit.cover,
      ),
    );
  }
}
