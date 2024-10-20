import 'package:flutter/material.dart';

class pg2 extends StatelessWidget {
  const pg2({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.asset(
        "images/brix2.jpg",
        height: 250,
        width: 335,
        fit: BoxFit.cover,
      ),
    );
  }
}
