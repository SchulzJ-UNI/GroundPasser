class GameInstance {
  String name;
  String userId;
  double total;
  double tor1;
  double tor2;
  double tor3;
  double tor4;
  double tor5;
  double tor6;
  double tor7;
  double tor8;
  double tor9;
  double tor10;

  //class for instances for one run in the game
  GameInstance(
      this.name,
      this.userId,
      this.total,
      this.tor1,
      this.tor2,
      this.tor3,
      this.tor4,
      this.tor5,
      this.tor6,
      this.tor7,
      this.tor8,
      this.tor9,
      this.tor10);

  String getAvgTime() {
    var result = (tor10) / 10;
    return result.toString();
  }

  String getTotal() {
    return total.toString();
  }

  String getuserID() {
    return userId.toString();
  }

  String getName() {
    return name.toString();
  }

  double getTorX(int index) {
    if (index == 1) {
      return tor1;
    }
    if (index == 2) {
      return tor2;
    }
    if (index == 3) {
      return tor3;
    }
    if (index == 4) {
      return tor4;
    }
    if (index == 5) {
      return tor5;
    }
    if (index == 6) {
      return tor6;
    }
    if (index == 7) {
      return tor7;
    }
    if (index == 8) {
      return tor8;
    }
    if (index == 1) {
      return tor1;
    }
    if (index == 9) {
      return tor9;
    } else {
      return tor10;
    }
  }
}
