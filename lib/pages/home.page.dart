import 'dart:io';

import 'package:band_names/services/socket.servie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:band_names/models/banda.model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Banda> bandas = [];
  @override
  void initState() {
    SocketService socket = Provider.of<SocketService>(context, listen: false);
    socket.socket.on('getBandsList', (dynamic b) {
      bandas = (b as List).map((e) => Banda.fromMap(e)).toList();
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    SocketService socket = Provider.of<SocketService>(context, listen: false);
    socket.socket.off('getBandsList');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SocketService socket = Provider.of<SocketService>(context);
    bool isOnline = socket.serverStatus == ServerStatus.Online ? true : false;
    return Scaffold(
      appBar: AppBar(
        actions: [
          Container(
            margin: EdgeInsets.only(right: 10),
            child: isOnline
                ? Icon(FontAwesomeIcons.checkCircle, color: Colors.green)
                : Icon(Icons.offline_bolt, color: Colors.red),
          )
        ],
        elevation: 1,
        title: Text(
          isOnline ? "Band Names" : "Band Names: desconectado..",
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildPieChart(),
          Expanded(
            child: ListView.builder(
              itemCount: this.bandas.length,
              itemBuilder: (context, i) => _bandTile(bandas[i]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: addNewBand, child: Icon(Icons.add), elevation: 1),
    );
  }

  _buildPieChart() {
    final Map<String, double> dataMap = {};

    bandas.forEach((b) {
      dataMap.putIfAbsent("${b.name}", () => b.votes.toDouble());
    });
    List<Color> colorList = [
      Colors.pink[200],
      Colors.yellow[100],
      Colors.green[100],
      Colors.pink[50],
    ];
    return Container(
      width: double.infinity,
      height: 200,
      child: dataMap.length > 0
          ? PieChart(
              dataMap: dataMap,
              animationDuration: Duration(milliseconds: 800),
              chartLegendSpacing: 32,
              chartRadius: MediaQuery.of(context).size.width / 3.2,
              colorList: colorList,
              initialAngleInDegree: 0,
              chartType: ChartType.ring,
              ringStrokeWidth: 32,
              centerText: "Votos",
              legendOptions: LegendOptions(
                showLegendsInRow: false,
                legendPosition: LegendPosition.right,
                showLegends: true,
                // legendShape: _BoxShape.circle,
                legendTextStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              chartValuesOptions: ChartValuesOptions(
                showChartValueBackground: true,
                chartValueBackgroundColor: Colors.blue[200],
                chartValueStyle:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                decimalPlaces: 0,
                showChartValues: true,
                showChartValuesInPercentage: false,
                showChartValuesOutside: true,
              ),
            )
          : Container(),
    );
  }

  Widget _bandTile(Banda banda) {
    final socketService = Provider.of<SocketService>(context, listen: false);
    return Dismissible(
      key: Key(banda.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) {
        socketService.socket.emit("borrarBanda", {"id": banda.id});
      },
      confirmDismiss: (direction) {
        return showDialog(
            context: context,
            child: AlertDialog(
              title: Text("Eliminar Banda..."),
              content: Text("Deseas eliminar la banda: ${banda.name}"),
              actions: [
                MaterialButton(
                  textColor: Colors.blue,
                  onPressed: () => Navigator.pop(context, true),
                  child: Text("confirm"),
                  elevation: 5,
                ),
                MaterialButton(
                  textColor: Colors.red,
                  onPressed: () => Navigator.pop(context, false),
                  child: Text("No"),
                  elevation: 5,
                ),
              ],
            ));
        // return true;
      },
      background: Container(
        padding: EdgeInsets.only(left: 8),
        color: Colors.red,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(Icons.delete, color: Colors.white),
            Text("Eliminar...",
                style: TextStyle(color: Colors.white, fontSize: 20)),
          ],
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(banda.name.substring(0, 2).toUpperCase()),
          backgroundColor: Colors.blue[100],
        ),
        title: Text(banda.name),
        trailing: Text("${banda.votes}", style: TextStyle(fontSize: 20)),
        onTap: () {
          socketService.socket.emit('votar', {"id": banda.id});
        },
      ),
    );
  }

  addNewBand() {
    final textController = TextEditingController();
    if (Platform.isAndroid) {
      return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("New Band Name"),
            content: TextField(
              controller: textController,
            ),
            actions: [
              MaterialButton(
                textColor: Colors.blue,
                onPressed: () => registerBandName(textController.text),
                child: Text("ADD"),
                elevation: 5,
              ),
            ],
          );
        },
      );
    } else {
      showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text("New Band Name: "),
            content: CupertinoTextField(
              controller: textController,
            ),
            actions: [
              CupertinoDialogAction(
                child: Text('Add'),
                isDefaultAction: true,
                onPressed: () => registerBandName(textController.text),
              ),
              CupertinoDialogAction(
                child: Text("Dismiss"),
                onPressed: () => Navigator.pop(context),
                isDestructiveAction: true,
              )
            ],
          );
        },
      );
    }
  }

  void registerBandName(String name) {
    print(name);
    if (name.length > 1) {
      final socketProvider = Provider.of<SocketService>(context, listen: false);
      socketProvider.socket.emit('registrarBanda', {"nombre": name});
    }
    Navigator.pop(context);
  }
}
