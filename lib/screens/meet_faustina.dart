import 'package:flutter/material.dart';

class FaustinaPage extends StatelessWidget {
  const FaustinaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: Image.asset(
            'assets/icon/splash.png', // Replace with your actual image path
            fit: BoxFit.cover, // This will cover the entire screen
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              // Fallback if image fails to load
              return Container(
                color: Colors.grey[200],
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_not_supported,
                      size: 50,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Image not found\nPlease check assets path',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Expected path: assets/images/app_logo.png',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}