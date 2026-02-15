import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LeadStatsCard extends StatelessWidget {
  final String title;
  final String value;
  final List<PieChartSectionData>? pieSections;
  final Color color;

  const LeadStatsCard({
    Key? key,
    required this.title,
    required this.value,
    this.pieSections,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
                ),
                if (pieSections != null)
                  SizedBox(
                    height: 60,
                    width: 60,
                    child: PieChart(
                      PieChartData(
                        sections: pieSections,
                        sectionsSpace: 0,
                        centerSpaceRadius: 0,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
