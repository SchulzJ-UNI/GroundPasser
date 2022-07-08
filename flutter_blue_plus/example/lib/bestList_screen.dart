import 'package:GroundPasserApp/personalScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'gameInstance.dart';

class BestListScreen extends StatelessWidget {
  var backgroundColor = Colors.black;
  final _gameInstancesStream;
  final device;
  BestListScreen(
      Stream<QuerySnapshot<Object?>> this._gameInstancesStream, this.device);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //show the headline 'Teamoverview' and the disconnect/connect button on top of the page
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text('Teamübersicht'),
          actions: <Widget>[
            StreamBuilder<BluetoothDeviceState>(
              stream: device.state,
              initialData: BluetoothDeviceState.connecting,
              builder: (c, snapshot) {
                VoidCallback? onPressed;
                String text;
                switch (snapshot.data) {
                  case BluetoothDeviceState.connected:
                    backgroundColor = Colors.black;
                    onPressed = () => device.disconnect();
                    text = 'DISCONNECT';
                    break;
                  case BluetoothDeviceState.disconnected:
                    backgroundColor = Colors.red;
                    onPressed = () => device.connect();
                    text = 'CONNECT';
                    break;
                  default:
                    onPressed = null;
                    text = snapshot.data.toString().substring(21).toUpperCase();
                    break;
                }
                return TextButton(
                    onPressed: onPressed,
                    style: TextButton.styleFrom(
                        backgroundColor: backgroundColor,
                        primary: Colors.white),
                    child: Text(
                      text,
                      style: Theme.of(context)
                          .primaryTextTheme
                          .button
                          ?.copyWith(color: Colors.white),
                    ));
              },
            )
          ],
        ),
        // body has two parts: 1) a scrollable list of every personal highscore from the registrated persons and a button toget to the prsonal overview
        body: ListView(children: [
          Container(height: 20),
          const Center(
              child: Align(
                  alignment: Alignment.topCenter,
                  child: Text('Teamübersicht',
                      style: TextStyle(fontSize: 60, color: Colors.teal)))),
          Container(height: 20),
          Center(
              child: Align(alignment: Alignment.topCenter, child: bestList())),
          Container(height: 20),
          Row(children: [
            Column(
              children: [Container(width: 190)],
            ),
            //Button to the next page
            Column(children: [
              ElevatedButton.icon(
                  label: const Text('Persönliche Übersicht'),
                  icon: const Icon(Icons.analytics_outlined),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black,
                  ),
                  onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => PersonalScreen(device)),
                      ))
            ]),
            Column()
          ]),
        ]));
  }

  //methods needed to get the data from the databases and get them into a nice form
  List<GameInstance> playerList = [];

  bool _checkIfBestTime(GameInstance currentPlayer) {
    var result = false;
    for (GameInstance p in playerList) {
      if (playerList.isNotEmpty && p.userId == currentPlayer.userId) {
        if (p.total <= currentPlayer.total) {
          // true = ein bisheriger Eintrag mit der gleichen ID hatte eine bessere Zeit --> jetztigen Eintrag nicht hinzufügen
          result = true;
        }
      }
    }
    if (result == false) {
      playerList.add(currentPlayer);
    }
    return result;
  }

  StreamBuilder bestList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _gameInstancesStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return const Text('Loading...');
        return DataTable(columns: const <DataColumn>[
          DataColumn(
            label: Text(
              'Name',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
          DataColumn(
            label: Text(
              'Bestzeit',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
          DataColumn(
            label: Text(
              'Durchschnittszeit/ Pass',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
        ], rows: getRows(snapshot));
      },
    );
  }

  List<DataRow> getRows(AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
    List<DataRow> result = [];

    snapshot.data!.docs.map((DocumentSnapshot document) {
      Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
      //neuen Eintrag als Instanz abspeichern
      var currentPlayer = GameInstance(
          data['name'],
          data['userId'],
          data['total'],
          data['tor01'],
          data['tor02'],
          data['tor03'],
          data['tor04'],
          data['tor05'],
          data['tor06'],
          data['tor07'],
          data['tor08'],
          data['tor09'],
          data['tor10']);
      //Prüfen ob für gleichen Spieler schon ein Eintrag vorhanden
      // Wenn schon gleicher Einträge vorhanden, prüfen ob dieser Eintrag eine besser Zeit hat --> wenn ja: keine neue Zeile hinzufügen
      var samePlayerhasBetterTime = _checkIfBestTime(currentPlayer);
      if (samePlayerhasBetterTime == false) {
        result.add(DataRow(cells: [
          DataCell(Text(data['name'].toString())),
          DataCell(Text(currentPlayer.getTotal())),
          DataCell(Text(currentPlayer.getAvgTime())),
        ]));
      }
    }).toList();
    return result;
  }
}
