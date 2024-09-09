import 'package:flutter/material.dart';

class OssLicensesPage extends StatelessWidget {
  const OssLicensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const LicensePage(
      applicationName: 'Struer Taekwondo App',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2024 Struer Taekwondo Club',
    );
  }
}
