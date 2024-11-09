class Engine {
  String id;
  String name;

  Engine({required this.id, required this.name});

  factory Engine.fromJson(Map<String, dynamic> json) {
    return Engine(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
