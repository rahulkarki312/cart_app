import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expiryData;
  String? _userId;

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    // the url for requesting sign up / sign in is done using firebase's REST API,
    // which provides the endpoint to send the request (email ,
    //password and requestSecureToken) with the API key of a realtime database (here firebase itself)

    final url = Uri.parse(
        "https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyDdjHQc0DAI2cAEdU8NuAVRIjuVYo9inPg");

    final response = await http.post(url,
        body: json.encode(
            {'email': email, 'password': password, 'returnSecureToken': true}));

    print(json.decode(response.body));
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, "signUp");
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, "signInWithPassword");
  }
}
