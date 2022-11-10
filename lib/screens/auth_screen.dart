import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../models/http_exceptions.dart';

enum AuthMode { Signup, Login }

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    // final transformConfig = Matrix4.rotationZ(-8 * pi / 180);
    // transformConfig.translate(-10.0);
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              // color: Theme.of(context).primaryColor,
              gradient: LinearGradient(
                  colors: [
                    Color.fromRGBO(255, 200, 55, 1), //rgba(255, 200, 55, 1)
                    // Color.fromRGBO(255, 128, 8, 1) ,//rgba(255, 128, 8, 1)
                    Theme.of(context).primaryColor
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0, 0.5]),
            ),
            // borderRadius: BorderRadius.circular(30)
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    flex: 0,
                    fit: FlexFit.tight,
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.10,
                      margin:
                          EdgeInsets.symmetric(vertical: 30.0, horizontal: 70),
                      padding:
                          EdgeInsets.symmetric(vertical: 2.0, horizontal: 14.0),
                      decoration: BoxDecoration(
                        border: Border.all(width: 3, color: Colors.white),
                        borderRadius: BorderRadius.circular(50),
                        color: Theme.of(context).primaryColor,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 6,
                            color: Colors.black26,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'Hamro Shop',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Anton',
                            fontSize: 30,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: AuthCard(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  // const AuthCard({
  //  required Key key,
  // }) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;

  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };

  var _isLoading = false;
  final _passwordController = TextEditingController();
  late AnimationController _controller;
  late Animation<Size> _heightAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = AnimationController(
        vsync: this,
        duration: Duration(
          milliseconds: 400,
        ));
    _heightAnimation = Tween<Size>(
            begin: Size(double.infinity, 260), end: Size(double.infinity, 320))
        .animate(
            CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn));
    _opacityAnimation = Tween(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // _heightAnimation.addListener(() => setState(() {}));
  }

  // @override
  // void dispose() {
  //   // TODO: implement dispose
  //   super.dispose();
  //   _controller.dispose();
  // }

  void _showErrorDialog(String message) {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text("An Error Occured !"),
            content: Text(message),
            actions: [
              FlatButton(
                  onPressed: () => Navigator.of(ctx).pop(), child: Text('Okay'))
            ],
          );
        });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_authMode == AuthMode.Login) {
        await Provider.of<Auth>(context, listen: false)
            .login(_authData['email']!, _authData['password']!);
      } else {
        await Provider.of<Auth>(context, listen: false)
            .signup(_authData['email']!, _authData['password']!);
      }
    } on HttpException catch (error) {
      var errorMessage = "Authentication failed";
      if (error.toString().contains("EMAIL_EXISTS")) {
        errorMessage = "Email already in use.";
      } else if (error.toString().contains("INVALID_EMAIL")) {
        errorMessage = "Invalid email address";
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMessage = "Password is too weak.";
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = "The email has not been registered";
      } else if (error.toString().contains("INVALID_PASSWORD")) {
        errorMessage = "The password you entered is wrong";
      }
      _showErrorDialog(errorMessage);
    } catch (error) {
      const errorMessage =
          "Could not authenticate you, please try again later.";
      _showErrorDialog(errorMessage);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
      _controller.forward();
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      // child: AnimatedBuilder(
      //   animation: _heightAnimation,
      //   // The child ch here (which is form,  AnimatedBuilder's child argument), inside the container does not animate/rebuild once the animation starts
      //   // the child ch is passed automatically
      //   builder: (ctx, ch) =>

      // the AnimatedContainer can do the same thing and it automatically animates/transitions when the size/dimension changes abruptly
      child: AnimatedContainer(
        height: _authMode == AuthMode.Signup ? 320 : 260,

        // height: _heightAnimation.value.height,
        curve: Curves.easeIn,
        duration: Duration(milliseconds: 300),
        // constraints: BoxConstraints(minHeight: _heightAnimation.value.height),
        constraints: BoxConstraints(
          minHeight: _authMode == AuthMode.Signup ? 320 : 260,
        ),
        width: deviceSize.width * 0.75,
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(labelText: 'E-Mail'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value!.isEmpty || !value.contains('@')) {
                      return 'Invalid email!';
                    }
                    return null;
                    return null;
                  },
                  onSaved: (value) {
                    _authData['email'] = value as String;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  controller: _passwordController,
                  validator: (value) {
                    if (value!.isEmpty || value.length < 5) {
                      return 'Password is too short!';
                    }
                  },
                  onSaved: (value) {
                    _authData['password'] = value as String;
                  },
                ),
                AnimatedContainer(
                  constraints: BoxConstraints(
                    minHeight: _authMode == AuthMode.Signup ? 60 : 0,
                    maxHeight: _authMode == AuthMode.Signup ? 120 : 0,
                  ),
                  duration: Duration(milliseconds: 400),
                  child: FadeTransition(
                    opacity: _opacityAnimation,
                    child: TextFormField(
                      enabled: _authMode == AuthMode.Signup,
                      decoration:
                          InputDecoration(labelText: 'Confirm Password'),
                      obscureText: true,
                      validator: _authMode == AuthMode.Signup
                          ? (value) {
                              if (value != _passwordController.text) {
                                return 'Passwords do not match!';
                              }
                            }
                          : null,
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                if (_isLoading)
                  CircularProgressIndicator()
                else
                  RaisedButton(
                    child:
                        Text(_authMode == AuthMode.Login ? 'LOGIN' : 'SIGN UP'),
                    onPressed: _submit,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                    color: Theme.of(context).accentColor,
                    textColor: Theme.of(context).primaryTextTheme.button!.color,
                  ),
                FlatButton(
                  child: Text(
                      '${_authMode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'} INSTEAD'),
                  onPressed: _switchAuthMode,
                  padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textColor: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
