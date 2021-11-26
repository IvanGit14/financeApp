import 'package:flutter/material.dart';

class WidgetAppBar extends StatefulWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize = Size(56.0, 56.0); // default is 56.0

  @override
  _WidgetAppBarState createState() => _WidgetAppBarState();
}

class _WidgetAppBarState extends State<WidgetAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: CircleAvatar(
        backgroundColor: Colors.transparent,
        child: Image.asset(
          "assets/images/icon.png",
          width: 30,
          fit: BoxFit.cover,
        ),
      ),
      backgroundColor: Color.fromRGBO(30, 30, 30, 1),
      title: Text(
        'Finance App',
        textAlign: TextAlign.center,
        style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            decorationThickness: 2.5),
      ),
      centerTitle: true,
      actions: <Widget>[
        IconButton(
          icon: const Icon(
            Icons.add,
          ),
          tooltip: 'Add Stock',
          onPressed: () {
            if (ModalRoute.of(context).settings.name != 'add_stock') {
              Navigator.pushNamed(context, 'add_stock');
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Stocks to add to the watchlists.')));
            }
          },
        ),
        IconButton(
          icon: const Icon(
            Icons.account_circle,
          ),
          tooltip: 'Set profile',
          onPressed: () {
            Navigator.of(context).pushNamedAndRemoveUntil(
                "profile", (route) => route.isCurrent ? false : true);
          },
        ),
      ],
    );
  }
}
