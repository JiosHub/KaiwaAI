class Message {
  final String content;
  final String feedback;
  final String isUser;
  bool showFeedback;

  Message({required this.content, this.feedback = "", required this.isUser, this.showFeedback = false});
}