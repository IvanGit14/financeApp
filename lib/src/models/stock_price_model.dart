class Stocks {
  List<Stock> items = [];

  Stocks();

  Stocks.fromJsonList(dynamic jsonList, fecha) {
    if (jsonList == null) return;

    for (var item in jsonList) {
      final stock = new Stock.fromJsonMap(item, fecha);
      items.add(stock);
    }
  }
}

class Stock {
  String nameStock;
  String fecha;
  double openPrice;
  double highPrice;
  double lowPrice;
  double currentPrice;
  double previousClosePrice;

  Stock({
    this.nameStock,
    this.fecha,
    this.openPrice,
    this.highPrice,
    this.lowPrice,
    this.currentPrice,
    this.previousClosePrice,
  });

  String get nombre {
    return this.nameStock;
  }

  double get precio {
    return this.currentPrice;
  }

  Stock.withParams(String nameStock, String fecha, double currentPrice) {
    this.currentPrice = currentPrice;
    this.nameStock = nameStock;
    this.fecha = fecha;
  }

  Stock.fromJsonMap(Map<String, dynamic> json, String fecha) {
    nameStock = 'AAPL';
    fecha = fecha;
    if (json['o'] != null &&
        json['h'] != null &&
        json['l'] != null &&
        json['c'] != null &&
        json['pc'] != null) {
      openPrice = json['o'].toDouble();
      highPrice = json['h'].toDouble();
      lowPrice = json['l'].toDouble();
      currentPrice = json['c'].toDouble();
      previousClosePrice = json['pc'].toDouble();
    } else {
      openPrice = 0.0;
      highPrice = 0.0;
      lowPrice = 0.0;
      currentPrice = 0.0;
      previousClosePrice = 0.0;
    }
  }
}
