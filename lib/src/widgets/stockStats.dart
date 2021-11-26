import 'package:flutter/material.dart';
import 'package:financeApp/src/models/stock_price_model.dart';

import 'package:financeApp/src/providers/stock_price_provider.dart';

class stockStats extends StatelessWidget {
  String nameStock;

  final stocksProvider = new stockPriceProvider();

  stockStats(
      this.nameStock); // definicion del constructor para pasarle el nombre del stock

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      child: FutureBuilder(
        future: stocksProvider.getStockPrices(nameStock),
        builder: (BuildContext context, AsyncSnapshot<Stock> snapshot) {
          if (snapshot.hasData) {
            String resultadoStock =
                snapshot.data.currentPrice.toString() + ' \$';
            return Text(
              resultadoStock,
            );
          } else {
            return Container(
                height: 64, child: Center(child: CircularProgressIndicator()));
          }
        },
      ),
    );
  }
}
