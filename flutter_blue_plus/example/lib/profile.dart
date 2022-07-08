import 'package:cloud_firestore/cloud_firestore.dart';

class Profile {
  var userId;
  var name;
  var points;
  var nrOfExc;
  var lvlUp;
  var dailyChamp;
  var fastStarter;
  var bestzeit;
  var letzteZeit;
  var teamHighscore = 10000.0;

  Profile(this.userId, this.name, this.points, this.nrOfExc, this.lvlUp, this.dailyChamp, this.fastStarter, this.bestzeit, letzteZeit) {
    print('derzeitiger user: id:'+ userId + ', name:'+ name+', points:'+points.toString()+', nrOfExc: '+nrOfExc.toString()+', lvlUp:'+ lvlUp.toString());
  }

  String getPoints() {
    return points.toString();
  }
  String getUserId() {
    return userId.toString();
  }

  String getNrOfExc() {
    return nrOfExc.toString();
  }
  String getlvlUp() {
    return lvlUp.toString();
  }

  String getDailyChamp() {
    return dailyChamp.toString();
  }

  String getFastStarter() {
    return fastStarter.toString();
  }

  upNrOfExc(total) async {
    var neu = nrOfExc + 1;
    //jedes Training gibt +10 Punkte
    await upPoints(10);
    // checken ob neues Level erreicht wurde --> bronze level = + 50 Punkte, Silber Level = + 150 Punkte, Gold Level = + 300 Punkte
    if (neu == 1){
      await upPoints(50);
    }
    if (neu == 3){
       await upPoints(150);
    }
    if (neu == 5){
      await upPoints(150);
    }
    print(userId);
    FirebaseFirestore.instance
        .collection('profils')
        .doc(userId)
        .update({'nrOfExc': neu}).then(
            (value) => print("nrOfExc successfully updated!"),
        onError: (e) => print("Error updating document $e"));
    FirebaseFirestore.instance
        .collection('profils')
        .doc(userId)
        .update({'letzteZeit': total}).then(
            (value) => print("letzte Zeit  "
            "successfully updated!"),
        onError: (e) => print("Error updating document $e"));
  }
  upPoints(anzahl) async {
    points = points + anzahl;
    print(userId);
    FirebaseFirestore.instance
        .collection('profils')
        .doc(userId)
        .update({'points': points}).then(
            (value) => print("points successfully updated!"),
        onError: (e) => print("Error updating document $e"));
  }

  uplvlUp(total) async {
    print('Letzte Zeit =' + bestzeit.toString());
    if (total < bestzeit) {
      // jedes mal Verbessern gibt +20 Punkte
      await upPoints(20);
      var neu = lvlUp + 1;
      // checken ob neues Level erreicht wurde --> bronze level = + 50 Punkte, Silber Level = + 150 Punkte, Gold Level = + 300 Punkte
      if (neu == 1){
        await upPoints(50);
      }
      if (neu == 3){
        await upPoints(150);
      }
      if (neu == 5){
        await upPoints(150);
      }
      FirebaseFirestore.instance
          .collection('profils')
          .doc(userId)
          .update({'lvlUp': neu}).then(
              (value) => print("lvlUp successfully updated!"),
          onError: (e) => print("Error updating document $e"));
    }
    FirebaseFirestore.instance
        .collection('profils')
        .doc(userId)
        .update({'bestzeit': total}).then(
            (value) => print("bestzeit successfully updated!"),
        onError: (e) => print("Error updating document $e"));
  }

  upDailyChamp(total, allTimeHs) async {
    //print('Teamhighscore =' + allTimeHs.toString() +'<--> aktuelle Zeit: '+ total.toString());
    if (total < allTimeHs) {
      // jedes mal Highscore schlagen gibt 100 Punkte
      await upPoints(100);
      var neu = dailyChamp + 1;
      // checken ob neues Level erreicht wurde --> bronze level = + 50 Punkte, Silber Level = + 150 Punkte, Gold Level = + 300 Punkte
      if (neu == 1){
        await upPoints(50);
      }
      if (neu == 3){
        await upPoints(150);
      }
      if (neu == 5){
        await upPoints(150);
      }
      FirebaseFirestore.instance
          .collection('profils')
          .doc(userId)
          .update({'dailyChamp': neu}).then(
              (value) => print("dailyChamp successfully updated!"),
          onError: (e) => print("Error updating document $e"));
      FirebaseFirestore.instance
          .collection('allTimeHighscore')
          .doc('hs')
          .update({'hs': total}).then(
              (value) => print("allTimeHs successfully updated!"),
          onError: (e) => print("Error updating document $e"));
    }
  }
  upfastStarter(tor5, tor10) async {
    if(tor5 < tor10-tor5){
      var neu = fastStarter + 1;
      // checken ob neues Level erreicht wurde --> bronze level = + 50 Punkte, Silber Level = + 150 Punkte, Gold Level = + 300 Punkte
      if (neu == 1){
        await upPoints(50);
      }
      if (neu == 3){
         await upPoints(150);
      }
      if (neu == 5){
        await upPoints(150);
      }
      FirebaseFirestore.instance
          .collection('profils')
          .doc(userId)
          .update({'fastStarter': neu}).then(
              (value) => print("fastStarter successfully updated!"),
          onError: (e) => print("Error updating document $e"));
    }
  }
}