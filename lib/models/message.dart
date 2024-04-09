class Message {
  bool isSender;
  String msg;
  late DateTime timestamp;
  Message(this.isSender, this.msg) {
    timestamp = DateTime.now();
  }
  
}