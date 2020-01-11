import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:flutter_easy_order/bloc/auth_bloc.dart';
import 'package:flutter_easy_order/models/auth_mode.dart';
import 'package:flutter_easy_order/models/user.dart';
import 'package:flutter_easy_order/pages/privacy_policy_screen.dart';
import 'package:flutter_easy_order/pages/terms_conditions_screen.dart';
import 'package:flutter_easy_order/widgets/helpers/form_helper.dart';
import 'package:flutter_easy_order/widgets/helpers/logger.dart';
import 'package:flutter_easy_order/widgets/helpers/validator.dart';
import 'package:flutter_easy_order/widgets/ui_elements/adapative_progress_indicator.dart';
import 'package:flutter_easy_order/widgets/ui_elements/footer_layout.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = '/login';

  @override
  State<StatefulWidget> createState() {
    return _LoginScreenState();
  }
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final Logger logger = getLogger();

  final Map<String, dynamic> _formData = {
    'email': null,
    'password': null,
  };
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AuthMode _authMode = AuthMode.Login;
  bool _isLoading = false;

  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _passwordConfirmFocusNode = FocusNode();

  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _passwordConfirmTextController = TextEditingController();
  bool _isEmailClearVisible = false;
  bool _isPasswordClearVisible = false;
  bool _isPasswordConfirmClearVisible = false;

  AnimationController _passwordOpacityAnimationController;
  Animation<double> _passwordOpacityAnimation;
  AnimationController _passwordAnimationController;
  Animation<double> _passwordAnimation;
  AnimationController _passwordConfirmOpacityAnimationController;
  Animation<double> _passwordConfirmOpacityAnimation;
  AnimationController _passwordConfirmAnimationController;

