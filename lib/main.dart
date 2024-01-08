import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class TodoListItem extends StatefulWidget {
  final String title;
  final ValueChanged<bool> onCheckboxChanged;
  final VoidCallback onDelete;

  TodoListItem({
    required this.title,
    required this.onCheckboxChanged,
    required this.onDelete,
  });

  @override
  _TodoListItemState createState() => _TodoListItemState();
}

class _TodoListItemState extends State<TodoListItem> {
  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        widget.title,
        style: TextStyle(
          decoration: _isChecked ? TextDecoration.lineThrough : null,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: _isChecked,
            onChanged: (bool? value) {
              setState(() {
                _isChecked = value!;
                widget.onCheckboxChanged(value);
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: widget.onDelete,
          ),
        ],
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TodoList(),
    );
  }
}

class TodoList extends StatefulWidget {
  @override
  _TodoListState createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  List<String> todos = [];
  TextEditingController _textFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  _loadTodos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      todos = prefs.getStringList('todos') ?? [];
    });
  }

  _saveTodos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('todos', todos);
  }

  _addTodo(String todo) {
    setState(() {
      todos.add(todo);
      _saveTodos();
    });
  }

  _deleteTodo(int index) {
    setState(() {
      todos.removeAt(index);
      _saveTodos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('To-Do List'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _textFieldController,
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                _addTodo(value);
                _textFieldController.clear();
              }
            },
            decoration: InputDecoration(
              hintText: 'Neues To-Do hinzufügen',
              contentPadding: EdgeInsets.all(16.0),
              suffixIcon: IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  String newTodo = _textFieldController.text.trim();
                  if (newTodo.isNotEmpty) {
                    _addTodo(newTodo);
                    _textFieldController.clear();
                  }
                },
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                return TodoListItem(
                  title: todos[index],
                  onCheckboxChanged: (bool value) {
                    setState(() {
                      todos[index] = value
                          ? 'Task ${index + 1} erledigt'
                          : 'Task ${index + 1}';
                      _saveTodos();
                    });
                  },
                  onDelete: () {
                    _deleteTodo(index);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
