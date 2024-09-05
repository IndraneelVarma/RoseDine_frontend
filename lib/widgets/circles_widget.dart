import 'package:flutter/material.dart';

class CirclesWidget extends StatelessWidget {
  final Map<String, dynamic> menuItem;

  const CirclesWidget({Key? key, required this.menuItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isGlutenFree = menuItem['glutenFree'];
    final isVegan = menuItem['vegan'];
    final isVegetarian = menuItem['vegetarian'];

    if (!isVegan && !isVegetarian) {
      return Row(
        children: [
          Container(
            margin: EdgeInsets.only(left: 8),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red[900],
            ),
            child: const Center(
              child: Text(
                'NVG',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          if (isGlutenFree)
            Container(
              margin: EdgeInsets.only(left: 8),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFAB8532),
              ),
              child: Center(
                child: Text(
                  'GF',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      );
    }

    return Row(
      children: [
        if (isGlutenFree)
          Container(
            margin: EdgeInsets.only(left: 8),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFAB8532),
            ),
            child: Center(
              child: Text(
                'GF',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        if (isVegan)
          Container(
            margin: EdgeInsets.only(left: 8),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green[700],
            ),
            child: Center(
              child: Text(
                'V',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        if (isVegetarian)
          Container(
            margin: EdgeInsets.only(left: 8),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green[900],
            ),
            child: Center(
              child: Text(
                'VG',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}