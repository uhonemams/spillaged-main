import 'package:flutter/material.dart';

class pg3 extends StatelessWidget {
  const pg3({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.asset(
        "images/land_img3.jpg",
        height: 250,
        width: 335,
        fit: BoxFit.cover,
      ),
    );
  }
}
