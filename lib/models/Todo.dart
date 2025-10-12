
List<Todo> todosFromJson(jsonData) => (List<Todo>.from(jsonData.map((todo) => Todo.fromJson(todo))));
// List<Thread>.from(decodeData['threads'].map((thread) => Thread.fromJson(thread)));
class Todo {
  int id;
  String content;
  bool done;

  Todo({
    required this.id,
    required this.content,
    required this.done,
  });

  factory Todo.fromJson(Map<String, dynamic> json) => Todo(
    id: json["id"],
    content: json["content"],
    done: false, //for UI
  );

  Map<String, dynamic> toJson() => {
    "id": id,
  };
}