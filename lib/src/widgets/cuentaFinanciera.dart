import 'dart:ui' as ui;

import 'package:financeApp/src/widgets/stockStats.dart';
import 'package:flutter/material.dart';

import 'package:charts_flutter/flutter.dart' as charts;

import 'package:financeApp/src/providers/stock_price_provider.dart';
import 'package:financeApp/src/models/stock_price_model.dart';

class CuentaFinanciera extends StatelessWidget {
  String nameCuentaFinanciera;
  Image imagenCuenta;

  CuentaFinanciera(String nameCuentaFinanciera, Image imagenCuenta) {
    this.nameCuentaFinanciera = nameCuentaFinanciera;
    this.imagenCuenta = imagenCuenta;
  }

  final stocksProvider = new stockPriceProvider();
  final dates = [
    '2021-08-30',
    '2021-08-31',
    '2021-09-01',
    '2021-09-02',
    '2021-09-03',
    '2021-09-04',
    '2021-09-05'
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blueGrey,
      child: Padding(
          padding: EdgeInsets.all(10),
          child: ListTile(
            onTap: () => Overlay.of(context).insert(getEntry(context, dates)),
            title: Text(
              this.nameCuentaFinanciera,
            ),
            focusColor: Colors.blueGrey,
            leading: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: 44,
                minHeight: 44,
                maxWidth: 64,
                maxHeight: 64,
              ),
              child: this
                  .imagenCuenta, //Image.asset('assets/images/Apple_logo_black.svg.png',fit: BoxFit.cover),
            ),
            trailing: Container(width: 76, child: new stockStats('AAPL')),
          )),
    );
  }

  OverlayEntry getEntry(context, dates) {
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
                  color: Colors.blueGrey,
                  margin: EdgeInsets.only(top: 60),
                  width: 300,
                  height: 450,
                  child: new charts.LineChart(
                    _getSeriesData('APPL', dates),
                    layoutConfig: new charts.LayoutConfig(
                        leftMarginSpec: new charts.MarginSpec.fromPixel(
                            minPixel: 19, maxPixel: 55),
                        rightMarginSpec: new charts.MarginSpec.fromPixel(
                            minPixel: 10, maxPixel: 55),
                        topMarginSpec: new charts.MarginSpec.fromPixel(
                            minPixel: 10, maxPixel: 55),
                        bottomMarginSpec: new charts.MarginSpec.fromPixel(
                            minPixel: 24, maxPixel: 55)),
                    // Conf del eje de dominio "fechas"
                    domainAxis: new charts.NumericAxisSpec(
                      renderSpec: new charts.GridlineRendererSpec(
                        // Tick and Label styling here.
                        /*labelStyle: new charts.TextStyleSpec(
                            fontSize: 14, // size in Pts.
                            color: charts.MaterialPalette.white),*/
                        // Change the line colors to match text color.
                        lineStyle: new charts.LineStyleSpec(
                            color: charts.MaterialPalette.white),
                      ),
                    ),
                    // Conf del eje de valores
                    primaryMeasureAxis: new charts.NumericAxisSpec(
                        renderSpec: new charts.GridlineRendererSpec(

                            // Tick and Label styling here.
                            /*labelStyle: new charts.TextStyleSpec(
                                fontSize: 12, // size in Pts.
                                color: charts.MaterialPalette.white),*/
                            // Change the line colors to match text color.
                            lineStyle: new charts.LineStyleSpec(
                                color: charts.MaterialPalette.white))),
                    animate: true,
                    defaultRenderer: new charts.LineRendererConfig(
                      includePoints: true,
                    ),
                    behaviors: [
                      // Conf del titulo del grafico
                      new charts.ChartTitle('Evolution of APPL',
                          titleStyleSpec: charts.TextStyleSpec(
                            color: charts.MaterialPalette.white,
                          ),
                          subTitleStyleSpec: charts.TextStyleSpec(
                              color: charts.MaterialPalette.white,
                              fontSize: 15),
                          subTitle: 'last week',
                          behaviorPosition: charts.BehaviorPosition.top,
                          titlePadding: 5,
                          titleOutsideJustification:
                              charts.OutsideJustification.start,
                          innerPadding: 20),
                      // Conf para resaltar lineas del punto seleccionado
                      charts.LinePointHighlighter(
                        drawFollowLinesAcrossChart: true,
                        showVerticalFollowLine:
                            charts.LinePointHighlighterFollowLineType.all,
                        showHorizontalFollowLine:
                            charts.LinePointHighlighterFollowLineType.all,
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
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

  _getSeriesData(nameStock, dates) {
    final data = [
      new Stock.withParams('APPL', '0', 70),
      new Stock.withParams('APPL', '1', 95.6),
      new Stock.withParams('APPL', '2', 108.8),
      new Stock.withParams('APPL', '3', 137.3),
      new Stock.withParams('APPL', '4', 149),
      new Stock.withParams('APPL', '5', 146.8),
      new Stock.withParams('APPL', '6', 147.6)
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
}
