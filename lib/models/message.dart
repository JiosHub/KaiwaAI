class Message {
  final String content;
  final String translation;
  final String feedback;
  final String isUser;
  bool showTranslation;
  bool showFeedback;
  final bool isLoading;
  

  Message({
    required this.content, 
    this.translation = "", 
    this.feedback = "", 
    required this.isUser, 
    this.showTranslation = false, 
    this.showFeedback = false, 
    this.isLoading = false
  });
}