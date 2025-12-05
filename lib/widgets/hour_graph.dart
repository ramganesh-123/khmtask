import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/iot_data.dart';

class HourGraph extends StatelessWidget {
  final List<IotData> data;

  const HourGraph({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return SizedBox(
        height: 250,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.show_chart, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 8),
              Text(
                'No data available yet',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 5,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.shade200,
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= data.length) {
                    return const Text('');
                  }
                  final hour = data[index].timestamp.hour;
                  if (index % 4 == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '${hour}h',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 5,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}°C',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey.shade300),
          ),
          minX: 0,
          maxX: (data.length - 1).toDouble(),
          minY: _getMinTemp() - 2,
          maxY: _getMaxTemp() + 2,
          lineBarsData: [
            LineChartBarData(
              spots: _getSpots(),
              isCurved: true,
              color: const Color(0xFF9D781C),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: Colors.white,
                    strokeWidth: 2,
                    strokeColor: const Color(0xFF9D781C),
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: Color(0xFF9D781C).withOpacity(0.1),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: Color(0xFF9D781C),
              getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                return touchedBarSpots.map((barSpot) {
                  final index = barSpot.x.toInt();
                  if (index < 0 || index >= data.length) {
                    return null;
                  }
                  final timestamp = data[index].timestamp;
                  return LineTooltipItem(
                    '${barSpot.y.toStringAsFixed(1)}°C\n${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }

  List<FlSpot> _getSpots() {
    return data
        .asMap()
        .entries
        .map((entry) => FlSpot(
              entry.key.toDouble(),
              entry.value.temperature,
            ))
        .toList();
  }

  double _getMinTemp() {
    if (data.isEmpty) return 0;
    return data.map((d) => d.temperature).reduce((a, b) => a < b ? a : b);
  }

  double _getMaxTemp() {
    if (data.isEmpty) return 100;
    return data.map((d) => d.temperature).reduce((a, b) => a > b ? a : b);
  }
}
