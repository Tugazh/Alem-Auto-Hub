class FAQItemModel {
  final String id;
  final String question;
  final String answer;

  const FAQItemModel({
    required this.id,
    required this.question,
    required this.answer,
  });

  factory FAQItemModel.fromJson(Map<String, dynamic> json) {
    return FAQItemModel(
      id: json['id']?.toString() ?? '',
      question: json['question']?.toString() ?? '',
      answer: json['answer']?.toString() ?? '',
    );
  }
}
