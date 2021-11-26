import 'package:postgres/postgres.dart';

/*Future conection() async {
  var connection = PostgreSQLConnection(
      "localhost", // hostURL
      5432, // port
      "finance_db", // databaseName
      username: "financeapp_user",
      password: "yw41IioC5KFjCtnCDrxjR2Z2V3");

  return await connection.open();
}*/

Future<List<Map<String, dynamic>>> getWatchlistStocks() async {
  var connection = PostgreSQLConnection(
      "192.168.1.132", // hostURL
      5432, // port
      "finance_db", // databaseName
      username: "postgres",
      password: "TlMMWe5TBXNGcQh5z829LmHSwm",
      useSSL: false);

  await connection.open();
  List<Map<String, Map<String, dynamic>>> results = await connection
      .mappedResultsQuery("SELECT * FROM flutter_apps.watchlists_stocks");

  List<Map<String, dynamic>> resultado = [];

  for (final row in results) {
    var nombre = row["watchlists_stocks"]["nombre"];
    var precio = row["watchlists_stocks"]["precio"];
    var fecha = row["watchlists_stocks"]["fecha_medicion"];

    Map<String, dynamic> stock = {
      'nombre': nombre,
      'precio': precio,
      'fecha_medicion': fecha
    };
    resultado.add(stock);
  }

  print(resultado);
  return resultado;
}
