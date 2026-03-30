import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ChartScreen extends StatelessWidget {
  const ChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Analytics")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: BarChart(
          BarChartData(
            titlesData: FlTitlesData(show: true),
            borderData: FlBorderData(show: false),
            barGroups: [
              BarChartGroupData(x: 0, barRods: [
                BarChartRodData(toY: 5),
              ]),
              BarChartGroupData(x: 1, barRods: [
                BarChartRodData(toY: 3),
              ]),
              BarChartGroupData(x: 2, barRods: [
                BarChartRodData(toY: 7),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}