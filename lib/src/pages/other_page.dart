import 'package:flutter/material.dart';

import 'package:financeApp/src/widgets/homePageAppBar.dart';

class SecondScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: WidgetAppBar(),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, 'watchlist');
            },
            child: const Text('Go back!'),
          ),
        ));
  }
}
