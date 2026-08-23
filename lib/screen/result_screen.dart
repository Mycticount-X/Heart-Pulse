import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ResultScreen extends StatelessWidget {
  final Map<String, dynamic> resultData;

  const ResultScreen({super.key, required this.resultData});

  @override
  Widget build(BuildContext context) {
    final trajectory = resultData['trajectory'] as List;
    final currentRisk = trajectory[0]['risk_percentage'];

    return Scaffold(
      appBar: AppBar(title: const Text("Hasil Analisis")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Risiko Saat Ini", style: TextStyle(fontSize: 16, color: Colors.grey)),
            Text(
              "$currentRisk%",
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: currentRisk > 50 ? Colors.red : Colors.green,
              ),
            ),
            const SizedBox(height: 40),
            const Text("Proyeksi 10 Tahun (Tanpa Perubahan)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text('Thn ${value.toInt()}');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: 10,
                  minY: 0,
                  maxY: 100,
                  lineBarsData: [
                    LineChartBarData(
                      spots: trajectory.map<FlSpot>((point) {
                        // Mengambil angka tahun dari string "Year X"
                        int year = int.parse(point['year'].toString().replaceAll("Year ", ""));
                        double risk = double.parse(point['risk_percentage'].toString());
                        return FlSpot(year.toDouble(), risk);
                      }).toList(),
                      isCurved: true,
                      color: Colors.blueAccent,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}