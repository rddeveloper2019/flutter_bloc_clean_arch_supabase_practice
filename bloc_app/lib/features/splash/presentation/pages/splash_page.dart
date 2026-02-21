import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    print('(**) => In The SplashPage');
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
