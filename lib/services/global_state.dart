import 'package:kaiwaai/models/message.dart';

class GlobalState {
  static final GlobalState _singleton = GlobalState._internal();

  factory GlobalState() {
    return _singleton;
  }

  GlobalState._internal();

  List<Message> globalMessageList = [];
  List<Message> globalApiMessageList = [];

  void clearMessageList() {
    globalMessageList.clear();
    globalApiMessageList.clear();
  }
}