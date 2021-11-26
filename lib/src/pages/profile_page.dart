import 'package:financeApp/src/widgets/myInvestmentPageAppBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:financeApp/src/services/tabselected_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

/// Helper class to show a snackbar using the passed context.
class ScaffoldSnackbar {
  ScaffoldSnackbar(this._context);
  final BuildContext _context;

  /// The scaffold of current context.
  factory ScaffoldSnackbar.of(BuildContext context) {
    return ScaffoldSnackbar(context);
  }

  /// Helper method to show a SnackBar.
  void show(String message) {
    ScaffoldMessenger.of(_context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }
}

final FirebaseAuth _auth = FirebaseAuth.instance;

final GoogleSignIn googleSignIn = new GoogleSignIn();

class ProfilePage extends StatefulWidget {
  ProfilePage({key}) : super(key: key);

  /// The page title.
  final String title = 'Profile';

  @override
  State<StatefulWidget> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User user;
  int _selectedIndex = 0;
  final _selectedItemColor = Colors.amber.shade800;
  final _unselectedItemColor = Colors.amber.shade600;
  final _selectedBgColor = Color.fromRGBO(30, 30, 30, 1);
  final _unselectedBgColor = Color.fromRGBO(30, 30, 30, 1);

  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  static const List<Widget> _widgetOptions = <Widget>[
    Text(
      'Index 0: Watchlist',
      style: optionStyle,
    ),
    Text(
      'Index 1: Other',
      style: optionStyle,
    ),
  ];

  Color _getBgColor(int index) =>
      _selectedIndex == index ? _selectedBgColor : _unselectedBgColor;

  Color _getItemColor(int index) =>
      _selectedIndex == index ? _selectedItemColor : _unselectedItemColor;

  Widget _buildIcon(IconData iconData, String text, int index) => Container(
        width: double.infinity,
        height: kBottomNavigationBarHeight,
        child: Material(
          color: _getBgColor(index),
          child: InkWell(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(iconData),
                Text(text,
                    style:
                        TextStyle(fontSize: 12, color: _getItemColor(index))),
              ],
            ),
          ),
        ),
      );

  @override
  void initState() {
    _auth.userChanges().listen(
          (event) => setState(() => user = event),
        );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(30, 30, 30, 1),
      appBar: myInvestmentAppBar(),
      body: Container(
        child: Builder(
          builder: (BuildContext context) {
            return Builder(
              builder: (BuildContext context) {
                return Center(
                  child: Column(
                    children: [
                      _UserInfoCard(),
                      Container(
                        child: IconButton(
                          iconSize: 80,
                          onPressed: () => _signOut(),
                          icon: Icon(
                            Icons.exit_to_app,
                            color: Colors.white,
                            size: 80,
                          ),
                        ),
                      ),
                      /* TextButton(
                      onPressed: () async {
                        final User user = _auth.currentUser;
                        if (user == null) {
                          ScaffoldSnackbar.of(context)
                              .show('No one has signed in.');
                          return;
                        }
                        await _signOut();

                        final String email = user.email;
                        ScaffoldSnackbar.of(context)
                            .show('$email has successfully signed out.');
                      },
                      child: const Text('Sign out'),
                    ), */
                    ],
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                  ),
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color.fromRGBO(30, 30, 30, 1),
        selectedFontSize: 0,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: _buildIcon(Icons.remove_red_eye, 'Watchlist', 0),
            title: SizedBox.shrink(),
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(Icons.show_chart, 'My Investment', 1),
            title: SizedBox.shrink(),
          ),
        ],
        currentIndex: Provider.of<tabselected>(context, listen: true).selected,
        onTap: (index) => {
          if (index == 1)
            {Navigator.pushNamed(context, 'myinvestment')}
          else
            {Navigator.pushNamed(context, 'watchlist')}
        },
        //Provider.of<tabselected>(context, listen: true).selected = index,
        selectedItemColor: _selectedItemColor,
        unselectedItemColor: _unselectedItemColor,
      ),
    );
  }

  /// Example code for sign out.
  Future<void> _signOut() async {
    await _auth.signOut();
    await googleSignIn.signOut();
    Navigator.pushNamed(context, 'login');
  }
}

class _UserInfoCard extends StatefulWidget {
  const _UserInfoCard({Key key, this.user}) : super(key: key);

  final User user;

  @override
  _UserInfoCardState createState() => _UserInfoCardState();
}

class _UserInfoCardState extends State<_UserInfoCard> {
  @override
  Widget build(BuildContext context) {
    Widget verified = Icon(
      Icons.check_circle_outline_rounded,
      color: Colors.white,
    );
    if (_auth.currentUser != null &&
        _auth.currentUser.emailVerified != null &&
        !_auth.currentUser.emailVerified) {
      verified = Text('Not Verified');
    }

    return Card(
      color: Color.fromRGBO(30, 30, 30, 1),
      elevation: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.only(bottom: 8),
            alignment: Alignment.center,
            child: Text(
              'User info',
              style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  decorationThickness: 4),
            ),
          ),
          if (_auth.currentUser != null)
            if (_auth.currentUser.photoURL != null)
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(bottom: 8),
                child: Image.network(_auth.currentUser.photoURL),
              )
            else
              Align(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(bottom: 8),
                  color: Colors.black,
                  child: const Text(
                    'No image',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          if (_auth.currentUser != null && _auth.currentUser.email != null)
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${_auth.currentUser.email}',
                      style: TextStyle(
                          fontFamily: 'Montserrat',
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          decorationThickness: 2.5),
                    ),
                    verified,
                  ],
                ),
                if (_auth.currentUser.phoneNumber != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${_auth.currentUser.phoneNumber}',
                        style: TextStyle(
                            fontFamily: 'Montserrat',
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            decorationThickness: 2.5),
                      ),
                    ],
                  ),
                Text(
                  '${_auth.currentUser.displayName}',
                  style: TextStyle(
                      fontFamily: 'Montserrat',
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      decorationThickness: 2.5),
                ),
              ],
            ),
          SizedBox(
            height: 16,
          ),
        ],
      ),
    );
  }
}

class UpdateUserDialog extends StatefulWidget {
  const UpdateUserDialog({Key key, this.user}) : super(key: key);

  final User user;

  @override
  _UpdateUserDialogState createState() => _UpdateUserDialogState();
}

class _UpdateUserDialogState extends State<UpdateUserDialog> {
  TextEditingController _nameController;
  TextEditingController _urlController;

  @override
  void initState() {
    _nameController = TextEditingController(text: widget.user.displayName);
    _urlController = TextEditingController(text: widget.user.photoURL);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update profile'),
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            TextFormField(
              controller: _nameController,
              autocorrect: false,
              decoration: const InputDecoration(labelText: 'displayName'),
            ),
            TextFormField(
              controller: _urlController,
              decoration: const InputDecoration(labelText: 'photoURL'),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              autocorrect: false,
              validator: (String value) {
                if (value != null && value.isNotEmpty) {
                  var uri = Uri.parse(value);
                  if (uri.isAbsolute) {
                    //You can get the data with dart:io or http and check it here
                    return null;
                  }
                  return 'Faulty URL!';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.user.updateDisplayName(_nameController.text);
            widget.user.updatePhotoURL(_urlController.text);

            Navigator.of(context).pop();
          },
          child: const Text('Update'),
        )
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    super.dispose();
  }
}
