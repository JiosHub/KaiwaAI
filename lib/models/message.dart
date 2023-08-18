class Message {
  final String content;
  final String feedback;
  final String isUser;

  Message({required this.content, this.feedback = "", required this.isUser});
}