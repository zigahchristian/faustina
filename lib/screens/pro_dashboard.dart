import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import 'package:intl/intl.dart';

class ProDashboardPage extends StatefulWidget {
  @override
  _ProDashboardPageState createState() => _ProDashboardPageState();
}

class _ProDashboardPageState extends State<ProDashboardPage> {
  final DatabaseHelper db = DatabaseHelper();

  double totalSales = 0;
  double totalExpenses = 0;
  double totalProfit = 0;
  bool isLoading = true;
  final moneyFormat = NumberFormat('#,##0.00');

  @override
  void initState() {
    super.initState();
    _loadTotals();
  }

  Future<void> _loadTotals() async {
    setState(() => isLoading = true);
    final sales = await db.getTotalSales();
    final expenses = await db.getTotalExpenses();

    setState(() {
      totalSales = sales;
      totalExpenses = expenses;
      totalProfit = sales - expenses;
      isLoading = false;
    });
  }

  Widget _statCard({required String title, required String value, required Color color}) {
    return Card(
      elevation: 3,
      child: Container(
        width: double.infinity, // Full width
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget buildSummaryCards() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        _statCard(
            title: "Total Sales",
            value: "¢ ${moneyFormat.format(totalSales)}",
            color: Colors.green),
        SizedBox(height: 8),
        _statCard(
            title: "Total Expenses",
            value: "¢ ${moneyFormat.format(totalExpenses)}",
            color: Colors.red),
        SizedBox(height: 8),
        _statCard(
            title: "Profit",
            value: "¢ ${moneyFormat.format(totalProfit)}",
            color: totalProfit >= 0 ? Colors.blue : Colors.orange),
      ],
    );
  }

  // Format amount for better readability
  String _formatAmount(double value) {
    if (value >= 1000) {
      return '¢ ${(value / 1000).toStringAsFixed(1)}K';
    }
    return '¢ ${value.toStringAsFixed(0)}';
  }

  // ================= BAR CHART =================
  Widget buildBarChart() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    
    if (totalSales == 0 && totalExpenses == 0) {
      return _buildEmptyChart("No data available");
    }
    
    final maxY = max(totalSales, totalExpenses) * 1.2;

    return Container(
      padding: EdgeInsets.all(16),
      child: AspectRatio(
        aspectRatio: 1.3,
        child: BarChart(
          BarChartData(
            maxY: maxY == 0 ? 1 : maxY,
            minY: 0,
            alignment: BarChartAlignment.spaceAround,
            barGroups: [
              BarChartGroupData(
                x: 0,
                barRods: [BarChartRodData(
                  toY: totalSales, 
                  color: Colors.green, 
                  width: 22,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                )],
              ),
              BarChartGroupData(
                x: 1,
                barRods: [BarChartRodData(
                  toY: totalExpenses, 
                  color: Colors.red, 
                  width: 22,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                )],
              ),
              BarChartGroupData(
                x: 2,
                barRods: [BarChartRodData(
                  toY: totalProfit >= 0 ? totalProfit : totalProfit.abs(), 
                  color: totalProfit >= 0 ? Colors.blue : Colors.orange, 
                  width: 22,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                )],
              ),
            ],
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final labels = ['Sales', 'Expenses', 'Profit'];
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        labels[value.toInt()],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    );
                  },
                  reservedSize: 40,
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        _formatAmount(value),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    );
                  },
                  reservedSize: 50,
                  interval: maxY / 4,
                ),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: maxY / 4,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: Colors.grey[300],
                  strokeWidth: 1,
                );
              },
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(
                color: Colors.grey[400]!,
                width: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyChart(String message) {
    return SizedBox(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, size: 48, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(message, 
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, // Full width
            children: [
              // Overview Title - Full width
              Text("Overview",
                  style: TextStyle(
                      fontSize: isSmallScreen ? 20 : 26,
                      fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              
              // Summary Cards - Full width
              buildSummaryCards(),
              SizedBox(height: 24),
              
              // Chart Title - Full width but centered text
              Container(
                width: double.infinity,
                child: Text(
                  "Financial Overview",
                  style: TextStyle(
                    fontSize: isSmallScreen ? 18 : 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 8),
              Container(
                width: double.infinity,
                child: Text(
                  "Sales vs Expenses vs Profit",
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 16),
              
              // Bar Chart - This will maintain its aspect ratio but constrained by parent
              Expanded(
                child: buildBarChart(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadTotals,
        child: Icon(Icons.refresh),
        backgroundColor: Colors.blue,
      ),
    );
  }
}