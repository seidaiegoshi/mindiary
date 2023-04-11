import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Google Login Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/calendar',
    ],
  );
  GoogleSignInAccount? _currentUser;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Google Login Demo'),
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
                  style: TextStyle(fontSize: 24)),
              Text(_currentUser!.email, style: TextStyle(fontSize: 18)),
              ElevatedButton(
                child: Text('Logout'),
                onPressed: _handleSignOut,
              ),
            ] else ...[
              Text('You are not logged in.'),
              ElevatedButton(
                child: Text('Login with Google'),
                onPressed: _handleSignIn,
              ),
            ]
          ],
        ),
      ),
    );
  }
}
