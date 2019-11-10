import 'package:flutter/material.dart';
import 'package:flutter_easy_order/bloc/auth_bloc.dart';
import 'package:flutter_easy_order/pages/splash_screen.dart';
import 'package:flutter_easy_order/widgets/helpers/logger.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LogoutButton extends StatelessWidget {

  final Logger logger = getLogger();

  @override
  Widget build(BuildContext context) {
    _logout(BuildContext context) {
      final AuthBloc authBloc = Provider.of<AuthBloc>(context, listen: false);

      try {
        authBloc.signOut().then((_) {
          // Redirect to splash screen so that user can be logged out from anywhere in the app
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (BuildContext context) => SplashScreen(),
            ), (_) => false);
        });
      } catch (e) {
        logger.e('Error: $e');
        _showErrorDialog(context, 'Logout failed !', 'Please try again later');
      }
    }

    return IconButton(
        icon: Icon(
          FontAwesomeIcons.signOutAlt,
          color: Colors.white,
        ),
        onPressed: () => _logout(context));
  }

  _showErrorDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }
}
