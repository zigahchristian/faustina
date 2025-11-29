import 'package:flutter/material.dart';
import 'package:faustina/screens/sales_page.dart';
import 'package:faustina/screens/expenses_page.dart';
import 'package:faustina/screens/business_profile_page.dart';
import 'package:faustina/screens/pro_dashboard.dart';
import 'package:faustina/screens/about_us.dart';
import 'package:faustina/screens/meet_faustina.dart';
import 'report_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
     ProDashboardPage(),
    SalesPage(),
    ExpensesPage(),
    ReportPage(),
    BusinessProfilePage(),
    AboutUsPage(),
    FaustinaPage(),

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sales & Expenses Tracker'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      drawer: Drawer(
        child: ListView(
          children: [
           DrawerHeader(
  decoration: BoxDecoration(color: Colors.blue),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        "Faustina",
        style: TextStyle(
          color: Colors.white,
          fontSize: 26,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: 4),
      Text(
        "Sales & Expenses Tracker",
        style: TextStyle(
          color: Colors.white.withOpacity(0.9),
          fontSize: 14,
        ),
      ),
    ],
  ),
),

 _buildDrawerItem(
              icon: Icons.dashboard,
              title: 'Dashboard',
              index: 0,
            ),
            _buildDrawerItem(
              icon: Icons.trending_up,
              title: 'Sales',
              index: 1,
            ),
            _buildDrawerItem(
              icon: Icons.trending_down,
              title: 'Expenses',
              index: 2,
            ),
            _buildDrawerItem(
              icon: Icons.picture_as_pdf,
              title: 'Reports',
              index: 3,
            ),
      
            _buildDrawerItem(
              icon: Icons.business,
              title: 'Profile',
              index: 4,
            ),
            
              _buildDrawerItem(
              icon: Icons.info,
              title: 'About Us',
              index: 5,
            ),
             _buildDrawerItem(
              icon: Icons.person,
              title: 'Myself',
              index: 6,
            ),
    
          ],
        ),
      ),

      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required int index,
  }) {
    return ListTile(
      leading: Icon(icon,
          color: _currentIndex == index ? Colors.blue : Colors.grey),
      title: Text(
        title,
        style: TextStyle(
          color: _currentIndex == index ? Colors.blue : Colors.black,
        ),
      ),
      selected: _currentIndex == index,
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
        Navigator.pop(context); // Close drawer
      },
    );
  }
}
