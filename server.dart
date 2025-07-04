import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:dartz/dartz.dart';

import 'html-builder.dart';

var counter = 0;

void main() async {
    print(divide(10, 2));
    print(divide(10, 0));

    final router = Router()
        ..get('/', home)
        ..post('/api/number', count);
  
    final handler = const Pipeline()
        .addMiddleware(logRequests())
        .addHandler(router);

    final server = await shelf_io.serve(handler, 'localhost', 8080);
    print('Server running on http://${server.address.host}:${server.port}');
}

Response home(Request req) {
    final styles = '''
        body {
            font-family: Arial, sans-serif;
            max-width: 600px;
            margin: 0 auto;
            padding: 20px;
            text-align: center;
        }
        button {
            padding: 10px 20px;
            font-size: 16px;
            background-color: #4CAF50;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }
        button:hover {
            background-color: #45a049;
        }
        #result {
            margin-top: 20px;
            font-size: 24px;
            font-weight: bold;
            min-height: 30px;
        }''';

    final jsScript = '''
    async function getNumber() {
        const resultElement = document.getElementById('result');
    
        try {
            const response = await fetch('/api/number', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ requestTime: new Date().toISOString() })
            });
            
            if (!response.ok) {
                throw new Error('Server error: ' + response.status);
            }
            
            const data = await response.json();
            resultElement.innerText = 'Your number: ' + data.number;
        } catch (error) {
            resultElement.innerText = 'Error: ' + error.message;
            console.error('Error:', error);
        }
    }''';
    final res = html(
        head(
            title('Number Generator') +
            style(styles)
        ) +
        body(
            h1()('Number Generator') +
            button({'onclick': 'getNumber()'})('Get Number') +
            div({'id': 'result'})('Your number: ${counter}') +
            script(jsScript)
        )
    );

    return Response.ok(res, headers: {'Content-Type': 'text/html'});
}

Future<Response> count(Request request) async {
    counter++;
    
    return Response.ok(
        '{"number": $counter}',
        headers: {'Content-Type': 'application/json'},
    );
}

Either<String, double> divide(int a, int b) {
    if (b == 0) return left("cant divide by zero");
    return right(a / b);
}