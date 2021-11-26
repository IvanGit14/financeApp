import 'package:financeApp/src/models/stock_price_model.dart';
import 'package:financeApp/src/providers/stock_price_provider.dart';
import 'package:financeApp/src/widgets/myInvestmentPageAppBar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'dart:convert';

import 'package:financeApp/src/services/tabselected_service.dart';
import 'package:http/http.dart' as http;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class MyInvestmentPage extends StatefulWidget {
  MyInvestmentPage({key}) : super(key: key);

  /// The page title.
  final String title = 'My Investment';

  @override
  State<StatefulWidget> createState() => _MyInvestmentPageState();
}

class _MyInvestmentPageState extends State<MyInvestmentPage> {
  User user;
  int _selectedIndex = 0;
  final _selectedItemColor = Colors.amber.shade800;
  final _unselectedItemColor = Colors.amber.shade600;
  final _selectedBgColor = Color.fromRGBO(30, 30, 30, 1);
  final _unselectedBgColor = Color.fromRGBO(30, 30, 30, 1);

  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  static const List<Widget> _widgetOptions = <Widget>[
    Text(
      'Index 0: Watchlist',
      style: optionStyle,
    ),
    Text(
      'Index 1: Other',
      style: optionStyle,
    ),
  ];

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
  void initState() {
    _auth.userChanges().listen(
          (event) => setState(() => user = event),
        );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myInvestmentAppBar(),
      body: Builder(
        builder: (BuildContext context) {
          return Container(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: FutureBuilder(
                                future: _getDataChart(
                                    context, _auth.currentUser.email),
                                builder: (BuildContext context,
                                    AsyncSnapshot<Map<String, double>>
                                        snapshot) {
                                  if (snapshot.hasData) {
                                    return getPieChart(snapshot.data);
                                  } else {
                                    return Center(
                                      child: CircularProgressIndicator(
                                        backgroundColor:
                                            Color.fromRGBO(30, 30, 30, 1),
                                        color: Colors.amber.shade800,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                            Expanded(
                              child: FutureBuilder(
                                future: _getDataChart(
                                    context, _auth.currentUser.email),
                                builder: (BuildContext context,
                                    AsyncSnapshot<Map<String, double>>
                                        snapshot) {
                                  if (snapshot.hasData) {
                                    return getRadarChart(snapshot.data);
                                  } else {
                                    return Center(
                                      child: CircularProgressIndicator(
                                        backgroundColor:
                                            Color.fromRGBO(30, 30, 30, 1),
                                        color: Colors.amber.shade800,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: FutureBuilder(
                          future: getSumInvestment(
                              context, _auth.currentUser.email),
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.hasData) {
                              return snapshot.data;
                            } else {
                              return Container(
                                height: 64,
                                child: Center(
                                  child: Lottie.asset(
                                      'assets/animations/data-animations.json'),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  // Seccion info de cada inversion
                  child: FutureBuilder(
                    future: getDBInvestment(context, _auth.currentUser.email),
                    builder: (BuildContext context,
                        AsyncSnapshot<Map<String, Widget>> snapshot) {
                      print(snapshot);
                      if (snapshot.hasData) {
                        return ListView.builder(
                          itemCount: snapshot.data.length,
                          itemBuilder: (context, index) {
                            final item = snapshot
                                .data[snapshot.data.keys.elementAt(index)];
                            return Column(
                              children: [
                                item,
                                Divider(
                                  color: Colors.amber.shade800,
                                  thickness: 1.0,
                                )
                              ],
                            );
                          },
                          addAutomaticKeepAlives: true,
                        );
                      } else {
                        return Container(
                          height: 64,
                          child: Center(
                            child: Lottie.asset(
                                'assets/animations/data-animations.json'),
                          ),
                        );
                      }
                    },
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Center(
                  // Seccion botones
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ButtonStyle(
                            fixedSize:
                                MaterialStateProperty.all(Size(60.0, 60.0)),
                            backgroundColor: MaterialStateProperty.all(
                                Color.fromRGBO(30, 30, 30, 1)),
                            shape: MaterialStateProperty.all<CircleBorder>(
                              CircleBorder(
                                side: BorderSide(
                                    color: Color.fromRGBO(124, 71, 122, 1)),
                              ),
                            )),
                        onPressed: () async {
                          Navigator.pushNamed(context, 'add_investment');
                        },
                        child: Icon(Icons.add),
                      ),
                      SizedBox(
                        width: 30,
                      ),
                      ElevatedButton(
                        style: ButtonStyle(
                            fixedSize:
                                MaterialStateProperty.all(Size(60.0, 60.0)),
                            backgroundColor: MaterialStateProperty.all(
                                Color.fromRGBO(30, 30, 30, 1)),
                            shape: MaterialStateProperty.all<CircleBorder>(
                              CircleBorder(
                                side: BorderSide(
                                    color: Color.fromRGBO(124, 71, 122, 1)),
                              ),
                            )),
                        onPressed: () => {},
                        child: Icon(Icons.edit),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
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
            {
              if (ModalRoute.of(context).settings.name != 'myinvestment')
                {Navigator.pushNamed(context, 'myinvestment')}
            }
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

Future<Widget> getSumInvestment(
    BuildContext context, String nombreUsuario) async {
  NumberFormat numberFormat = NumberFormat("#,##0.0", "en_ES");
  final queryParameters = {
    'name': '\'' + nombreUsuario + '\'',
  };

  final url =
      Uri.http('192.168.1.132:3000', '/UserInvestment', queryParameters);

  final response = await http.get(url);
  final list = json.decode(response.body);

  final stocksProvider = new stockPriceProvider();

  double totalInvested = 0;
  double totalProfit = 0;
  Stock intento;

  for (var item in list) {
    totalInvested = totalInvested + item['amount_invested'];

    intento = await stocksProvider.getStockPrices(item['stock_name']);

    totalProfit = totalProfit +
        ((item['num_stocks'] * intento.precio.toDouble()) -
            item['amount_invested']);
  }
  return Row(
    children: [
      Expanded(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          elevation: 10.0,
          shadowColor: Colors.amber.shade800,
          borderOnForeground: true,
          color: Color.fromRGBO(124, 71, 122, 1),
          child: ListTile(
            contentPadding: EdgeInsets.only(left: 5, right: 5),
            leading: Icon(
              Icons.monetization_on,
            ),
            title: Transform.translate(
              offset: Offset(-18, 0),
              child: Text(
                '${numberFormat.format(totalInvested)} \$',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            subtitle: Transform.translate(
              offset: Offset(-18, 0),
              child: Text(
                '\$ Invested',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            trailing: Icon(
              Icons.arrow_upward_outlined,
              color: Colors.greenAccent.shade200,
            ),
          ),
        ),
      ),
      Expanded(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          elevation: 10.0,
          shadowColor: Colors.amber.shade800,
          borderOnForeground: true,
          color: Color.fromRGBO(124, 71, 122, 1),
          child: ListTile(
            contentPadding: EdgeInsets.only(left: 5, right: 5),
            leading: Icon(
              Icons.monetization_on,
            ),
            title: Transform.translate(
              offset: Offset(-18, 0),
              child: Text(
                '${numberFormat.format(totalProfit)} \$',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            subtitle: Transform.translate(
              offset: Offset(-18, 0),
              child: Text(
                'Profit',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            trailing: Icon(
              Icons.arrow_upward_outlined,
              color: Colors.greenAccent.shade200,
            ),
          ),
        ),
      ),
    ],
  );
}

Future<Map<String, Widget>> getDBInvestment(
    BuildContext context, String nombreUsuario) async {
  final queryParameters = {
    'name': '\'' + nombreUsuario + '\'',
  };

  final url =
      Uri.http('192.168.1.132:3000', '/UserInvestment', queryParameters);

  final response = await http.get(url);
  final list = json.decode(response.body);

  final Map<String, Widget> resultado = {};

  for (var item in list) {
    double num_stocks = item['num_stocks'].toDouble();

    final title = Transform.translate(
      offset: Offset(0, 0),
      child: Text(
        item['amount_invested'].toString() + ' \$ Invested',
        style: TextStyle(
          fontSize: 14,
          color: Colors.white,
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    final subtitle = Transform.translate(
      offset: Offset(0, 0),
      child: Text(
        item['stock_name'],
        style: TextStyle(
          fontSize: 14,
          color: Colors.white,
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    final elem = Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28.0),
      ),
      color: Color.fromRGBO(124, 71, 122, 1),
      child: Padding(
          padding: EdgeInsets.all(2.5),
          child: ListTile(
            title: title,
            subtitle: subtitle,
            focusColor: Colors.blueGrey,
            leading: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: 64,
                minHeight: 64,
                maxWidth: 64,
                maxHeight: 64,
              ),
              child: getImage(item['stock_name']),
            ),
            trailing: getIcon(
                num_stocks, item['stock_name'], item['amount_invested']),
          )),
    );

    resultado[item['stock_name']] = elem;
  }

  return resultado;
}

Future<Map<String, double>> _getDataChart(
    BuildContext context, String nombreUsuario) async {
  final queryParameters = {
    'name': '\'' + nombreUsuario + '\'',
  };

  final url = Uri.http(
      '192.168.1.132:3000', '/getUserInvestmentCharts', queryParameters);

  final response = await http.get(url);
  final list = json.decode(response.body);

  final Map<String, double> resultado = {};

  for (var item in list) {
    resultado[item['stock_name']] = item['amount_invested'];
  }

  return resultado;
}

Widget getIcon(double numStocks, String stockName, double invested) {
  final stocksProvider = new stockPriceProvider();

  return Container(
    width: 76,
    child: FutureBuilder(
      future: stocksProvider.getStockPrices(stockName),
      builder: (BuildContext context, AsyncSnapshot<Stock> snapshot) {
        if (snapshot.hasData) {
          if (numStocks * snapshot.data.currentPrice.toDouble() > invested) {
            return Icon(
              Icons.arrow_upward_outlined,
              color: Colors.greenAccent.shade200,
            );
          } else {
            return Icon(
              Icons.arrow_downward_outlined,
              color: Colors.red.shade400,
            );
          }
        } else {
          return Container(
            height: 64,
            child: Center(
              child: CircularProgressIndicator(
                backgroundColor: Color.fromRGBO(30, 30, 30, 1),
                color: Colors.amber.shade800,
              ),
            ),
          );
        }
      },
    ),
  );
}

SfCircularChart getPieChart(Map<String, double> data) {
  List<Color> colores = [
    Color.fromRGBO(247, 214, 245, 0.97),
    Color.fromRGBO(245, 140, 241, 0.96),
    Color.fromRGBO(115, 245, 228, 0.96),
    Color.fromRGBO(124, 71, 122, 1)
  ];

  int i = 0;

  List<ChartData> chartData = [];
  data.forEach((key, value) {
    chartData.add(ChartData(key, value, colores[i]));
    i = i + 1;
  });

  return SfCircularChart(
    series: <CircularSeries>[
      PieSeries<ChartData, String>(
        strokeColor: Color.fromRGBO(124, 71, 122, 1),
        radius: '100%',
        dataSource: chartData,
        pointColorMapper: (ChartData data, _) => data.color,
        xValueMapper: (ChartData data, _) => data.x,
        yValueMapper: (ChartData data, _) => data.y,
        explode: true,
        legendIconType: LegendIconType.circle,
        dataLabelMapper: (ChartData data, _) =>
            data.x + '\n\$ ' + data.y.toString(),
        dataLabelSettings: DataLabelSettings(
          textStyle: TextStyle(
            color: Colors.white,
            fontFamily: 'Montserrat',
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
          isVisible: true,
        ),
      )
    ],
  );
}

SfCircularChart getRadarChart(Map<String, double> data) {
  List<Color> colores = [
    Color.fromRGBO(247, 214, 245, 0.97),
    Color.fromRGBO(245, 140, 241, 0.96),
    Color.fromRGBO(115, 245, 228, 0.96),
    Color.fromRGBO(124, 71, 122, 1)
  ];

  int i = 0;

  List<ChartData> chartData = [];
  data.forEach((key, value) {
    chartData.add(ChartData(key, value, colores[i]));
    i = i + 1;
  });

  Iterable inReverse = chartData.reversed;
  chartData = inReverse.toList();

  return SfCircularChart(
    series: <CircularSeries>[
      RadialBarSeries<ChartData, String>(
        radius: '100%',
        dataSource: chartData,
        xValueMapper: (ChartData data, _) => data.x,
        yValueMapper: (ChartData data, _) => data.y,
        cornerStyle: CornerStyle.bothCurve,
        pointColorMapper: (ChartData data, _) => data.color,
        trackColor: Colors.transparent,
        dataLabelMapper: (ChartData data, _) =>
            data.x + ' \$ ' + data.y.toString(),
        dataLabelSettings: DataLabelSettings(
          textStyle: TextStyle(
            color: Colors.white,
            fontFamily: 'Montserrat',
            fontSize: 7,
            fontWeight: FontWeight.bold,
          ),
          isVisible: true,
        ),
      )
    ],
  );
}

Widget getImage(String item) {
  Widget result;

  switch (item) {
    case 'AAPL':
      result = Image.asset('assets/images/apple_logo_white.png',
          fit: BoxFit.scaleDown);
      break;
    case 'NVDA':
      result = Image.asset('assets/images/Nvidia_logo.svg.png',
          fit: BoxFit.scaleDown);
      break;
    case 'TSLA':
      result =
          Image.asset('assets/images/Tesla_logo.png', fit: BoxFit.scaleDown);
      break;
    case 'INTC':
      result = Image.asset('assets/images/Intel_logo.svg.png',
          fit: BoxFit.scaleDown);
      break;
    case 'ETH':
      result = Image.asset('assets/images/Ethereum_logo.svg.png',
          fit: BoxFit.scaleDown);
      break;
    case 'GOOGL':
      result = Image.asset('assets/images/Google_Logo.svg.png',
          fit: BoxFit.scaleDown);
      break;
    case 'BTC':
      result = Image.asset('assets/images/BTC_Logo.png', fit: BoxFit.scaleDown);
      break;
    case 'MSFT':
      result = Image.asset('assets/images/Microsoft_logo.png',
          fit: BoxFit.scaleDown);
      break;
    case 'UBER':
      result =
          Image.asset('assets/images/Uber_logo.png', fit: BoxFit.scaleDown);
      break;
    default:
      result = CircleAvatar(child: Icon(Icons.monetization_on_rounded));
      break;
  }

  return result;
}

class ChartData {
  String x;
  double y;
  Color color;

  ChartData(String x, double y, Color color) {
    this.x = x;
    this.y = y;
    this.color = color;
  }
}
