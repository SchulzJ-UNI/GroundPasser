import 'dart:convert';
import 'package:GroundPasserApp/profile.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrganizeGameInstance {
  double tor1 = 0.0;
  double tor2 = 0.0;
  double tor3 = 0.0;
  double tor4 = 0.0;
  double tor5 = 0.0;
  double tor6 = 0.0;
  double tor7 = 0.0;
  double tor8 = 0.0;
  double tor9 = 0.0;
  double tor10 = 0.0;
  double total = 0.0;
  bool fin = false;

  OrganizeGameInstance(BluetoothCharacteristic c, String name, String id) {
    waitForEvent(c, name, id);
  }

  //when this class is instanciated it waits for the remote Bluetooth device to send messages
  waitForEvent(BluetoothCharacteristic c, String name, String id) async {
    CollectionReference users =
        FirebaseFirestore.instance.collection('bestlist');
    await for (final event in c.value) {
      if (event.isNotEmpty) {
        print(event.toString());
        //these messages have an identificator at the beginning, indicating which goal was hit
        // in the following this message is checked and the time saved to the corresponding variable
        if (event.toString().substring(0, 3) == "[48") {
          tor1 = double.parse(utf8.decode(event).substring(2));
          print(tor1.toString() + " für Tor 1 abgespeichert");
        }
        if (event.toString().substring(0, 3) == "[49") {
          tor2 = double.parse(utf8.decode(event).substring(2));
          print(tor2.toString() + " für Tor 2 abgespeichert");
        }
        if (event.toString().substring(0, 3) == "[50") {
          tor3 = double.parse(utf8.decode(event).substring(2));
          print(tor3.toString() + " für Tor 3 abgespeichert");
        }
        if (event.toString().substring(0, 3) == "[51") {
          tor4 = double.parse(utf8.decode(event).substring(2));
          print(tor4.toString() + " für Tor 4 abgespeichert");
        }
        if (event.toString().substring(0, 3) == "[52") {
          tor5 = double.parse(utf8.decode(event).substring(2));
          print(tor5.toString() + " für Tor 5 abgespeichert");
        }
        if (event.toString().substring(0, 3) == "[53") {
          tor6 = double.parse(utf8.decode(event).substring(2));
          print(tor6.toString() + " für Tor 6 abgespeichert");
        }
        if (event.toString().substring(0, 3) == "[54") {
          tor7 = double.parse(utf8.decode(event).substring(2));
          print(tor7.toString() + " für Tor 7 abgespeichert");
        }
        if (event.toString().substring(0, 3) == "[55") {
          tor8 = double.parse(utf8.decode(event).substring(2));
          print(tor8.toString() + " für Tor 8 abgespeichert");
        }
        if (event.toString().substring(0, 3) == "[56") {
          tor9 = double.parse(utf8.decode(event).substring(2));
          print(tor9.toString() + " für Tor 9 abgespeichert");
        }
        // after the last goal the possibility to entry times is blocked (fin =true),
        // this try is saved in the database and the profil of the currently logged in user is updated
        if (event.toString().substring(0, 3) == "[57" && fin == false) {
          tor10 = double.parse(utf8.decode(event).substring(2));
          fin = true;
          users
              .add(<String, dynamic>{
                'tor01': tor1,
                'tor02': tor2,
                'tor03': tor3,
                'tor04': tor4,
                'tor05': tor5,
                'tor06': tor6,
                'tor07': tor7,
                'tor08': tor8,
                'tor09': tor9,
                'tor10': tor10,
                'total': tor10,
                'name': name,
                'userId': id,
                'timestamp': FieldValue.serverTimestamp()
              })
              .then((value) => print("User Added"))
              .catchError((error) => print("Failed to add user: $error"));
          var myProfil = await _updateMyProfile(id, users);
          var allTimeHs = await _getAllTimeHS(id);
          myProfil.upNrOfExc(tor10);
          myProfil.uplvlUp(tor10);
          myProfil.upDailyChamp(tor10, allTimeHs);
          myProfil.upfastStarter(tor5, tor10);
          print(tor10.toString() + " für Tor 10 abgespeichert");
        }
      }
    }
  }

  Future<Profile> _updateMyProfile(userId, CollectionReference<Object?> users) {
    var result = FirebaseFirestore.instance
        .collection('profils')
        .doc(userId)
        .get()
        .then((DocumentSnapshot documentSnaphot) {
      return Profile(
        documentSnaphot.get('userId'),
        documentSnaphot.get('name'),
        documentSnaphot.get('points'),
        documentSnaphot.get('nrOfExc'),
        documentSnaphot.get('lvlUp'),
        documentSnaphot.get('dailyChamp'),
        documentSnaphot.get('fastStarter'),
        documentSnaphot.get('bestzeit'),
        documentSnaphot.get('letzteZeit'),
      );
    });
    return result;
  }

  Future<dynamic> _getAllTimeHS(userId) {
    var result = FirebaseFirestore.instance
        .collection('allTimeHighscore')
        .doc('hs')
        .get()
        .then((DocumentSnapshot documentSnaphot) {
      return documentSnaphot.get('hs');
    });
    return result;
  }
}
