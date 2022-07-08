import 'package:cloud_firestore/cloud_firestore.dart';

class Profile {
  String userId;
  String name;
  num points;
  num nrOfExc;
  num lvlUp;
  num dailyChamp;
  num fastStarter;
  double bestzeit;
  double letzteZeit = 0.0;
  double teamHighscore = 10000.0;

  Profile(this.userId, this.name, this.points, this.nrOfExc, this.lvlUp,
      this.dailyChamp, this.fastStarter, this.bestzeit, letzteZeit) {
    print('derzeitiger user: id:' +
        userId +
        ', name:' +
        name +
        ', points:' +
        points.toString() +
        ', nrOfExc: ' +
        nrOfExc.toString() +
        ', lvlUp:' +
        lvlUp.toString());
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

  // increases the number of Exercise of the player currently logged in by one
  upNrOfExc(total) async {
    var neu = nrOfExc + 1;
    //every exercise gives +10 points
    await upPoints(10);
    // check if a new level was reached --> bronze level = + 50 points, Silber Level = + 150 points, Gold Level = + 300 points
    if (neu == 1) {
      await upPoints(50);
    }
    if (neu == 3) {
      await upPoints(150);
    }
    if (neu == 5) {
      await upPoints(150);
    }
    //updates nrOf Exc in the database
    FirebaseFirestore.instance
        .collection('profils')
        .doc(userId)
        .update({'nrOfExc': neu}).then(
            (value) => print("nrOfExc successfully updated!"),
            onError: (e) => print("Error updating document $e"));
    //updates last recorded time for this user in the database
    FirebaseFirestore.instance
        .collection('profils')
        .doc(userId)
        .update({'letzteZeit': total}).then(
            (value) => print("letzte Zeit  "
                "successfully updated!"),
            onError: (e) => print("Error updating document $e"));
  }

  //updates the points of the currently logged in user in the database
  upPoints(anzahl) async {
    points = points + anzahl;
    FirebaseFirestore.instance
        .collection('profils')
        .doc(userId)
        .update({'points': points}).then(
            (value) => print("points successfully updated!"),
            onError: (e) => print("Error updating document $e"));
  }

  // updates if the player has beaten his own highscore
  uplvlUp(total) async {
    if (total < bestzeit) {
      // every time a player beats his own highscore +20 Punkte
      await upPoints(20);
      var neu = lvlUp + 1;
      // check if a new level was reached --> bronze level = + 50 points, Silber Level = + 150 points, Gold Level = + 300 points
      if (neu == 1) {
        await upPoints(50);
      }
      if (neu == 3) {
        await upPoints(150);
      }
      if (neu == 5) {
        await upPoints(150);
      }
      //update in database
      FirebaseFirestore.instance
          .collection('profils')
          .doc(userId)
          .update({'lvlUp': neu}).then(
              (value) => print("lvlUp successfully updated!"),
              onError: (e) => print("Error updating document $e"));
    }
    //update the personal highscore
    FirebaseFirestore.instance
        .collection('profils')
        .doc(userId)
        .update({'bestzeit': total}).then(
            (value) => print("bestzeit successfully updated!"),
            onError: (e) => print("Error updating document $e"));
  }

  // check and then update if the current runthrough was the all time best
  upDailyChamp(total, allTimeHs) async {
    if (total < allTimeHs) {
      var neu = dailyChamp + 1;
      // ever time beating the all time highscore are + 100 points
      await upPoints(100);
      // check if a new level was reached --> bronze level = + 50 points, Silber Level = + 150 points, Gold Level = + 300 points
      if (neu == 1) {
        await upPoints(50);
      }
      if (neu == 3) {
        await upPoints(150);
      }
      if (neu == 5) {
        await upPoints(150);
      }
      //update number of dailyChamp in database for the currently logged in player
      FirebaseFirestore.instance
          .collection('profils')
          .doc(userId)
          .update({'dailyChamp': neu}).then(
              (value) => print("dailyChamp successfully updated!"),
              onError: (e) => print("Error updating document $e"));
      //update the all time highscore for every player
      FirebaseFirestore.instance
          .collection('allTimeHighscore')
          .doc('hs')
          .update({'hs': total}).then(
              (value) => print("allTimeHs successfully updated!"),
              onError: (e) => print("Error updating document $e"));
    }
  }

  //check if the first five goals were faster then the latter 5 five goals. This is the KPI for the "surprise" batch
  upfastStarter(tor5, tor10) async {
    if (tor5 < tor10 - tor5) {
      var neu = fastStarter + 1;
      // check if a new level was reached --> bronze level = + 50 points, Silber Level = + 150 points, Gold Level = + 300 points
      if (neu == 1) {
        await upPoints(50);
      }
      if (neu == 3) {
        await upPoints(150);
      }
      if (neu == 5) {
        await upPoints(150);
      }
      //update fast Starter for currently logged in player in the database
      FirebaseFirestore.instance
          .collection('profils')
          .doc(userId)
          .update({'fastStarter': neu}).then(
              (value) => print("fastStarter successfully updated!"),
              onError: (e) => print("Error updating document $e"));
    }
  }
}
