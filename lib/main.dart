import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Android emulator reaches your computer at 10.0.2.2, not localhost
String get baseUrl {
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:3000';
  }
  return 'http://localhost:3000';
}

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Docker Tasks',
        theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
        home: const TasksPage(),
      );
}

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final _controller = TextEditingController();
  List<dynamic> _tasks = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/tasks?order=id'));
      if (res.statusCode != 200) throw 'Status ${res.statusCode}';
      setState(() {
        _tasks = jsonDecode(res.body);
        _error = null;
      });
    } catch (e) {
      setState(() => _error = 'Cannot reach API: $e');
    }
  }

  Future<void> _add() async {
    final title = _controller.text.trim();
    if (title.isEmpty) return;
    await http.post(
      Uri.parse('$baseUrl/tasks'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'title': title}),
    );
    _controller.clear();
    _load();
  }

  Future<void> _toggle(Map task) async {
    await http.patch(
      Uri.parse('$baseUrl/tasks?id=eq.${task['id']}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'done': !task['done']}),
    );
    _load();
  }

  Future<void> _delete(Map task) async {
    await http.delete(Uri.parse('$baseUrl/tasks?id=eq.${task['id']}'));
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Docker Tasks')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(hintText: 'New task'),
                  onSubmitted: (_) => _add(),
                ),
              ),
              IconButton(onPressed: _add, icon: const Icon(Icons.add)),
            ]),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            Expanded(
              child: ListView(
                children: [
                  for (final t in _tasks)
                    CheckboxListTile(
                      value: t['done'],
                      title: Text(t['title']),
                      onChanged: (_) => _toggle(t),
                      secondary: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _delete(t),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}