class Message {
  final String content;
  final String feedback;
  final int chatIndex;

  Message({required this.content, this.feedback = "", required this.chatIndex});
}