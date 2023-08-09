class Message {
  final String content;
  final String feedback;
  final bool isUser;

  Message({required this.content, this.feedback = "", required this.isUser});
}