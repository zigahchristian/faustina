import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 16 : 32),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 24.0, horizontal: 24.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'About the App',
                        style: TextStyle(
                            fontSize: isSmallScreen ? 20 : 26,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'This application was developed to help business owners efficiently record their daily sales and expenses, generate accurate financial summaries, and produce printable PDF reports. By simplifying financial tracking, the app enables users to make informed decisions, plan effectively, and support long-term business growth.',
                        style: TextStyle(
                            fontSize: isSmallScreen ? 14 : 16, height: 1.5),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      _infoText('Idea Originator', 'Miss Faustina Alima Nuhu'),
                      const SizedBox(height: 8),
                      _infoText('Developer', 'OLGABYTE'),
                      const SizedBox(height: 8),
                      _infoText('Email', 'olgabyte256@gmail.com'),
                      const SizedBox(height: 8),
                      _infoText('Phone', '+233 (0) 55 323 0095'),
                      const SizedBox(height: 8),
                      _infoText('Location', 'Accra, Ghana'),
                      const SizedBox(height: 24),
                      Text(
                        '© ${DateTime.now().year} OLGABYTE. All rights reserved.',
                        style: TextStyle(
                            fontSize: isSmallScreen ? 12 : 14,
                            color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      // Image at the bottom
                      Container(
                        width: isSmallScreen ? 120 : 150,
                        height: isSmallScreen ? 120 : 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[100],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'assets/icon/icon.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: isSmallScreen ? 40 : 50,
                                  color: Colors.grey[400],
                                ),
                              );
                            },
                          ),
                        )),
                      const SizedBox(height: 8),
                      Text(
                        'App Logo',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 12 : 14,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoText(String title, String content) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          TextSpan(
              text: '$title: ',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black)),
          TextSpan(text: content, style: const TextStyle(color: Colors.black)),
        ],
      ),
    );
  }
}