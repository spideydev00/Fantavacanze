import 'package:flutter/material.dart';

class ShopPage extends StatelessWidget {
  static Route get route =>
      MaterialPageRoute(builder: (context) => const ShopPage());
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Acquista i prodotti della tua lega'));
  }
}
