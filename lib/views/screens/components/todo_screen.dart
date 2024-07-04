import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:krp/controllers/todo_controller.dart';
import 'package:krp/model/todo.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final _todoController = TodoController();
  final TextEditingController _titleController = TextEditingController();
  DateTime _selectedDateTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: _todoController.list,
        builder: (context, streamSnapshot) {
          if (streamSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!streamSnapshot.hasData || streamSnapshot.data == null) {
            return const Center(
              child: Text("No quote available"),
            );
          }

          final todos = streamSnapshot.data!.docs;

          return todos.isEmpty
              ? const Center(
                  child: Text("No available todos"),
                )
              : ListView.builder(
                  itemCount: todos.length,
                  itemBuilder: (context, index) {
                    final todo = Todo.fromQuerySnapshot(todos[index]);

                    final DateTime timestamp = todo.time.toDate();
                    final String formattedDate =
                        DateFormat('yyyy-MM-dd – kk:mm').format(timestamp);

                    return ListTile(
                      leading: todo.isDone
                          ? const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            )
                          : const Icon(Icons.check_circle_outline),
                      title: Text(todo.title),
                      subtitle: Text(formattedDate),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () => _showEditTodoDialog(todo),
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.amber,
                            ),
                          ),
                          IconButton(
                            onPressed: () => _deleteTodo(todo.id),
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      onTap: () async {
                        await _todoController.updateTodoStatus(
                          todo.id,
                          !todo.isDone,
                        );
                      },
                    );
                  },
                );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTodoDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTodoDialog() {
    _titleController.clear();
    _selectedDateTime = DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Todo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Due Date: ${DateFormat('yyyy-MM-dd').format(_selectedDateTime)}',
                    ),
                  ),
                  TextButton(
                    onPressed: _pickDate,
                    child: const Text('Select Date'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Due Time: ${DateFormat('kk:mm').format(_selectedDateTime)}',
                    ),
                  ),
                  TextButton(
                    onPressed: _pickTime,
                    child: const Text('Select Time'),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: _addTodo,
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditTodoDialog(Todo todo) {
    _titleController.text = todo.title;
    _selectedDateTime = todo.time.toDate();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Todo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Due Date: ${DateFormat('yyyy-MM-dd').format(_selectedDateTime)}',
                    ),
                  ),
                  TextButton(
                    onPressed: _pickDate,
                    child: const Text('Select Date'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Due Time: ${DateFormat('kk:mm').format(_selectedDateTime)}',
                    ),
                  ),
                  TextButton(
                    onPressed: _pickTime,
                    child: const Text('Select Time'),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => _editTodo(todo.id),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDateTime) {
      setState(() {
        _selectedDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedDateTime.hour,
          _selectedDateTime.minute,
        );
      });
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );
    if (picked != null) {
      setState(() {
        _selectedDateTime = DateTime(
          _selectedDateTime.year,
          _selectedDateTime.month,
          _selectedDateTime.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Future<void> _addTodo() async {
    if (_titleController.text.isEmpty) {
      return;
    }

    await _todoController.addTodo(
      _titleController.text,
      _selectedDateTime,
    );

    _titleController.clear();
    Navigator.of(context).pop();
  }

  Future<void> _editTodo(String id) async {
    if (_titleController.text.isEmpty) {
      return;
    }

    await _todoController.updateTodo(
      id,
      _titleController.text,
      _selectedDateTime,
    );

    _titleController.clear();
    Navigator.of(context).pop();
  }

  Future<void> _deleteTodo(String id) async {
    await _todoController.deleteTodo(id);
  }
}
