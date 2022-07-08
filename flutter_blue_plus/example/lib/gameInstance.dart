class GameInstance {
  var name;
  var userId;
  var total;
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
  GameInstance(name, id,  total, tor1, tor2, tor3, tor4, tor5, tor6,
      tor7, tor8, tor9, tor10) {
    this.name = name;
    this.userId = id;
    this.total = total;
    this.tor1 = tor1;
    this.tor2 = tor2;
    this.tor3 = tor3;
    this.tor4 = tor4;
    this.tor5 = tor5;
    this.tor6 = tor6;
    this.tor7 = tor7;
    this.tor8 = tor8;
    this.tor9 = tor9;
    this.tor10 = tor10;
  }
  String getAvgTime() {
    var result =
        (tor10) / 10;
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
    if (index == 1){
      return tor1;
    }
    if (index == 2){
      return tor2;
    }
    if (index == 3){
      return tor3;
    }
    if (index == 4){
      return tor4;
    }
    if (index == 5){
      return tor5;
    }
    if (index == 6){
      return tor6;
    }
    if (index == 7){
      return tor7;
    }
    if (index == 8){
      return tor8;
    }
    if (index == 1){
      return tor1;
    }
    if (index == 9){
      return tor9;
    }
    else{
      return tor10;
    }
  }
  int getTor2() {
    return tor2;
  }
  int getTor3() {
    return tor3;
  }
  int getTor4() {
    return tor4;
  }
}