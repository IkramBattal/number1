import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hospital_appointment/Screens/home/patient_home_page.dart';
import 'package:hospital_appointment/Screens/login/Patient_registration.dart';
import 'package:hospital_appointment/widget/inputdecoration.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import '../../componets/loadingindicator.dart';
import '../../constants.dart';
import '../../services/shared_preferences_service.dart';
import '../../widget/Alert_Dialog.dart';
import 'ForgetPassword.dart';
import 'loginas.dart';

class login_page extends StatefulWidget {
  const login_page({Key? key}) : super(key: key);

  @override
  _login_pageState createState() => _login_pageState();
}

class _login_pageState extends State<login_page> {
  var _isObscure = true;
  var t_email, t_password;
  var user = FirebaseFirestore.instance.collection("parent").snapshots();
  final PrefService _prefService = PrefService();
  var auth = FirebaseAuth.instance;

  var errorMessage;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  bool isLoading = false;

  var result;
  var subscription;
  bool status = false;

  getConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
// I am connected to a mobile network.
      status = true;
      print("Mobile Data Connected !");
    } else if (connectivityResult == ConnectivityResult.wifi) {
      print("Wifi Connected !");
      status = true;
// I am connected to a wifi network.
    } else {
      print("No Internet !");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getConnectivity();
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        setState(() {
          status = false;
        });
      } else {
        setState(() {
          status = true;
        });
      }
    });
  }

  Future<bool> getInternetUsingInternetConnectivity() async {
    result = await InternetConnectionChecker().hasConnection;
    if (result == true) {
      print('YAY! Free cute dog pics!');
    } else {
      print('No internet :( Reason:');
    }
    return result;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    t_password.dispose();
    t_email.dispose();
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isEmailValid(String email) {
      var pattern =
          r'^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
      RegExp regex = new RegExp(pattern);
      return regex.hasMatch(email);
    }

    var size = MediaQuery.of(context).size;

    return Scaffold(
        backgroundColor: Color(0xFFF5F5F5),
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios,
              size: 25,
              color: Color(0xFF4CA6A8),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Loginas()),
              );
            },
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),

        body: GestureDetector(
          onHorizontalDragEnd: (DragEndDetails details) {
            if (details.velocity.pixelsPerSecond.dx < 0) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Loginas()),
              );
            }
          },
          child: SafeArea(
            child: Form(
              key: _formkey,
              child: isLoading
                  ? Loading()
                  : SingleChildScrollView(
                child: Container(
                  height: size.height * 1,

                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 50,
                        ),
                        Container(
                          child: Center(
                              child: Text(
                                "Parent Login",
                                style: TextStyle(
                                    fontSize: 26,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              )),
                        ),
                        SizedBox(
                          height: 60,
                        ),

                        SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          height: size.height * 0.02,
                        ),
                        // ************
                        // Email Field
                        //*************
                        Container(
                          width: size.width * 0.9,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50), // Set circular border radius
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                blurRadius: 10,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),

                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50), // Set circular border radius
                            child: TextFormField(
                              keyboardType: TextInputType.emailAddress,
                              cursorColor: Color(0xFF4CA6A8),
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.email,
                                  color: Color(0xFF4CA6A8),
                                ),
                                fillColor: Color(0xFFFFFFFF),
                                filled: true,
                                errorBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0), // Adjust padding
                                hintText: "Your Email",
                              ),
                              onChanged: (email) {
                                t_email = email.trim();
                              },
                              validator: (email) {
                                if (isEmailValid(email!))
                                  return null;
                                else
                                  return 'Enter a valid email address';
                              },
                              onSaved: (var email) {
                                t_email = email.toString().trim();
                              },
                            ),
                          ),
                        ),



                        // ************
                        // Password Field
                        //*************
                        SizedBox(height: 30),
                        Container(
                          width: size.width * 0.9,
                          margin: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50), // Set circular border radius
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                blurRadius: 10,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50), // Set circular border radius
                            child: TextFormField(
                              obscureText: _isObscure,
                              cursorColor: Color(0xFF4CA6A8),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                prefixIcon: Icon(
                                  Icons.lock,
                                  color: Color(0xFF4CA6A8),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isObscure ? Icons.visibility_off : Icons.visibility,
                                    color: Color(0xFF4CA6A8),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isObscure = !_isObscure;
                                      print("on password");
                                    });
                                  },
                                ),
                                fillColor: Color(0xFFFFFFFF),
                                filled: true,
                                errorBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0), // Adjust padding
                                hintText: "Password",
                              ),
                              validator: (var value) {
                                if (value!.isEmpty) {
                                  return "Enter Your Password";
                                }
                                return null;
                              },
                              onChanged: (password) {
                                t_password = password;
                              },
                              onSaved: (var password) {
                                t_password = password;
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 40),
                        Column(
                          children: [
                            Container(
                              width: 210,
                              margin: EdgeInsets.only(
                                  left: 10, right: 10, top: 10, bottom: 5),
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    shape: StadiumBorder(),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 40, vertical: 15),
                                    backgroundColor: Color(0xFF4CA6A8)),
                                onPressed: () async {
                                  if (status == false) {
                                    showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (BuildContext context) =>
                                            AdvanceCustomAlert());
                                  } else {
                                    if (_formkey.currentState!.validate()) {
                                      if (isLoading) return;
                                      setState(() {
                                        isLoading = true;
                                      });
                                      CollectionReference doctorsCollection = FirebaseFirestore
                                          .instance.collection('parent');
                                      QuerySnapshot querySnapshot = await doctorsCollection
                                          .where('email', isEqualTo: t_email).get();
                                      if (querySnapshot.docs.isEmpty) {
                                        errorMessage =
                                        "User not found";
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    login_page()));
                                        Fluttertoast.showToast(
                                            msg: errorMessage);
                                        setState(() {});
                                      }
                                      else{
                                        try {
                                          userCredential = await auth
                                              .signInWithEmailAndPassword(
                                              email: t_email,
                                              password: t_password);
                                          showLoadingDialog(context: context);
                                        } on FirebaseAuthException catch (error) {
                                          print("FirebaseError: " + error.code);
                                          switch (error.code) {
                                            case "invalid-email":
                                              errorMessage =
                                              "Your email address appears to be malformed.";
                                              break;
                                            case "wrong-password":
                                              errorMessage =
                                              "Your password is wrong.";
                                              break;
                                            case "user-not-found":
                                              errorMessage =
                                              "Parent with this email doesn't exist.";
                                              break;
                                            case "user-disabled":
                                              errorMessage =
                                              "User with this email has been disabled.";
                                              break;
                                            case "too-many-requests":
                                              errorMessage =
                                              "Too many requests";
                                              break;
                                            case "operation-not-allowed":
                                              errorMessage =
                                              "Signing in with Email and Password is not enabled.";
                                              break;
                                            case "email-already-in-use":
                                              {
                                                errorMessage =
                                                "email already in use";
                                                break;
                                              }
                                            default:
                                              errorMessage =
                                              "An undefined Error happened.";
                                              break;
                                          }
                                          Fluttertoast.showToast(
                                              msg: errorMessage);
                                          if (errorMessage ==
                                              "Parent with this email doesn't exist.") {
                                            Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        Registration()));
                                          } else {
                                            Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        login_page()));
                                            // hideLoadingDialog(context: context);
                                          }

                                          print("error data" + error.code);
                                          setState(() {});

                                        }


                                        if (userCredential != null) {
                                          await auth
                                              .signInWithEmailAndPassword(
                                              email: t_email,
                                              password: t_password)
                                              .then((value) =>
                                              _prefService.createCache(2))
                                              .then((uid) => {
                                            print("Login Successful"),
                                            Fluttertoast.showToast(
                                                msg: "Login Successful",
                                                toastLength:
                                                Toast.LENGTH_SHORT,
                                                gravity:
                                                ToastGravity.BOTTOM,
                                                timeInSecForIosWeb: 1,
                                                backgroundColor:
                                                Color(0xFF4CA6A8),
                                                textColor: Colors.white,
                                                fontSize: 16.0),
                                            Navigator.pushAndRemoveUntil<
                                                dynamic>(
                                                context,
                                                MaterialPageRoute<
                                                    dynamic>(
                                                    builder: (BuildContext
                                                    context) =>
                                                        HomePage()),
                                                    (route) => false),
                                          })
                                              .catchError((e) {
                                            print(e);
                                          });
                                        }
                                      }
                                    }}
                                },
                                child: Text(
                                  'Login',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),

                            TextButton(
                              onPressed: () {
                                if (status == false) {
                                  showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (BuildContext context) =>
                                          AdvanceCustomAlert());
                                } else {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ForgetPassword()));
                                }
                              },

                              child: Text(
                                "Forget Password ?",
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),

                            SizedBox(
                              height: 5,
                            ),
                            Container(
                              height: 2,
                              width: 150,
                              color: Color(0xFF4CA6A8),
                            ),
                            
                            SizedBox(
                              height: 20,
                            ),
                            // ************
                            // add new account
                            //*************
                            Container(
                              child: Center(
                                child: Row(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Center(
                                      child: Text(
                                        "New User?",
                                        style: TextStyle(
                                            color: Colors.black26,
                                            fontSize: 15),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        if (status == false) {
                                          showDialog(
                                              context: context,
                                              barrierDismissible: false,
                                              builder:
                                                  (BuildContext context) =>
                                                  AdvanceCustomAlert());
                                        } else {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      Registration()));
                                        }
                                      },
                                      child: Text(
                                        " Create New Account",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ));
  }

  void sigin(var email, var password) async {
    if (_formkey.currentState!.validate()) {
      await auth
          .signInWithEmailAndPassword(email: email, password: password)
          .then((uid) => {
        print("Login Successful"),
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        ),
      })
          .catchError((e) {
        print(e);
      });
    }
  }
}