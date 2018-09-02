import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const endpointApi = "https://api.hgbrasil.com/finance?format=json&key=d2c26da8";

void main() async {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(hintColor: Colors.amber, primaryColor: Colors.white),
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(endpointApi);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController realController = TextEditingController();
  final TextEditingController dolarController = TextEditingController();
  final TextEditingController euroController = TextEditingController();

  double _dolarCotacao;
  double _euroCotacao;

  void _realChanged (String text) {
    double real = double.parse(text);
    dolarController.text = (real/_dolarCotacao).toStringAsFixed(2);
    euroController.text = (real/_euroCotacao).toStringAsFixed(2);
  }

  void _dolarChanged (String text) {
    double dolar = double.parse(text);
    realController.text = (dolar * _dolarCotacao).toStringAsFixed(2);
    euroController.text = (dolar * _dolarCotacao / _euroCotacao).toStringAsFixed(2);
  }

  void _euroChanged (String text) {
    double euro = double.parse(text);
    realController.text = (euro * _euroCotacao).toStringAsFixed(2);
    euroController.text = (euro * _euroCotacao / _dolarCotacao).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text("\$ Conversor"),
          backgroundColor: Colors.amber,
          centerTitle: true,
        ),
        body: FutureBuilder<Map>(
            future: getData(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return Center(
                      child: Text("Carregando dados...",
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(color: Colors.amber, fontSize: 25.0)));
                default:
                  if (snapshot.hasError) {
                    return Center(
                        child: Text("Erro ao carregar dados :(",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.amber, fontSize: 25.0)));
                  } else {
                    _dolarCotacao = snapshot.data['results']['currencies']['USD']['buy'];
                    _euroCotacao = snapshot.data['results']['currencies']['EUR']['buy'];

                    return SingleChildScrollView(
                      padding: EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Icon(Icons.monetization_on,
                              size: 150.0, color: Colors.amber),
                          buildTextField("Reais", "R\$", realController, _realChanged),
                          Divider(),
                          buildTextField("Dolares", "US\$", dolarController, _dolarChanged),
                          Divider(),
                          buildTextField("Euros", "€", euroController, _euroChanged)
                        ],
                      ),
                    );
                  }
              }
            }));
  }
}

Widget buildTextField(
    String label, String prefix, TextEditingController controller, Function onChanged) {
  return TextField(
    controller: controller,
    onChanged: onChanged,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.amber),
        border: OutlineInputBorder(),
        prefixText: prefix),
    style: TextStyle(color: Colors.amber, fontSize: 25.0),
    keyboardType: TextInputType.number,
  );
}
