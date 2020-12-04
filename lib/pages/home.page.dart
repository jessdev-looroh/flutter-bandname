import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:band_names/models/banda.model.dart';

class HomePage extends StatefulWidget {
  List<Banda> bandas = [
    Banda(id: "1", name: "Metallica", votes: 5),
    Banda(id: "2", name: "Heroes del silencio", votes: 1),
    Banda(id: "3", name: "Megadeth", votes: 3),
    Banda(id: "4", name: "Seresencia", votes: 12),
  ];

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Text(
          "Band Names",
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: this.widget.bandas.length,
        itemBuilder: (context, i) => _bandTile(widget.bandas[i]),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: addNewBand, child: Icon(Icons.add), elevation: 1),
    );
  }

  Widget _bandTile(Banda banda) {
    return Dismissible(
      key: Key(banda.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) {
        //TODO : LLAMAR BORRADO EN SERVER
        print(banda.id);
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
        onTap: () => {print(banda.name)},
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
    if (name.length > 1) {
      this.widget.bandas.add(
            new Banda(
              id: DateTime.now().toString(),
              name: name,
              votes: 0,
            ),
          );
      setState(() {});
    }
    Navigator.pop(context);
  }
}
