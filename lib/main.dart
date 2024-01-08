import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}


class TodoListItem extends StatefulWidget {
  final String title;
  final ValueChanged<bool> onCheckboxChanged;

  TodoListItem({required this.title, required this.onCheckboxChanged});

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
      trailing: Checkbox(
        value: _isChecked,
        onChanged: (bool? value) {
          setState(() {
            _isChecked = value!;
            widget.onCheckboxChanged(value);
          });
        },
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('To-Do List'),
      ),
      body: Column(
        children: [
          TextField(
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                _addTodo(value);
              }
            },
            decoration: InputDecoration(
              hintText: 'Neues To-Do hinzufügen',
              contentPadding: EdgeInsets.all(16.0),
              suffixIcon: IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  // Hier kannst du die Aktion beim Drücken des Hinzufügen-Icons hinzufügen
                  // Zum Beispiel kannst du _addTodo mit dem aktuellen Text des Textfelds aufrufen.
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
                      todos[index] = value ? 'Task ${index + 1} erledigt' : 'Task ${index + 1}';
                      _saveTodos();
                    });
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