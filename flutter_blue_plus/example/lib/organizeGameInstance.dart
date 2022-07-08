import 'dart:convert';
import 'package:GroundPasserApp/profile.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrganizeGameInstance {
  var tor1;
  var tor2;
  var tor3;
  var tor4;
  var tor5;
  var tor6;
  var tor7;
  var tor8;
  var tor9;
  var tor10;
  var fin = false;
  var total;


  OrganizeGameInstance(BluetoothCharacteristic c, String name, String id) {
    waitForEvent(c, name, id);
  }

  waitForEvent(BluetoothCharacteristic c, String name, String id) async {
    CollectionReference users =
        FirebaseFirestore.instance.collection('bestlist');
    await for (final event in c.value) {
      if (event.isNotEmpty) {
        print(event.toString());
        if (event.toString().substring(0, 3) == "[48") {
          //print(event.first.toString());
          //var zv =utf8.decode(event).substring(3);
          tor1 = double.parse(utf8.decode(event).substring(2));
          print(tor1.toString() + " für Tor 1 abgespeichert");
        }
        if (event.toString().substring(0, 3) == "[49") {
          //print(event.first.toString());
          tor2 = double.parse(utf8.decode(event).substring(2));
          print(tor2.toString() + " für Tor 2 abgespeichert");
        }
        if (event.toString().substring(0, 3) == "[50") {
          //print(event.first.toString());
          tor3 = double.parse(utf8.decode(event).substring(2));
          print(tor3.toString() + " für Tor 3 abgespeichert");
        }
        if (event.toString().substring(0, 3) == "[51") {
          //print(event.first.toString());
          tor4 = double.parse(utf8.decode(event).substring(2));
          print(tor4.toString() + " für Tor 4 abgespeichert");
        }
        if (event.toString().substring(0, 3) == "[52") {
          //print(event.first.toString());
          tor5 = double.parse(utf8.decode(event).substring(2));
          print(tor5.toString() + " für Tor 5 abgespeichert");
        }
        if (event.toString().substring(0, 3) == "[53") {
          //print(event.first.toString());
          tor6 = double.parse(utf8.decode(event).substring(2));
          print(tor6.toString() + " für Tor 6 abgespeichert");
        }
        if (event.toString().substring(0, 3) == "[54") {
          //print(event.first.toString());
          tor7 = double.parse(utf8.decode(event).substring(2));
          print(tor7.toString() + " für Tor 7 abgespeichert");
        }
        if (event.toString().substring(0, 3) == "[55") {
          //print(event.first.toString());
          tor8 = double.parse(utf8.decode(event).substring(2));
          print(tor8.toString() + " für Tor 8 abgespeichert");
        }
        if (event.toString().substring(0, 3) == "[56") {
          //print(event.first.toString());
          tor9 = double.parse(utf8.decode(event).substring(2));
          print(tor9.toString() + " für Tor 9 abgespeichert");
        }
        if (event.toString().substring(0, 3) == "[57" && fin == false) {
          //print(event.first.toString());
          print ('fin= false davor');
          tor10 = double.parse(utf8.decode(event).substring(2));
         fin= true;
         print ('fin= false danach');
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
                'timestamp':FieldValue.serverTimestamp()
              })
              .then((value) => print("User Added"))
              .catchError((error) => print("Failed to add user: $error"));
          //print(id);
          var myProfil = await _updateMyProfile(id, users);
          var allTimeHs = await _getAllTimeHS(id);
          //print('wurde gewartet?');
          myProfil.upNrOfExc(tor10);
          myProfil.uplvlUp(tor10);
          myProfil.upDailyChamp(tor10, allTimeHs);
          myProfil.upfastStarter(tor5, tor10);
          //sleep(Duration(seconds: 3));
          print(tor10.toString() + " für Tor 10 abgespeichert");

        }
      }
    }
  }

  Future <Profile> _updateMyProfile(userId, CollectionReference<Object?> users) {
    var result= FirebaseFirestore.instance
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

      }
    );
    return result;
  }
  Future <dynamic> _getAllTimeHS (userId) {
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
