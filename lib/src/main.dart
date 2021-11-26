import 'package:financeApp/src/pages/add_investment_page.dart';
import 'package:financeApp/src/pages/profile_page.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:lottie/lottie.dart';

import 'package:provider/provider.dart';

import 'package:financeApp/src/services/tabselected_service.dart';

import 'package:financeApp/src/pages/home_page_stateless.dart';
import 'package:financeApp/src/pages/add_stocks_page.dart';
import 'package:financeApp/src/pages/login_page.dart';
import 'package:financeApp/src/pages/other_page.dart';
import 'package:financeApp/src/pages/myinvest_page.dart';
import 'package:financeApp/src/pages/signup_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _fbApp = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => new tabselected())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'FinanceApp',
        theme: ThemeData(
          backgroundColor: Color.fromRGBO(30, 30, 30, 1),
          scaffoldBackgroundColor: Color.fromRGBO(30, 30, 30, 1),
          fontFamily: 'Montserrat',
          primarySwatch: Colors.blueGrey,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: 'login',
        routes: {
          'login': (BuildContext context) => FutureBuilder(
                future: _fbApp,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    print('Error--> $snapshot.error.toString()');
                    return Text('Something went wrong');
                  } else if (snapshot.hasData) {
                    return LogInPage();
                  } else {
                    return Lottie.network(
                      'https://assets7.lottiefiles.com/packages/lf20_z6scuqaw.json',
                    );
                  }
                },
              ),
          'watchlist': (BuildContext context) => MyHomePageStateless(),
          'add_stock': (BuildContext context) => addStockPage(),
          'add_investment': (BuildContext context) => addInvestmentPage(),
          'signup': (BuildContext context) => SignUpPage(),
          'myinvestment': (BuildContext context) => MyInvestmentPage(),
          'profile': (BuildContext context) => ProfilePage(),
        },
      ),
    );
  }
}
