import 'package:flutter/material.dart';
import 'package:flutter_easy_order/bloc/auth_bloc.dart';
import 'package:flutter_easy_order/models/user.dart';
import 'package:flutter_easy_order/pages/login_screen.dart';
import 'package:flutter_easy_order/pages/order_list_screen.dart';
import 'package:flutter_easy_order/widgets/helpers/logger.dart';
import 'package:flutter_easy_order/widgets/ui_elements/adapative_progress_indicator.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = '/';

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  AuthBloc _authBloc;
  Stream<User> _user$;

  final Logger logger = getLogger();

  @override
  void initState() {
    _authBloc = Provider.of<AuthBloc>(context, listen: false);
    _user$ = _authBloc.user$;
    super.initState();
  }

  @override
  void dispose() {
    _authBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    logger.d('build splash screen');
    return StreamBuilder<User>(
        stream: _user$,
        builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildWaitingScreen();
          }

          // User must verify his email address first
          final bool isLoggedIn = snapshot.hasData && snapshot.data.isEmailVerified;
          logger.d('isLoggedIn? $isLoggedIn');
          return isLoggedIn ? OrderListScreen() : LoginScreen();
        });
  }

  Widget _buildWaitingScreen() {
    return Scaffold(
      body: SafeArea(
        top: true,
        bottom: true,
        child: Container(
          decoration: BoxDecoration(
            image: _buildBackgroundImage(),
            color: Colors.indigo[100],
//              border: Border.all(color: Colors.red),
          ),
          padding: EdgeInsets.all(10.0),
          child: _buildLayout(),
        ),
      ),
    );
  }

  Widget _buildLayout() {
    return LayoutBuilder(builder: (context, constraints) {
      final double maxHeight = constraints.maxHeight;
      return Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
            top: maxHeight - 0.95 * maxHeight,
            child: _buildTitle(maxHeight),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: AdaptiveProgressIndicator(),
          ),
        ],
      );
    });
  }

  Widget _buildTitle(double maxHeight) {
    final double deviceHeight = MediaQuery.of(context).size.height;
    final double titleFontSize = 40; // deviceHeight > 550 ? 40 : 30;
    final double titlePadding = deviceHeight > 550 ? 30 : 10;
    return Container(
      margin: EdgeInsets.only(top: titlePadding, bottom: titlePadding),
//      child: IntrinsicWidth(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            'SIMPLE',
            style: TextStyle(
              fontSize: titleFontSize,
              fontFamily: 'LuckiestGuy',
              color: Theme.of(context).accentColor,
            ),
          ),
          Text(
            'ORDER',
            style: TextStyle(
              fontSize: titleFontSize,
              fontFamily: 'LuckiestGuy',
              color: Theme.of(context).accentColor,
            ),
          ),
          Text(
            'MANAGER',
            style: TextStyle(
              fontSize: titleFontSize,
              fontFamily: 'LuckiestGuy',
              color: Theme.of(context).accentColor,
            ),
          ),
        ],
      ),
//      ),
    );
  }

  DecorationImage _buildBackgroundImage() {
    return DecorationImage(
      fit: BoxFit.scaleDown,
      colorFilter: ColorFilter.mode(Colors.indigo[100].withOpacity(0.5), BlendMode.dstATop),
      image: AssetImage('assets/background.png'),
    );
  }
}
