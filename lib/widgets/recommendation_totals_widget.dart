import 'package:flutter/material.dart';

class RecommendationTotalsWidget extends StatelessWidget {
  final Map<String, dynamic> totals;

  const RecommendationTotalsWidget({Key? key, required this.totals}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueGrey[900],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color:Color(0xFFAB8532), width: 2),
      ),
      child: Column(
        children: [
          Text('Recommendations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          SizedBox(height: 10),
          Text('Total Protein: ${totals['totalProtein']}g', style: TextStyle(color: Colors.white)),
          Text('Total Carbs: ${totals['totalCarbs']}g', style: TextStyle(color: Colors.white)),
          Text('Total Fats: ${totals['totalFats']}g', style: TextStyle(color: Colors.white)),
          Text('Total Calories: ${totals['totalCalories']} kcal', style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
