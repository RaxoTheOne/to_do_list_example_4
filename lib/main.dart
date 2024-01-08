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
      title: Center(
        child: Text(
          widget.title,
          style: TextStyle(
            decoration: _isChecked ? TextDecoration.lineThrough : null,
          ),
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
      onTap: () {
        setState(() {
          _isChecked = !_isChecked;
          widget.onCheckboxChanged(_isChecked);
        });
      },
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('To-Do List'),
        ),
        body: Center(
          child: TodoList(),
        ),
      ),
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

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
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
    );
  }
}