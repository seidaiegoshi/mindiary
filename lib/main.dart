import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mindiary',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        "153597970793-o59ipltl1memjvjmaap3l9la2q87rgbn.apps.googleusercontent.com",
    scopes: [
      'email',
      'https://www.googleapis.com/auth/calendar',
    ],
  );
  GoogleSignInAccount? _currentUser;
  List<dynamic> _calendarEvents = [];

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
      });
    });
    _googleSignIn.signInSilently();
  }

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }

  Future<void> _handleSignOut() => _googleSignIn.disconnect();

  Future<void> _getCalendarEvents() async {
    if (_currentUser == null) return;

    String authHeader = await _currentUser!.authHeaders
        .then((headers) => headers['Authorization']!);

    final response = await http.get(
      Uri.parse('http://localhost/calendar/events'),
      headers: {
        'Authorization': authHeader,
      },
    );

    if (response.statusCode == 200) {
      final events = json.decode(response.body);
      // Process and display the events
      setState(() {
        _calendarEvents = events;
        // print(events);
      });
    } else {
      print('Failed to fetch calendar events');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mindiary'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_currentUser != null) ...[
              CircleAvatar(
                backgroundImage: NetworkImage(_currentUser!.photoUrl ?? ''),
              ),
              Text(_currentUser!.displayName ?? '',
                  style: const TextStyle(fontSize: 24)),
              Text(_currentUser!.email, style: const TextStyle(fontSize: 18)),
              ElevatedButton(
                onPressed: _handleSignOut,
                child: const Text('Logout'),
              ),
              ElevatedButton(
                child: Text('Get Calendar Events'),
                onPressed: _getCalendarEvents,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _calendarEvents.length,
                  itemBuilder: (context, index) {
                    final event = _calendarEvents[index];
                    return ListTile(
                      title: Text(event['summary']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(event['start']),
                          Text(event['description'] ??
                              ''), // Add the description here
                        ],
                      ),
                    );
                  },
                ),
              ),
            ] else ...[
              const Text('You are not logged in.'),
              ElevatedButton(
                onPressed: _handleSignIn,
                child: const Text('Login with Google'),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
