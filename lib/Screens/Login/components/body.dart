import 'package:finto_spoti/Screens/Main/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:finto_spoti/Screens/Login/components/background.dart';
import 'package:finto_spoti/Screens/Signup/signup_screen.dart';
import 'package:finto_spoti/components/already_have_an_account_acheck.dart';
import 'package:finto_spoti/components/rounded_button.dart';
import 'package:finto_spoti/components/rounded_input_field.dart';
import 'package:finto_spoti/components/rounded_password_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

// ignore: must_be_immutable
class Body extends StatefulWidget {
  Body({
    Key key,
  }) : super(key: key);

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  bool isHidden = true,
      wantsToSavePassword = false,
      isEmailValid = true,
      emailValid = true,
      isHidden_1 = false,
      isPassword1Valid = true,
      requestStarted = false;

  String email = "", psw_1 = "";

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "LOGIN",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: size.height * 0.03),
            SvgPicture.asset(
              "assets/icons/login_2.svg",
              height: size.height * 0.35,
            ),
            SizedBox(height: size.height * 0.03),
            RoundedInputField(
              icon: Icons.email_rounded,
              inputType: TextInputType.emailAddress,
              border: isEmailValid
                  ? InputBorder.none
                  : OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red, width: 50.0),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
              color: Color(0xFF6F35A5),
              hintText: "Your Email",
              onChanged: (value) {
                emailValid = RegExp(
                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                    .hasMatch(value);
                email = value;
              },
            ),
            RoundedPasswordField(
              hidden: isHidden_1,
              border: isPassword1Valid
                  ? InputBorder.none
                  : OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red, width: 50.0),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
              onChanged: (value) {
                psw_1 = value;
                if (psw_1.length < 8) {
                  isPassword1Valid = false;
                  return;
                }
              },
              press: () {
                isHidden_1 = !isHidden_1;
                (context as Element).markNeedsBuild();
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Salva Credenziali"),
                Checkbox(
                  fillColor: MaterialStateColor.resolveWith(
                      (states) => Color(0xFF6F35A5)),
                  checkColor: Colors.white,
                  value: wantsToSavePassword,
                  onChanged: (newValue) {
                    wantsToSavePassword = newValue;
                    (context as Element).markNeedsBuild();
                  },
                ),
              ],
            ),
            RoundedButton(
              textColor: Colors.white,
              text: "LOGIN",
              isLoading: requestStarted,
              press: () async {
                requestStarted = true;
                (context as Element).markNeedsBuild();
                var url = Uri.parse(
                    'https://sechisimone.altervista.org/flows/API/registration/signin.php');
                var response = await http
                    .post(url, body: {'email': email, 'password': psw_1});
                print('Response status: ${response.statusCode}');
                print('Response body: ${response.body}');
                if (response.statusCode == 200) {
                  var responseParsed = convert.jsonDecode(response.body);
                  print(responseParsed["response_type"]);
                  if (responseParsed["response_type"] == "already_registered") {
                    //questi sono qua nel caso in futuro aggiungessi degli errori da php (cosa molto molto probabile), per ora non servono a nulla
                    showToast(
                        "Mail/Username già utilizzati in un altro account");
                    requestStarted = false;
                    (context as Element).markNeedsBuild();
                    return;
                  } else if (responseParsed["response_type"] == "email_error") {
                    showToast(
                        "Ci sono problemi con i server, si è pregati di riprovare più tardi");
                    requestStarted = false;
                    (context as Element).markNeedsBuild();
                    return;
                  } else if (responseParsed["response_type"] ==
                      "loggedin_correctly") {
                    if (wantsToSavePassword) {
                      // ignore: invalid_use_of_visible_for_testing_member
                      SharedPreferences.setMockInitialValues({});
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.setString('access_token',
                          responseParsed["response_body"]["access_token"]);
                      prefs.setString('refresh_token',
                          responseParsed["response_body"]["refresh_token"]);
                    }
                    requestStarted = false;
                    (context as Element).markNeedsBuild();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => MainScreen()),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Email di verifica inviata!'),
                      behavior: SnackBarBehavior.floating,
                      /*action: SnackBarAction(
                        label: 'Undo',
                        onPressed: () {},
                      ),*/
                    ));
                  }
                }
              },
            ),
            SizedBox(height: size.height * 0.03),
            AlreadyHaveAnAccountCheck(
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return SignUpScreen();
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void showToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 24.0);
  }
}
