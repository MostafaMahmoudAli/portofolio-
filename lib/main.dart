import 'package:flutter/material.dart';

// Phase 0 placeholder: proves the build and GitHub Pages deploy work.
// Replaced by the real app in Phase 1.
void main() => runApp(const PortfolioApp());

class PortfolioApp extends StatelessWidget {
  const PortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mostafa Mahmoud — Flutter Developer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A12),
      ),
      home: const ComingSoonPage(),
    );
  }
}

class ComingSoonPage extends StatelessWidget {
  const ComingSoonPage({super.key});

  static const _gradient = LinearGradient(
    colors: [Color(0xFF7C5CFF), Color(0xFF22D3EE)],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ShaderMask(
                shaderCallback: _gradient.createShader,
                child: const Text(
                  'Mostafa Mahmoud',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Flutter Developer · Portfolio coming soon',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF9A9AB0), fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