//  Animation<Offset> _passwordConfirmAnimation;
  Animation<double> _passwordConfirmAnimation;

  @override
  void initState() {
    _emailTextController.addListener(_toggleEmailClearVisible);
    _passwordTextController.addListener(_togglePasswordClearVisible);
    _passwordConfirmTextController.addListener(_togglePasswordConfirmClearVisible);

    _passwordConfirmAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _passwordConfirmAnimation =
//        Tween<Offset>(begin: Offset(0.0, -1.5), end: Offset.zero).animate(
        Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _passwordConfirmAnimationController, curve: Curves.easeIn),
    );

    _passwordConfirmOpacityAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _passwordConfirmOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: CurvedAnimation(parent: _passwordConfirmOpacityAnimationController, curve: Curves.fastOutSlowIn),
        curve: Curves.easeIn,
      ),
    );

    _passwordAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _passwordAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _passwordAnimationController, curve: Curves.easeIn),
    );

    _passwordOpacityAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _passwordOpacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _passwordOpacityAnimationController, curve: Curves.fastOutSlowIn),
    );

    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is removed from the Widget tree
    _emailTextController.dispose();
    _passwordTextController.dispose();
    _passwordConfirmTextController.dispose();
    _passwordAnimationController.dispose();
    _passwordConfirmAnimationController.dispose();
    _passwordOpacityAnimationController.dispose();
    _passwordConfirmOpacityAnimationController.dispose();
    super.dispose();
  }

  void _toggleEmailClearVisible() {
    setState(() {
      _isEmailClearVisible = _emailTextController.text.isEmpty ? false : true;
    });
  }

  void _togglePasswordClearVisible() {
    setState(() {
      _isPasswordClearVisible = _passwordTextController.text.isEmpty ? false : true;
    });
  }

  void _togglePasswordConfirmClearVisible() {
    setState(() {
      _isPasswordConfirmClearVisible = _passwordConfirmTextController.text.isEmpty ? false : true;
    });
  }

  Widget _buildEmailTextField() {
    return TextFormField(
      autofocus: false,
      keyboardType: TextInputType.emailAddress,
      textCapitalization: TextCapitalization.none,
      controller: _emailTextController,
      focusNode: _emailFocusNode,
      textInputAction: _authMode != AuthMode.ForgotPassword ? TextInputAction.next : TextInputAction.done,
      onFieldSubmitted: (value) {
        if (_authMode != AuthMode.ForgotPassword) {
          FormHelper.changeFieldFocus(context, _emailFocusNode, _passwordFocusNode);
        } else {
          _submitForm();
        }
      },
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: EdgeInsets.only(left: 5.0),
          child: Icon(
            Icons.email,
          ),
        ),
        suffixIcon: !_isEmailClearVisible
            ? Container(height: 0.0, width: 0.0)
            : IconButton(
                onPressed: () {
                  _emailTextController.clear();
                },
                icon: Icon(
                  Icons.clear,
                )),
        hintText: 'Email',
        contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0)),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (String value) {
        return Validator.validateEmail(value);
      },
      onSaved: (String value) {
        _formData['email'] = value;
      },
    );
  }

  Widget _buildPasswordTextField() {
    return FadeTransition(
      opacity: _passwordOpacityAnimation,
      child: SizeTransition(
//        position: _passwordSlideAnimation,
//        scale: _passwordSlideAnimation,
        sizeFactor: _passwordAnimation,
        child: TextFormField(
          autofocus: false,
          obscureText: true,
          controller: _passwordTextController,
          focusNode: _passwordFocusNode,
          textInputAction: _authMode != AuthMode.Login ? TextInputAction.next : TextInputAction.done,
          onFieldSubmitted: (term) {
            if (_authMode != AuthMode.Login) {
              FormHelper.changeFieldFocus(context, _passwordFocusNode, _passwordConfirmFocusNode);
            } else {
              _submitForm();
            }
          },
          decoration: InputDecoration(
              prefixIcon: Padding(
                padding: EdgeInsets.only(left: 5.0),
                child: Icon(
                  Icons.lock,
                ),
              ),
              suffixIcon: !_isPasswordClearVisible
                  ? Container(height: 0.0, width: 0.0)
                  : IconButton(
                      onPressed: () {
                        _passwordTextController.clear();
                      },
                      icon: Icon(
                        Icons.clear,
                      )),
              hintText: 'Password',
              contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0)),
              filled: true,
              fillColor: Colors.white),
          validator: (String value) {
            if (_authMode != AuthMode.ForgotPassword) {
              return Validator.validatePassword(value);
            }
            return null;
          },
          onSaved: (String value) {
            _formData['password'] = value;
          },
        ),
      ),
    );
  }

  Widget _buildPasswordConfirmTextField() {
    return FadeTransition(
      opacity: _passwordConfirmOpacityAnimation,
      child: SizeTransition(
        // SlideTransition(
//        position: _passwordConfirmAnimation,
        sizeFactor: _passwordConfirmAnimation,
        child: TextFormField(
          autofocus: false,
          obscureText: true,
          focusNode: _passwordConfirmFocusNode,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (term) => _submitForm(),
          controller: _passwordConfirmTextController,
          style: TextStyle(fontSize: 16.0),
          decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
              prefixIcon: Padding(
                padding: EdgeInsets.only(left: 5.0),
                child: Icon(
                  Icons.lock,
                ),
              ),
              suffixIcon: !_isPasswordConfirmClearVisible
                  ? Container(height: 0.0, width: 0.0)
                  : IconButton(
                      onPressed: () {
                        _passwordConfirmTextController.clear();
                      },
                      icon: Icon(
                        Icons.clear,
                      )),
              hintText: 'Confirm password',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0)),
              filled: true,
              fillColor: Colors.white),
          validator: (String value) {
            // TODO export to class
            if (_passwordTextController.text != value && _authMode == AuthMode.SignUp) {
              return 'Passwords do not match';
            }
            return null;
          },
        ),
      ),
    );
  }

  void _submitForm() async {
    setState(() => _isLoading = true);

    final AuthBloc authBloc = Provider.of<AuthBloc>(context, listen: false);

    if (!_formKey.currentState.validate()) {
      // || !_formData['acceptTerms']
      setState(() => _isLoading = false);
      return;
    }

    _formKey.currentState.save();

    try {
      switch (_authMode) {
        case AuthMode.Login:
          User user =
              await authBloc.signInWithEmailAndPassword(email: _formData['email'], password: _formData['password']);

          // Check if email is verified
          if (user == null || !user.isEmailVerified) {
            setState(() => _isLoading = false);
            _showAlertDialog('Authentication failed !', 'Please verify your email address');
          }
          break;

        case AuthMode.SignUp:
          await authBloc.createUserWithEmailAndPassword(email: _formData['email'], password: _formData['password']);

          setState(() {
            _isLoading = false;
            _authMode = AuthMode.Login;
          });

//          if (mounted) {
          _passwordConfirmOpacityAnimationController.reverse();
          _passwordConfirmAnimationController.reverse();
//          }

          _showAlertDialog('Registration successful !', 'A verification email has been sent to your email address');
          break;

        case AuthMode.ForgotPassword:
          await authBloc.sendPasswordResetEmail(email: _formData['email']);

          setState(() {
            _isLoading = false;
            _authMode = AuthMode.Login;
          });

//          if (mounted) {
          _passwordOpacityAnimationController.reverse();
          _passwordAnimationController.reverse();
          _passwordConfirmOpacityAnimationController.reverse();
          _passwordConfirmAnimationController.reverse();
//          }

          _showAlertDialog('Reset password successful !', 'A reset password email has been sent to your email address');
          break;

        default:
          logger.e('Illegal Auth Mode');
          break;
      }

      // Navigator.pushReplacementNamed(context, '/');

    } catch (e) {
      logger.e('Error: $e');
      setState(() => _isLoading = false);

      final String title = _authMode == AuthMode.Login
          ? 'Authentication failed !'
          : (_authMode == AuthMode.SignUp ? 'Registration failed !' : 'Reset password failed !');
      final String content = _authMode == AuthMode.Login
          ? 'Please check your username and password'
          : (_authMode == AuthMode.SignUp
              ? 'Please try again and verify that your email is not already used'
              : 'Please try again later');
      _showAlertDialog(title, content);
    }
//    finally {
//      if (mounted) {
//        _passwordConfirmOpacityAnimationController.reverse();
//        _passwordConfirmAnimationController.reverse();
//      }
//    }
  }

  void _signInWithGoogle() async {
    setState(() => _isLoading = true);

    final AuthBloc authBloc = Provider.of<AuthBloc>(context, listen: false);

    try {
      await authBloc.signInWithGoogle();
    } catch (e) {
      logger.e('Error: $e');
      setState(() => _isLoading = false);

      final String title = 'Authentication failed !';
      final String content = 'Please try again later';
      _showAlertDialog(title, content);
    }
  }

  void _signInWithFacebook() async {
    setState(() => _isLoading = true);

    final AuthBloc authBloc = Provider.of<AuthBloc>(context, listen: false);

    try {
      await authBloc.signInWithFacebook();
    } catch (e) {
      logger.e('Error: $e');
      setState(() => _isLoading = false);

      final String title = 'Authentication failed !';
      final String content = 'Please try again later';
      _showAlertDialog(title, content);
    }
  }

  _showAlertDialog(String title, String content) {
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

  @override
  Widget build(BuildContext context) {
//    logger.d('Device size: ${MediaQuery.of(context).size}');
    final Size deviceSize = MediaQuery.of(context).size;
//    final double deviceHeight = deviceSize.height;
    final double deviceWidth = deviceSize.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.95;
    return Scaffold(
      // TODO remove resizeToAvoidBottomInset
      resizeToAvoidBottomInset: false,
//      appBar: PreferredSize(
//        preferredSize: Size.fromHeight(40.0), // default 56.0
//        child: AppBar(
//          title: Text(
//              _authMode == AuthMode.Login ? 'Login' : (_authMode == AuthMode.SignUp ? 'Register' : 'Reset Password')),
//        ),
//      ),
      body: SafeArea(
        top: true,
        bottom: true,
        child: Container(
          decoration: BoxDecoration(
            image: _buildBackgroundImage(),
            color: Colors.indigo[100],
//            border: Border.all(color: Colors.red),
          ),
          padding: EdgeInsets.all(10.0),
          child: _buildPageContent(targetWidth),
        ),
      ),
    );
  }

  Widget _buildSwitchButton() {
//    final double bottomButtonPadding = MediaQuery.of(context).size.height > 550 ? 20 : 8;
    final double bottomButtonFontSize = MediaQuery.of(context).size.height > 550 ? 16 : 12;
    return _authMode == AuthMode.ForgotPassword
        ? Container()
        : Material(
            color: Colors.transparent,
            child: InkWell(
              splashColor: Theme.of(context).accentColor,
              child: Container(
                padding: EdgeInsets.all(8.0),
//                decoration: BoxDecoration(color: Colors.red),
                child: Text(
                  _authMode == AuthMode.Login
                      ? 'Don' 't have an account ? Create one !'
                      : 'Already have an account ? Sign in !',
                  style: TextStyle(
                    color: Theme.of(context).accentColor,
                    fontWeight: FontWeight.bold,
                    fontSize: bottomButtonFontSize,
                  ),
                ),
              ),
              onTap: () {
                if (_authMode == AuthMode.Login) {
                  setState(() {
                    _authMode = AuthMode.SignUp;
                  });
                  _passwordConfirmOpacityAnimationController.forward();
                  _passwordConfirmAnimationController.forward();
                } else {
                  setState(() {
                    _authMode = AuthMode.Login;
                  });
                  _passwordConfirmOpacityAnimationController.reverse();
                  _passwordConfirmAnimationController.reverse();
                }
              },
            ),
          );
  }

  Widget _buildForgotPasswordButton() {
//    final double bottomButtonPadding = MediaQuery.of(context).size.height > 550 ? 20 : 8;
    final double bottomButtonFontSize = MediaQuery.of(context).size.height > 550 ? 16 : 12;
    return _authMode == AuthMode.SignUp
        ? Container()
        : Material(
            color: Colors.transparent,
            child: InkWell(
              splashColor: Theme.of(context).accentColor,
              child: Container(
                padding: EdgeInsets.all(8.0),
//                decoration: BoxDecoration(color: Colors.red),
                child: Text(
                  _authMode == AuthMode.Login ? 'Forgot password ?' : 'Sign in !',
                  style: TextStyle(
                    color: Theme.of(context).accentColor,
                    fontWeight: FontWeight.bold,
                    fontSize: bottomButtonFontSize,
                  ),
                ),
              ),
              onTap: () {
                if (_authMode == AuthMode.Login) {
                  setState(() => _authMode = AuthMode.ForgotPassword);
                  _passwordAnimationController.forward();
                  _passwordOpacityAnimationController.forward();
                } else {
                  setState(() => _authMode = AuthMode.Login);
                  _passwordAnimationController.reverse();
                  _passwordOpacityAnimationController.reverse();
                }
              },
            ),
          );
  }

  Widget _buildPrivacyPolicyButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        splashColor: Theme.of(context).accentColor,
        child: Container(
          padding: EdgeInsets.all(8.0),
//                decoration: BoxDecoration(color: Colors.red),
          child: Text(
            'Privacy Policy',
            style: TextStyle(
              color: Theme.of(context).accentColor,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              settings: RouteSettings(name: PrivacyPolicyScreen.routeName),
              builder: (context) => PrivacyPolicyScreen()));
        },
      ),
    );
  }

  Widget _buildTermsAndConditionsButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        splashColor: Theme.of(context).accentColor,
        child: Container(
          padding: EdgeInsets.all(8.0),
//                decoration: BoxDecoration(color: Colors.red),
          child: Text(
            'Terms & Conditions',
            style: TextStyle(
              color: Theme.of(context).accentColor,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              settings: RouteSettings(name: TermsConditionsScreen.routeName),
              builder: (context) => TermsConditionsScreen()));
        },
      ),
    );
  }

  Widget _buildSubmitButton() {
    final double submitButtonPadding = 0; // MediaQuery.of(context).size.height > 550 ? 0 : 0;
    final Widget loginButton = SizedBox(
      width: 200,
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        color: Theme.of(context).accentColor,
        textColor: Colors.white,
        onPressed: () => _submitForm(),
        child: Text(
            _authMode == AuthMode.Login ? 'LOGIN' : (_authMode == AuthMode.SignUp ? 'REGISTER' : 'RESET PASSWORD')),
      ),
    );
    final Widget googleSignInButton = _authMode == AuthMode.Login
        ? GoogleSignInButton(
            onPressed: _signInWithGoogle,
            darkMode: false,
            borderRadius: 24.0,
          )
        : Container(
            height: 0.0,
            width: 0.0,
          );
    final Widget facebookSignInButton = _authMode == AuthMode.Login
        ? FacebookSignInButton(
            onPressed: _signInWithFacebook,
            borderRadius: 24.0,
          )
        : Container(
            height: 0.0,
            width: 0.0,
          );

    return Padding(
      padding: EdgeInsets.only(top: submitButtonPadding),
      child: _isLoading
          ? AdaptiveProgressIndicator()
          : Column(
              children: <Widget>[
                loginButton,
                googleSignInButton,
                facebookSignInButton,
              ],
            ),
    );
  }

  Widget _buildPageContent(double targetWidth) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: FooterLayout(
        body: _buildBody(targetWidth),
        footer: _buildFooter(),
      ),
    );
  }

  _buildFooter() {
    return Container(
      child: IntrinsicHeight(
        child: Align(
          alignment: Alignment.center,
          child: Column(
            children: <Widget>[
              _buildSwitchButton(),
              _buildForgotPasswordButton(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly, // center
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  _buildPrivacyPolicyButton(),
                  _buildTermsAndConditionsButton(),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(double targetWidth) {
    return Container(
      child: SingleChildScrollView(
        child: LayoutBuilder(builder: (context, constraints) {
          final double maxHeight = constraints.maxHeight;
          return Column(
            children: <Widget>[
              _buildTitle(),
              _buildForm(maxHeight, targetWidth),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildForm(double maxHeight, double targetWidth) {
    return Container(
      width: targetWidth,
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            _buildEmailTextField(),
            SizedBox(
              height: 10.0,
            ),
            _buildPasswordTextField(),
            if (_authMode == AuthMode.Login || _authMode == AuthMode.SignUp)
              SizedBox(
                height: 10.0,
              ),
            _buildPasswordConfirmTextField(),
            if (_authMode == AuthMode.SignUp)
              SizedBox(
                height: 10.0,
              ),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
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
//        ),
      ),
    );
  }

  DecorationImage _buildBackgroundImage() {
    return DecorationImage(
      fit: BoxFit.scaleDown,
      colorFilter: ColorFilter.mode(Colors.indigo[100].withOpacity(0.1), BlendMode.dstATop),
      image: AssetImage('assets/background.png'),
    );
  }
}
