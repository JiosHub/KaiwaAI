import 'package:unichat_ai/models/message.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GlobalState {

  static final GlobalState _singleton = GlobalState._internal();

  factory GlobalState() {
    return _singleton;
  }

  GlobalState._internal();

  List<Message> globalMessageList = [];
  List<Message> globalApiMessageList = [];
  String globalLanguage = "";
  int globalGPT4MessageCount = -1;
  int globalGPT35MessageCount = -1;

  void clearMessageList() {
    globalMessageList.clear();
    globalApiMessageList.clear();
  }
}