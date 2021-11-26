import 'dart:io';

import 'package:financeApp/src/widgets/myInvestmentPageAppBar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:provider/provider.dart';

import 'package:http/http.dart' as http;

import 'package:financeApp/src/widgets/homePageAppBar.dart';
import 'package:financeApp/src/services/tabselected_service.dart';
import 'package:financeApp/src/providers/stock_price_provider.dart';

class addStockPage extends StatelessWidget {
  int _selectedIndex = 0;
  final _selectedItemColor = Colors.amber.shade800;
  final _unselectedItemColor = Colors.amber.shade600;
  final _selectedBgColor = Color.fromRGBO(30, 30, 30, 1);
  final _unselectedBgColor = Color.fromRGBO(30, 30, 30, 1);

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
      body: _addStockPageBody(context),
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
}

Widget _addStockPageBody(BuildContext context) {
  return Flex(
    direction: Axis.horizontal,
    children: <Widget>[
      Container(
        color: Color.fromRGBO(30, 30, 30, 1),
        width: MediaQuery.of(context).size.width,
        child: FutureBuilder(
          future: _getAllStockNames(context),
          builder:
              (BuildContext context, AsyncSnapshot<List<Widget>> snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  final item = snapshot.data[index];
                  return Column(
                    children: [
                      item,
                      Divider(
                        color: Color.fromRGBO(124, 71, 122, 1),
                        thickness: 2.0,
                      ),
                    ],
                  );
                },
                addAutomaticKeepAlives: true,
              );
            } else {
              return Center(
                child: CircularProgressIndicator(
                  backgroundColor: Color.fromRGBO(30, 30, 30, 1),
                  color: Colors.amber.shade800,
                ),
              );
            }
          },
        ),
      ),
    ],
  );
}

Future<List<Widget>> _getAllStockNames(BuildContext context) async {
  String _apiKey = 'c4m6auqad3icjh0ed3jg';
  String _url = 'finnhub.io';

  final url = Uri.https(_url, '/api/v1/stock/symbol', {
    'exchange': 'US',
    'mic': 'XNYS',
    'token': _apiKey,
  });

  final response = await http.get(url);
  final list = json.decode(response.body);

  final List<Widget> resultado = [];

  for (var item in list) {
    final elem = Card(
      shadowColor: Color.fromRGBO(0, 0, 0, 0),
      color: Color.fromRGBO(30, 30, 30, 1),
      child: Padding(
          padding: EdgeInsets.all(10),
          child: ListTile(
            onTap: () async {
              final nombre = item['displaySymbol'];
              final now = new DateTime.now();
              final formatter = new DateFormat('yyyy-MM-dd');
              final date = formatter.format(now);
              final id_user = 0;
              final stocksProvider = new stockPriceProvider();
              final precio = '0';

              final jsonBody = JsonEncoder().convert({
                'nombre': nombre,
                'fecha_medicion': date,
                'id_user': id_user,
                'precio': precio
              });

              final url = Uri.http(
                '192.168.1.132:3000',
                '/addWatchlistStock',
              );

              final headers = {
                HttpHeaders.contentTypeHeader: 'application/json'
              };
              await http.post(url, headers: headers, body: jsonBody);
              Navigator.pushNamed(context, 'watchlist');
            },
            title: Text(
              item['description'],
              style: TextStyle(color: Colors.white), // nombre stock
            ),
            subtitle: Text(item['displaySymbol'],
                style: TextStyle(color: Colors.white) // nombre stock
                ),
            focusColor: Colors.blueGrey,
            leading: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: 44,
                  minHeight: 44,
                  maxWidth: 64,
                  maxHeight: 64,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.monetization_on_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () {},
                )),
          )),
    );
    resultado.add(elem);
  }

  return resultado;
}
