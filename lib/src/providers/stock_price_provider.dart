import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:intl/intl.dart';

import 'package:financeApp/src/models/stock_price_model.dart';

class stockPriceProvider {
  String _apiKey = 'c4m6auqad3icjh0ed3jg';
  String _url = 'finnhub.io';

  List<Widget> _stocksDefault = [];

  final _popularesStreamController = new StreamController<
      List<
          Stock>>.broadcast(); // muchos listeners(Widgets) del stream al ser broadcast

  void _disposeStreams() {
    _popularesStreamController
        .close(); // la ? se usa para hacer una  comprobación rápida es como si existe un != null algo asi
  }

  Future<Stock> _procesarRespuesta(Uri url, String nameStock) async {
    final result = await http.get(url);
    final respuestaJSON = json.decode(result.body);

    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd');
    final fecha = formatter.format(now);

    final stocks = new Stock.fromJsonMap(respuestaJSON, fecha);
    return stocks;
  }

  Future<Stock> _procesarRespuesta_dates(
      Uri url, String nameStock, String fecha) async {
    final result = await http.get(url);
    final respuestaJSON = json.decode(result.body);

    final stocks = respuestaJSON.b[0];
    return await stocks;
  }

  Future<Stock> getStockPrices(nameStock) async {
    final url = Uri.https(_url, '/api/v1/quote', {
      'symbol': nameStock,
      'token': _apiKey,
    });
    return await _procesarRespuesta(url, nameStock);
  }

  Future<Stock> getStockPricesDates(nameStock, fecha) async {
    final url = Uri.https(_url, '/stock/bbo', {
      'symbol': nameStock,
      'token': _apiKey,
      'date': fecha,
      'limit': 500,
      'skip': 0,
      'format': 'json'
    });
    return await _procesarRespuesta_dates(url, nameStock, fecha);
  }

  Function(List<Stock>) get stocksSink => _popularesStreamController.sink.add;

  Stream<List<Stock>> get stocksStream => _popularesStreamController.stream;
}
