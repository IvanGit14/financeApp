import 'dart:io';

import 'package:email_validator/email_validator.dart';
import 'package:financeApp/src/widgets/myInvestmentPageAppBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:provider/provider.dart';

import 'package:http/http.dart' as http;

import 'package:financeApp/src/widgets/homePageAppBar.dart';
import 'package:financeApp/src/services/tabselected_service.dart';
import 'package:financeApp/src/providers/stock_price_provider.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class addInvestmentPage extends StatelessWidget {
  int _selectedIndex = 0;
  final _selectedItemColor = Colors.amber.shade800;
  final _unselectedItemColor = Colors.amber.shade600;
  final _selectedBgColor = Color.fromRGBO(30, 30, 30, 1);
  final _unselectedBgColor = Color.fromRGBO(30, 30, 30, 1);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _stocknameController = TextEditingController();
  final TextEditingController _amountInvestedController =
      TextEditingController();
  final TextEditingController _numStocksController = TextEditingController();

  Color _getBgColor(int index) =>
      _selectedIndex == index ? _selectedBgColor : _unselectedBgColor;

  Color _getItemColor(int index) =>
      _selectedIndex == index ? _selectedItemColor : _unselectedItemColor;

  Widget _buildIcon(IconData iconData, String text, int index) => Container(
        width: double.infinity,
        height: kBottomNavigationBarHeight,
        child: Material(
          color: _getBgColor(index),
          child: InkWell(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(iconData),
                Text(text,
                    style:
                        TextStyle(fontSize: 12, color: _getItemColor(index))),
              ],
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myInvestmentAppBar(),
      body: _addInvestmentPageBody(context),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color.fromRGBO(30, 30, 30, 1),
        selectedFontSize: 0,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: _buildIcon(Icons.remove_red_eye, 'Watchlist', 0),
            title: SizedBox.shrink(),
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(Icons.show_chart, 'My Investment', 1),
            title: SizedBox.shrink(),
          ),
        ],
        currentIndex: Provider.of<tabselected>(context, listen: true).selected,
        onTap: (index) => {
          if (index == 1)
            {Navigator.pushNamed(context, 'myinvestment')}
          else
            {Navigator.pushNamed(context, 'watchlist')}
        },
        //Provider.of<tabselected>(context, listen: true).selected = index,
        selectedItemColor: _selectedItemColor,
        unselectedItemColor: _unselectedItemColor,
      ),
    );
  }

  Widget _addInvestmentPageBody(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
        image: AssetImage('assets/images/investment_fondo2.jpg'),
        fit: BoxFit.cover,
      )),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Form(
            autovalidateMode: AutovalidateMode.always,
            key: _formKey,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      alignment: Alignment.center,
                      child: const Text(
                        'Add your investment data',
                        style: TextStyle(
                          color: Color.fromRGBO(30, 30, 30, 1),
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    TextFormField(
                      controller: _stocknameController,
                      decoration: InputDecoration(
                        labelText: 'Stock Name: ',
                      ),
                      validator: (String value) {
                        if (value != null && !EmailValidator.validate(value)) {
                          return "Please enter a valid stock name";
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _amountInvestedController,
                      decoration: InputDecoration(
                        labelText: 'Amount Invested: ',
                      ),
                      validator: (String value) {
                        if (value.isEmpty) return 'Please some valid quantity';
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _numStocksController,
                      decoration: InputDecoration(
                        labelText: 'Number of stocks: ',
                      ),
                      validator: (String value) {
                        if (value != null && !EmailValidator.validate(value)) {
                          return "Please enter a valid number";
                        }
                        return null;
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(top: 16, right: 10),
                          alignment: Alignment.center,
                          child: ElevatedButton(
                            onPressed: () async {
                              final stock_name = _stocknameController.text;
                              final amount_invested =
                                  _amountInvestedController.text;
                              final num_stocks = _numStocksController.text;

                              final jsonBody = JsonEncoder().convert({
                                'name': _auth.currentUser.email,
                                'stock_name': stock_name,
                                'amount_invested': amount_invested,
                                'num_stocks': num_stocks
                              });

                              final url = Uri.http(
                                '192.168.1.132:3000',
                                '/UserInvestment',
                              );

                              final headers = {
                                HttpHeaders.contentTypeHeader:
                                    'application/json'
                              };
                              await http.post(url,
                                  headers: headers, body: jsonBody);

                              Navigator.pushNamed(context, 'watchlist');
                            },
                            child: Text(
                              'CONFIRM',
                              style: TextStyle(
                                color: Color.fromRGBO(30, 30, 30, 1),
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              primary: Colors.white,
                              side: BorderSide(
                                  color: Color.fromRGBO(124, 71, 122, 1)),
                              shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(30.0),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(top: 16),
                          alignment: Alignment.center,
                          child: ElevatedButton(
                            onPressed: () async {
                              Navigator.pushNamed(context, 'watchlist');
                            },
                            child: Text(
                              'CANCEL',
                              style: TextStyle(
                                color: Color.fromRGBO(30, 30, 30, 1),
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              side: BorderSide(
                                  color: Color.fromRGBO(124, 71, 122, 1)),
                              primary: Colors.white,
                              shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(30.0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
