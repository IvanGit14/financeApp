import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:financeApp/src/widgets/homePageAppBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:financeApp/src/services/tabselected_service.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import 'package:http/http.dart' as http;

import 'package:charts_flutter/flutter.dart' as charts;

import 'package:financeApp/src/models/stock_price_model.dart';

import 'package:financeApp/src/providers/stock_price_provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class MyHomePageStateless extends StatelessWidget {
  final String title = 'Finance App';
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WidgetAppBar(),
      body: _HomePageStateless(),
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
            {
              if (ModalRoute.of(context).settings.name != 'watchlist')
                {Navigator.pushNamed(context, 'watchlist')}
            }
        },
        //Provider.of<tabselected>(context, listen: true).selected = index,
        selectedItemColor: _selectedItemColor,
        unselectedItemColor: _unselectedItemColor,
      ),
    );
  }
}

class _HomePageStateless extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: Axis.horizontal,
      children: <Widget>[
        Container(
          color: Color.fromRGBO(30, 30, 30, 1),
          width: MediaQuery.of(context).size.width,
          child: FutureBuilder(
            future: getDBWatchList(context),
            builder: (BuildContext context,
                AsyncSnapshot<Map<String, Widget>> snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    final item =
                        snapshot.data[snapshot.data.keys.elementAt(index)];
                    return Column(children: [
                      Dismissible(
                        key: UniqueKey(),
                        child: item,
                        onDismissed: (direction) {
                          final eliminado = snapshot.data.keys.elementAt(index);
                          // Remove the item from the data source.
                          snapshot.data.remove(eliminado);
                          // Then show a snackbar.
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content:
                                  Text('$eliminado deleted from watchlist')));
                        },
                        background: Container(
                          color: Color.fromRGBO(217, 82, 80, 1),
                          child: Center(
                              child: Text(
                            'DELETE',
                            style: TextStyle(color: Colors.white),
                          )),
                        ),
                        confirmDismiss: (DismissDirection direction) async {
                          return await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Confirm"),
                                content: const Text(
                                    "Are you sure you wish to delete this stock?"),
                                actions: <Widget>[
                                  TextButton(
                                      onPressed: () async {
                                        final nombre =
                                            snapshot.data.keys.elementAt(index);

                                        final jsonBody = JsonEncoder()
                                            .convert({'nombre': nombre});

                                        final url = Uri.http(
                                          '192.168.1.132:3000',
                                          '/deleteWatchlistStock',
                                        );

                                        final headers = {
                                          HttpHeaders.contentTypeHeader:
                                              'application/json'
                                        };
                                        await http.put(url,
                                            headers: headers, body: jsonBody);

                                        Navigator.of(context).pop(true);
                                      },
                                      child: const Text("OK")),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: const Text("CANCEL"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                      Divider(
                        color: Color.fromRGBO(124, 71, 122, 1),
                        thickness: 2.0,
                      )
                    ]);
                  },
                  addAutomaticKeepAlives: true,
                );
              } else {
                return Center(
                  child: Lottie.asset('assets/animations/data-animations.json'),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Future<Map<String, Widget>> getDBWatchList(BuildContext context) async {
    final stocksProvider = new stockPriceProvider();

    final queryParameters = {
      'name': '\'' + _auth.currentUser.email + '\'',
    };

    final url = Uri.http('192.168.1.132:3000', '/watchlists', queryParameters);

    final response = await http.get(url);
    final list = json.decode(response.body);

    final Map<String, Widget> resultado = {};

    for (var item in list) {
      final trailing = Container(
        width: 76,
        child: FutureBuilder(
          future: stocksProvider.getStockPrices(item['nombre']),
          builder: (BuildContext context, AsyncSnapshot<Stock> snapshot) {
            if (snapshot.hasData) {
              String resultadoStock =
                  snapshot.data.currentPrice.toString() + ' \$';
              return Text(
                resultadoStock,
                style: TextStyle(color: Colors.white),
              );
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

      final elem = Card(
        shadowColor: Color.fromRGBO(0, 0, 0, 0),
        color: Color.fromRGBO(30, 30, 30, 1),
        child: Padding(
            padding: EdgeInsets.all(10),
            child: ListTile(
              onTap: () => Overlay.of(context).insert(
                  getEntry(context, getDates(item['nombre']), item['nombre'])),
              title: Text(
                item['nombre'],
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold), // nombre stock
              ),
              focusColor: Colors.blueGrey,
              leading: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: 64,
                  minHeight: 64,
                  maxWidth: 64,
                  maxHeight: 64,
                ),
                child: getImage(item['nombre']),
              ),
              trailing: trailing,
            )),
      );

      resultado[item['nombre']] = elem;
    }

    return resultado;
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
        result =
            Image.asset('assets/images/BTC_Logo.png', fit: BoxFit.scaleDown);
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

  Future<List<charts.Series<Stock, int>>> getDates(String item) async {
    final queryParameters = {
      'name': item,
    };

    final url = Uri.http('192.168.1.132:3000', '/getLastWeek', queryParameters);

    final response = await http.get(url);
    final list = json.decode(response.body);

    final data = [
      new Stock.withParams(item, '0', list[0]['precio'].toDouble()),
      new Stock.withParams(item, '1', list[1]['precio'].toDouble()),
      new Stock.withParams(item, '2', list[2]['precio'].toDouble()),
      new Stock.withParams(item, '3', list[3]['precio'].toDouble()),
      new Stock.withParams(item, '4', list[4]['precio'].toDouble()),
      new Stock.withParams(item, '5', list[5]['precio'].toDouble()),
      new Stock.withParams(item, '6', list[6]['precio'].toDouble())
    ];

    List<charts.Series<Stock, int>> series = [
      charts.Series(
          id: "Sales",
          data: data,
          domainFn: (Stock series, _) => int.parse(series.fecha),
          measureFn: (Stock series, _) => series.currentPrice,
          colorFn: (Stock series, _) =>
              charts.MaterialPalette.blue.shadeDefault),
    ];
    return series;
  }

  OverlayEntry getEntry(BuildContext context,
      Future<List<charts.Series<Stock, int>>> seriesData, String item) {
    OverlayEntry entry;

    entry = OverlayEntry(
      opaque: false,
      maintainState: true,
      builder: (_) => Positioned(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(
            sigmaX: 2,
            sigmaY: 2,
          ),
          child: Material(
            type: MaterialType.transparency,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                      color: Color.fromRGBO(30, 30, 30, 1),
                      border: Border.all(
                        color: Color.fromRGBO(124, 71, 122, 1),
                      ),
                      borderRadius: BorderRadius.circular(4.0)),
                  margin: EdgeInsets.only(top: 60, bottom: 10),
                  width: 300,
                  height: 450,
                  child: _getChart(seriesData, item, context),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                      fixedSize: MaterialStateProperty.all(Size(50.0, 50.0)),
                      backgroundColor: MaterialStateProperty.all(
                          Color.fromRGBO(30, 30, 30, 1)),
                      padding: MaterialStateProperty.all(EdgeInsets.all(10)),
                      shape: MaterialStateProperty.all<CircleBorder>(
                        CircleBorder(
                          side: BorderSide(
                              color: Color.fromRGBO(124, 71, 122, 1)),
                        ),
                      )),
                  onPressed: () => entry.remove(),
                  child: Text('OK'),
                )
              ],
            ),
          ),
        ),
      ),
    );
    return entry;
  }

  Widget _getChart(Future<List<charts.Series<Stock, int>>> seriesData, item,
      BuildContext context) {
    return FutureBuilder(
      future: _getDataChart(context, _auth.currentUser.email, item),
      builder: (BuildContext context,
          AsyncSnapshot<Map<DateTime, double>> snapshot) {
        if (snapshot.hasData) {
          return getLineChart(snapshot.data);
        } else {
          return CircularProgressIndicator(
            backgroundColor: Color.fromRGBO(30, 30, 30, 1),
            color: Colors.amber.shade800,
          );
        }
      },
    );
  }

  SfCartesianChart getLineChart(Map<DateTime, double> data) {
    Color color = Color.fromRGBO(247, 214, 245, 0.97);

    int i = 0;

    List<ChartData> chartData = [];
    data.forEach((key, value) {
      chartData.add(ChartData(key, value, color));
      i = i + 1;
    });

    return SfCartesianChart(primaryXAxis: DateTimeAxis(), series: <ChartSeries>[
      // Renders line chart
      LineSeries<ChartData, DateTime>(
        color: Color.fromRGBO(247, 214, 245, 0.97),
        dataSource: chartData,
        xValueMapper: (ChartData data, _) => data.x,
        yValueMapper: (ChartData data, _) => data.y,
      )
    ]);
  }

  Future<Map<DateTime, double>> _getDataChart(
      BuildContext context, String nombreUsuario, String stock) async {
    final queryParameters = {
      'name': '\'' + nombreUsuario + '\'',
      'stock': '\'' + stock + '\''
    };

    final url =
        Uri.http('192.168.1.132:3000', '/getWatchlistCharts', queryParameters);

    final response = await http.get(url);
    final list = json.decode(response.body);

    final Map<DateTime, double> resultado = {};

    for (var item in list) {
      resultado[DateTime.parse(item['fecha_medicion'].substring(0, 10))] =
          item['precio'].toDouble();
    }

    return resultado;
  }
}

class ChartData {
  DateTime x;
  double y;
  Color color;

  ChartData(DateTime x, double y, Color color) {
    this.x = x;
    this.y = y;
    this.color = color;
  }
}
