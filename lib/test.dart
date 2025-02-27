import 'package:fantavacanze_official/features/auth/presentation/widgets/google_loader.dart';
import 'package:flutter/material.dart';

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  bool showLoader = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              setState(() {
                showLoader = false;
              });
            },
            child: Text("Stop Animation"),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                showLoader = true;
              });
            },
            child: Text("Show Animation"),
          ),
          showLoader ? GoogleLoader() : SizedBox(),
        ],
      ),
    );
  }
}
