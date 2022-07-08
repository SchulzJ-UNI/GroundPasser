import 'package:GroundPasserApp/gameInstance.dart';
import 'package:GroundPasserApp/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:timelines/timelines.dart';
import 'gameInstance.dart';

class PersonalScreen extends StatelessWidget {
  var userName = FirebaseAuth.instance.currentUser!.displayName.toString();
  var userId = FirebaseAuth.instance.currentUser!.uid.toString();
  final Stream<QuerySnapshot> _playersStream = FirebaseFirestore.instance
      .collection('bestlist')
      .orderBy('timestamp', descending: true)
      .snapshots();
  final Stream<QuerySnapshot> _profileStream = FirebaseFirestore.instance
      .collection('profils')
      .orderBy('userId')
      .snapshots();
  final device;
  var backgroundColor = Colors.black;

  var highscore =
      GameInstance('nV', 'nV', 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);

  PersonalScreen(Stream<QuerySnapshot<Object?>> usersStream, this.device) {
    //this._usersStream = usersStream;
  }

  @override
  Widget build(BuildContext context) {
    var userName = FirebaseAuth.instance.currentUser!.displayName.toString();
    var userId = FirebaseAuth.instance.currentUser!.uid.toString();
    //_updateMyProfile();
    print(userId);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('$userName´s Übersicht',
            style: TextStyle(
              fontSize: 35,
            )),
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
                      backgroundColor: backgroundColor, primary: Colors.white),
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
      body:
          ListView(shrinkWrap: true, scrollDirection: Axis.vertical, children: [
        Container(height: 5),
        const Center(
            child: Align(
                alignment: Alignment.center,
                child: Text('Versuche',
                    style: TextStyle(fontSize: 30, color: Colors.blueGrey)))),
        Container(height: 5),
        SizedBox(
            height: 150,
            child: Flex(direction: Axis.horizontal, children: [
              bestList(userId),
            ])),
        Container(
          height: 5,
          decoration: const BoxDecoration(
              border:
                  Border(bottom: BorderSide(width: 1, color: Colors.blueGrey))),
        ),
        const Center(
            child: Align(
                alignment: Alignment.center,
                child: Text('Highscore',
                    style: TextStyle(fontSize: 30, color: Colors.blueGrey)))),
        Center(
            child: Align(
          alignment: Alignment.centerLeft,
          child: _getHighscoreTotal(userId),
        )),
        SizedBox(height: 150, child: _buildAlign(userId)),
        Container(
          height: 5,
          decoration: const BoxDecoration(
              border:
                  Border(bottom: BorderSide(width: 1, color: Colors.blueGrey))),
        ),
        const Center(
            child: Align(
                alignment: Alignment.center,
                child: Text('Punkte',
                    style: TextStyle(fontSize: 30, color: Colors.blueGrey)))),
        _getPoints(),
        Container(
          height: 5,
          decoration: const BoxDecoration(
              border:
                  Border(bottom: BorderSide(width: 1, color: Colors.blueGrey))),
        ),
        const Center(
            child: Align(
                alignment: Alignment.center,
                child: Text('Trophies',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 30, color: Colors.blueGrey)))),
        Row(
          children: [
            Column(
              children: [Container(width: 5)],
            ),
            Column(children: [
              _getIcons(Icons.fitness_center, 'nrOfExc'),
              Row(children: const [
                Text('Fleißpreis ',
                    style: TextStyle(fontStyle: FontStyle.italic, fontSize: 20))
              ]),
              _getTrophyTexts('nrOfExc'),
              _getIcons(Icons.offline_bolt, 'lvlUp'),
              Row(children: const [
                Text('lvlUp ',
                    style: TextStyle(fontStyle: FontStyle.italic, fontSize: 20))
              ]),
              _getTrophyTexts('lvlUp'),
            ]),
            Column(
              children: [Container(width: 50)],
            ),
            Column(
              children: [
                _getIcons(Icons.emoji_events, 'dailyChamp'),
                Row(children: const [
                  Text('Highscorer ',
                      style:
                          TextStyle(fontStyle: FontStyle.italic, fontSize: 20))
                ]),
                _getTrophyTexts('dailyChamp'),
                _getIcons(Icons.question_mark, 'fastStarter'),
                Row(children: const [
                  Text('Überraschung',
                      style:
                          TextStyle(fontStyle: FontStyle.italic, fontSize: 20))
                ]),
                _getTrophyTexts('fastStarter'),
              ],
            )
          ],
        )
        //Text('Tagessieger')
      ]),
    );
  }

  StreamBuilder _buildAlign(String userId) {
    return StreamBuilder<QuerySnapshot>(
        stream: _playersStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return new Text('Loading...');
          return getAlignRow(snapshot, userId);
        });
  }

  Align getAlignRow(
      AsyncSnapshot<QuerySnapshot<Object?>> snapshot, String userId) {
    Align result = Align();
    var bestzeit = GameInstance('', '', 1000000.0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
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

      //Prüfen ob dieser Eintrag aus der Cloud Database ein eintrag des angemeldeten Spieler ist
      if (currentPlayer.getuserID() == userId &&
          double.parse(currentPlayer.getTotal()) <=
              double.parse(bestzeit.getTotal())) {
        bestzeit = currentPlayer;
      }
      result = Align(
          alignment: Alignment.topCenter,
          child: Timeline.tileBuilder(
            theme: TimelineThemeData(
              direction: Axis.horizontal,
              connectorTheme: ConnectorThemeData(
                  space: 10, thickness: 3, color: Colors.blueGrey),
            ),
            builder: TimelineTileBuilder.fromStyle(
              contentsAlign: ContentsAlign.alternating,
              contentsBuilder: (context, index) => Padding(
                padding: const EdgeInsets.all(9),
                child: _returnTimes(index, bestzeit),
              ),
              itemCount: 10,
            ),
          ));
    }).toList();
    return result;
  }

  Text _returnTimes(index, bestzeit) {
    //Player hs = _setHighscore(userId);
    var realIndex = index + 1;
    var torZw = 0.0;
    var gesamtZeit = bestzeit.getTorX(realIndex).toString().substring(0, 5);
    if (realIndex == 1) {
      torZw = bestzeit.getTorX(realIndex);
    } else {
      torZw = bestzeit.getTorX(realIndex) - bestzeit.getTorX(realIndex - 1);
    }
    String tor = torZw.toString();
    if (tor.length > 5) {
      tor = tor.substring(0, 5);
    }
    return Text('''Tor $realIndex:\n$tor\n $gesamtZeit''');
  }

  StreamBuilder _getHighscoreTotal(String userId) {
    return StreamBuilder<QuerySnapshot>(
        stream: _playersStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return new Text('Loading...');
          return getHighscoreRow(snapshot, userId);
        });
  }

  Text getHighscoreRow(
      AsyncSnapshot<QuerySnapshot<Object?>> snapshot, String userId) {
    Text result = Text('');
    var bestzeit = GameInstance('', '', 1000000.0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
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

      //Prüfen ob dieser Eintrag aus der Cloud Database ein eintrag des angemeldeten Spieler ist
      if (currentPlayer.getuserID() == userId &&
          double.parse(currentPlayer.getTotal()) <=
              double.parse(bestzeit.getTotal())) {
        bestzeit = currentPlayer;
      }
      var str =
          '  Gesamtzeit: ' + bestzeit.getTotal().substring(0, 6) + ' Sekunden';
      result = Text(str, style: TextStyle(fontSize: 15, color: Colors.black));
    }).toList();
    return result;
  }

  List<GameInstance> playerList = [];

  StreamBuilder bestList(uID) {
    return StreamBuilder<QuerySnapshot>(
      stream: _playersStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return new Text('Loading...');
        return Expanded(
            child: SingleChildScrollView(
                child: DataTable(columns: const <DataColumn>[
          DataColumn(
            label: Text(
              'Name',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
          DataColumn(
            label: Text(
              'Zeit',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
          DataColumn(
            label: Text(
              'Durchschnittszeit/ Pass',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
        ], rows: getRows(snapshot, uID))));
      },
    );
  }

  List<DataRow> getRows(
      AsyncSnapshot<QuerySnapshot<Object?>> snapshot, String uID) {
    List<DataRow> result = [];
    playerList = [];
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

      //Prüfen ob dieser Eintrag aus der Cloud Database ein eintrag des angemeldeten Spieler ist
      if (currentPlayer.getuserID() == uID) {
        playerList.add(currentPlayer);

        result.add(DataRow(cells: [
          DataCell(Text(data['name'].toString())),
          DataCell(Text(currentPlayer.getTotal().substring(0, 5) + ' Sek')),
          DataCell(
              Text(currentPlayer.getAvgTime().substring(0, 5) + ' Sek/Pass ')),
        ]));
      }
    }).toList();
    return result;
  }

  StreamBuilder _getPoints() {
    return StreamBuilder<QuerySnapshot>(
        stream: _profileStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return new Text('Loading...');
          return getPointRow(snapshot, userId);
        });
  }

  Row getPointRow(AsyncSnapshot<QuerySnapshot<Object?>> snapshot, String uID) {
    Row result = Row();
    var text = '';
    var level = 0;
    var percent = 0.0;
    var naechstesLevel = 100;
    snapshot.data!.docs.map((DocumentSnapshot document) {
      Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
      //neuen Eintrag als Instanz abspeichern
      var currentProfile = Profile(
        data['userId'],
        data['name'],
        data['points'],
        data['nrOfExc'],
        data['lvlUp'],
        data['dailyChamp'],
        data['fastStarter'],
        data['bestzeit'],
        data['letzteZeit'],
      );
      //print('userId: '+ userId+' und Ids aus Profile:' + currentProfile.getUserId());
      if (currentProfile.getUserId() == userId) {
        var nr = int.parse(currentProfile.getPoints());
        if (nr < 100) {
          text =
              'Level 0 \n B-Klasse\n Da geht mehr. Sammle Trophäen \n und werde besser um \n Level aufzusteigen';
          level = 0;
          naechstesLevel = 100;
          percent = nr / naechstesLevel;
        }
        if (nr >= 100 && nr < 500) {
          text =
              'Level 1 \n Kreisliga\n Das ist ein Anfang. Sammle  \n weiter Trophäen um \n Level aufzusteigen';
          level = 1;
          naechstesLevel = 500;
          percent = nr / naechstesLevel;
        }
        if (nr >= 500 && nr < 1000) {
          text =
              'Level 2 \n Regionalliga \n Super! Nur noch ein  \n kleiner Schritt \n zum Profi';
          level = 2;
          naechstesLevel = 1000;
          percent = nr / naechstesLevel;
        }
        if (nr >= 1000) {
          text =
              'Level 3 \n Bunndesliga \n Dir muss man nichts \n mehr beibringen ';
          level = 3;
          naechstesLevel = 1000;
          percent = 1;
        }
        result = Row(children: [
          Text(text),
          CircularPercentIndicator(
            radius: 60.0,
            lineWidth: 20.0,
            percent: percent,
            center: Text(
              "Level " +
                  level.toString() +
                  "\n " +
                  nr.toString() +
                  " /" +
                  naechstesLevel.toString() +
                  "\nPunkten",
              textAlign: TextAlign.center,
            ),
            progressColor: Colors.blueGrey,
          ),
          Text(
              'Level 0 - B Klasse: 0-100 Punkte \n Level 1 - Kreisliga: 100-500 Punkte \n Level 2 - Regionalliga: 500-1000 Punkte \n Level 3 - Bundesliga: >1000 Punkte')
        ]);
      }
    }).toList();
    return result;
  }

  StreamBuilder _getIcons(IconData icon, challengeIndikator) {
    return StreamBuilder<QuerySnapshot>(
        stream: _profileStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return new Text('Loading...');
          return getIconRows(snapshot, userId, icon, challengeIndikator);
          print('Test');
        });
  }

  Row getIconRows(AsyncSnapshot<QuerySnapshot<Object?>> snapshot, String uID,
      icon, challengeIndicator) {
    var hidden = Colors.grey[300];
    var bronze = const Color(0xff8c6c0d);
    var silber = Colors.grey[700];
    var gold = Colors.amber;
    var clIcon1 = hidden;
    var clIcon2 = hidden;
    var clIcon3 = hidden;
    Row result = Row();
    snapshot.data!.docs.map((DocumentSnapshot document) {
      Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
      //neuen Eintrag als Instanz abspeichern
      var currentProfile = Profile(
        data['userId'],
        data['name'],
        data['points'],
        data['nrOfExc'],
        data['lvlUp'],
        data['dailyChamp'],
        data['fastStarter'],
        data['bestzeit'],
        data['letzteZeit'],
      );
      //print('userId: '+ userId+' und Ids aus Profile:' + currentProfile.getUserId());
      if (currentProfile.getUserId() == userId) {
        var nr;
        if (challengeIndicator == 'nrOfExc') {
          nr = int.parse(currentProfile.getNrOfExc());
        }
        if (challengeIndicator == 'lvlUp') {
          nr = int.parse(currentProfile.getlvlUp());
        }
        if (challengeIndicator == 'dailyChamp') {
          nr = int.parse(currentProfile.getDailyChamp());
        }
        if (challengeIndicator == 'fastStarter') {
          nr = int.parse(currentProfile.getFastStarter());
        }
        if (nr >= 1) {
          clIcon1 = bronze;
        }
        if (nr >= 3) {
          clIcon2 = silber;
        }
        if (nr >= 5) {
          clIcon3 = gold;
        }
        result = Row(
          children: [
            Icon(icon, color: clIcon1, size: 75),
            Icon(icon, color: clIcon2, size: 75),
            Icon(icon, color: clIcon3, size: 75),
          ],
        );
      }
    }).toList();
    return result;
  }

  StreamBuilder _getTrophyTexts(challengeIndikator) {
    return StreamBuilder<QuerySnapshot>(
        stream: _profileStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return new Text('Loading...');
          return _getFleisPreisText(snapshot, userId, challengeIndikator);
          print('Test');
        });
  }

  _getFleisPreisText(AsyncSnapshot<QuerySnapshot<Object?>> snapshot, String uID,
      challengeIndicator) {
    var text1 = '';
    var text2 = '';
    var text3 = '';
    var text4 = '';
    var result = text1;
    Row resultRow = Row();
    snapshot.data!.docs.map((DocumentSnapshot document) {
      Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
      //neuen Eintrag als Instanz abspeichern
      var currentProfile = Profile(
        data['userId'],
        data['name'],
        data['points'],
        data['nrOfExc'],
        data['lvlUp'],
        data['dailyChamp'],
        data['fastStarter'],
        data['bestzeit'],
        data['letzteZeit'],
      );
      //print('userId: '+ userId+' und Ids aus Profile:' + currentProfile.getUserId());
      if (currentProfile.getUserId() == userId) {
        var nr;
        if (challengeIndicator == 'nrOfExc') {
          nr = int.parse(currentProfile.getNrOfExc());
          text1 = 'Trainiere 1 Mal um das \n Bronze Level zu erreichen\n';
          text2 =
              'Fleißig! Das Bronze Level ist erreicht\n Trainiere 3 Mal um das Silber Level zu erreichen\n';
          text3 =
              'LFG!!! Du hast das Silberlevel erreicht!\n Trainiere 5 Mal um das Gold Level zu erreichen\n';
          text4 =
              'Trainingsweltmeister! Du hast 5 mal oder \n öfter trainiert und das Gold Level erreicht.\n';
        }
        if (challengeIndicator == 'lvlUp') {
          nr = int.parse(currentProfile.getlvlUp());
          text1 =
              'Verbessere dich 1 Mal im Gegensatz\nzur vorherigen Runde um das Bronze\n Level zu erreichen';
          text2 =
              'Das Bronze Level ist erreicht!\nVerbessere dich 3 Mal am Stück\num das Silber Level zu erreichen';
          text3 =
              'Stark! Du hast das Silberlevel erreicht!\nVerbessere dich 5 Mal hintereinander\num das Gold Level zu erreichen';
          text4 =
              'Du Kontinuitätsmonster! Du hast dich\n5 mal oder öfter am Stück verbessert\nund das Gold Level erreicht. ';
        }
        if (challengeIndicator == 'dailyChamp') {
          nr = int.parse(currentProfile.getDailyChamp());
          text1 =
              'Schlage 1 mal den \nMannschaftshighscore um das \nBronze Level zu erreichen';
          text2 =
              'Das Bronze Level ist erreicht!\nSchlage 3 Mal den Teamhghscore\num das Silber Level zu erreichen';
          text3 =
              'Stark! Du hast das Silberlevel erreicht!\nSchlage 5 Mal den Teamhighscore\num das Gold Level zu erreichen';
          text4 =
              'Kneel down for the King! Du hast 5 mal\noder öfter den Teamhighscore geschlagen\nund das Gold Level erreicht. ';
        }
        if (challengeIndicator == 'fastStarter') {
          nr = int.parse(currentProfile.getFastStarter());
          text1 =
              'Finde selbst heraus, was du tun musst \nBronze Level zu erreichen';

          text2 =
              'Das Bronze Level ist erreicht!\nWiederhole die geheime Aufgabe mind.\n3 Mal um das Silber Level zu erreichen';
          text3 =
              'Weißt du was zu tun ist? Du hast das Silber-\nlevel erreicht!Wiederhole die unbekannte\nAufgabe 5 Mal für das Gold Level';
          text4 =
              'FastStarter! Du bist 5 mal oder öfter\nbei den ersten 5 Toren schneller gewesen\n als bei den letzten 5\nund hast damit das Gold Level erreicht. ';
        }
        if (nr < 1) {
          result = text1;
        }
        if (nr >= 1) {
          result = text2;
        }
        if (nr >= 3) {
          result = text3;
        }
        if (nr >= 5) {
          result = text4;
        }
        resultRow = Row(
          children: [
            Text(result, textAlign: TextAlign.center),
          ],
        );
      }
    }).toList();
    return resultRow;
  }
}
