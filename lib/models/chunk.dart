class LLmChunk {
  final String type;
  final String text;
  final String? name;
  final String? status;
  final bool done;

  LLmChunk({
    required this.type,
    required this.text,
    this.name,
    this.status,
    required this.done,
  });

  factory LLmChunk.fromJson(Map<String, dynamic> json) {
    return LLmChunk(
      type: json['type'],
      text: json['text'] ?? '',
      name: json['name'],
      status: json['status'],
      done: json['done'] as bool,
    );
  }
}
