class Task {
  String title;
  String description;
  String priority;
  String status;
  DateTime dueDate;

  Task({
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    required this.dueDate,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'priority': priority,
    'status': status,
    'dueDate': dueDate.toIso8601String(),
  };

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      title: json['title'],
      description: json['description'],
      priority: json['priority'] ?? "Low",
      status: json['status'] ?? "To-Do",
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'])
          : DateTime.now(),
    );
  }
}
