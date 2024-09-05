import 'package:flutter/material.dart';

class ExpandedContent extends StatelessWidget {
  final Map<String, dynamic> menuItem;
  final int userRating;

  const ExpandedContent({
    Key? key,
    required this.menuItem,
    required this.userRating,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const labelStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );

    const valueStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );

    return Column(
      children: [
        _buildNutrientBar(
          label: 'Calories',
          value: menuItem['calories'],
          maxValue: 1000,
          labelStyle: labelStyle,
          valueStyle: valueStyle,
        ),
        SizedBox(height: 8),
        _buildNutrientBar(
          label: 'Protein',
          value: menuItem['protein'],
          maxValue: 150,
          labelStyle: labelStyle,
          valueStyle: valueStyle,
        ),
        SizedBox(height: 8),
        _buildNutrientBar(
          label: 'Fats',
          value: menuItem['fats'],
          maxValue: 150,
          labelStyle: labelStyle,
          valueStyle: valueStyle,
        ),
        SizedBox(height: 8),
        _buildNutrientBar(
          label: 'Carbs',
          value: menuItem['carbs'],
          maxValue: 150,
          labelStyle: labelStyle,
          valueStyle: valueStyle,
        ),
        SizedBox(height: 16),
        _buildNutrientBar(
          label: 'Overall Rating',
          value: menuItem['overallStars'],
          maxValue: 5,
          barColor: Color(0xFFAB8532),
          labelStyle: labelStyle,
          valueStyle: valueStyle,
        ),
        SizedBox(height: 16),
        _buildNutrientBar(
          label: 'Your Rating',
          value: userRating,
          maxValue: 5,
          barColor: Color(0xFFAB8532),
          labelStyle: labelStyle,
          valueStyle: valueStyle,
        ),
      ],
    );
  }

  Widget _buildNutrientBar({
    required String label,
    required int value,
    required int maxValue,
    Color barColor = Colors.blue,
    TextStyle labelStyle = const TextStyle(),
    TextStyle valueStyle = const TextStyle(),
  }) {
    final percentage = value / maxValue;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text('$label: ', style: labelStyle),
          ),
          Expanded(
            flex: 7,
            child: Container(
              height: 20,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Flexible(
                    child: FractionallySizedBox(
                      widthFactor: percentage,
                      child: Container(
                        decoration: BoxDecoration(
                          color: barColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '$value',
              textAlign: TextAlign.right,
              style: valueStyle,
            ),
          ),
        ],
      ),
    );
  }
}