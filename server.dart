import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:dartz/dartz.dart';
import 'package:sqlite3/sqlite3.dart';

import 'html-builder.dart';
import 'dart:convert';
import 'dart:io';

//var counterVar = 0;

class Todo {
    final int id;
    final String task;
    final DateTime createdAt;
    final bool isCompleted;

    Todo(this.id, this.task, this.createdAt, this.isCompleted);
}

typedef CounterType = ({int Function(int) add, int Function() value});

void main() async {
    var counter = () {
        int num = 0;

        return (
            value: () => num,
            add: (int n) => num += n
        );
    }();

    final db = sqlite3.open('todos.db');
    db.execute('''
        CREATE TABLE IF NOT EXISTS todos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        task TEXT NOT NULL,
        created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%d %H:%M:%S', 'now')),
        is_completed BOOLEAN DEFAULT FALSE
        );
    ''');

    //final allTodos = db.select('SELECT * FROM todos');

    final router = Router()
        ..get('/counter', (Request req) => counterHandler(req, counter))
        ..post('/api/number', (Request req) => countHandler(req, counter))
        ..get('/todo', todoHandler)
        ..post('/api/add_todo', add_todo)
        ; 

    final handler = const Pipeline()
        .addMiddleware(logRequests())
        .addHandler(router);

    final server = await shelf_io.serve(handler, 'localhost', 8080);
    print('Server running on http://${server.address.host}:${server.port}');
}

Response counterHandler(Request req, CounterType counter) {
    final styles = File('web/counter.css').readAsStringSync();
    final jsScript = File('web/counter.js').readAsStringSync();

    final res = html(
        head(
            title('Number Generator') +
            style(styles)
        ) +
        body(
            h1()('Number Generator') +
            button({'onclick': 'getNumber()'})('Get Number') +
            div({'id': 'result'})('Your number: ${counter.value()}') +
            div({'class': 'todo-input-container'})(
                input({'type': 'text', 'id': 'todoInput', 'placeholder': 'Enter a new task...'})() +
                button({'id': 'addTodoBtn'})('Add Todo')
            ) +
            script(jsScript)
        )
    );

    return Response.ok(res, headers: {'Content-Type': 'text/html'});
}

Future<Response> countHandler(Request request, CounterType counter) async {
    counter.add(1);

    return Response.ok(
        '{"number": ${counter.value()}}',
        headers: {'Content-Type': 'application/json'},
    );
}

Response todoHandler(Request req) {
    return Response.ok("");
}

Future<Response> add_todo(Request request) async {
    final body = await request.readAsString();
    final data = jsonDecode(body) as Map<String, dynamic>;

    final db = sqlite3.open('todos.db');

    try {
        db.execute(
        'INSERT INTO todos (task, due_date, is_completed) VALUES (?, ?, ?)', [
            data['task'],
            data['dueDate'] != null 
            ? DateTime.parse(data['dueDate']).toIso8601String() 
            : null,
            false
        ]);

        return Response.ok('Todo added');
    } catch (e) {
        return Response.internalServerError(body: 'Error: $e');
    } finally {
        db.dispose();
    }
}

Either<String, double> divide(int a, int b) {
    if (b == 0) return left("cant divide by zero");
    return right(a / b);
}