import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hospital_appointment/Screens/login/patientlogin.dart';
import 'package:hospital_appointment/componets/text_field_container.dart';
import 'package:hospital_appointment/widget/inputdecoration.dart';
import 'package:image_picker/image_picker.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:path/path.dart';
import '../../componets/loadingindicator.dart';
import '../../constants.dart';
import '../../widget/Alert_Dialog.dart';

class Registration extends StatefulWidget {
  const Registration({Key? key}) : super(key: key);

  @override
  _RegistrationState createState() => _RegistrationState();
}

late UserCredential userCredential;

class _RegistrationState extends State<Registration> {
  var t_name,
      t_lname,
      t_address,
      t_city,
      t_email,
      t_age,
      t_phone,
      t_password,
      tc_password;
  var mydate;
  var t_date;
  var _isObscure = true;
  var _isObscure1 = true;
  var _auth = FirebaseAuth.instance;
  var gender;
  var isEmailExist = false;
  var m_status;
  String phoneController = '';
  var c_data = false;
  var c_gender = false;
  var c_status = false;

  DateTime selectedDate = DateTime.now();

  final DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm');

  var users;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  var file;

  setSelectedgender(int val) {
    setState(() {
      gender = val;
    });
  }

  setSelectedstatus(int val) {
    setState(() {
      m_status = val;
    });
  }

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
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String? errorMessage;

    bool isEmailValid(String email) {
      var pattern =
          r'^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
      RegExp regex = new RegExp(pattern);
      return regex.hasMatch(email);
    }

    var size = MediaQuery.of(context).size;
    var container_width = size.width * 0.9;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: SafeArea(
            child: Center(
              child: Container(
                width: size.width * 1,
                child: Container(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Container(
                          child: Center(
                              child: Text(
                                "Client Registration",
                                style: TextStyle(
                                    fontSize: 25,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              )),
                        ),
                      ),

                      SizedBox(
                        height: size.height * 0.03,
                      ),
                      Stack(children: [
                        CircleAvatar(
                          radius: 50.00,
                          backgroundColor: Color(0xFF4CA6A8),
                          child: Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: file == null
                                ? InkWell(
                              onTap: () {
                                chooseImage();
                              },
                              child: CircleAvatar(
                                radius: 50.00,
                                backgroundImage: AssetImage(
                                    "assets/images/account.png"),
                              ),
                            )
                                : CircleAvatar(
                              radius: 50.00,
                              backgroundImage: FileImage(file),
                            ),
                          ),
                        ),
                        Positioned(
                            right: 0,
                            bottom: 5,
                            child: Container(
                                width: 30,
                                height: 30,
                                child: Image.asset(
                                  "assets/images/camera.png",
                                )))
                      ]),

                      SizedBox(
                        height: size.height * 0.02,
                      ),
                      // ************************************
                      // Name Field
                      //*************************************
                      Container(
                        width: container_width,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                blurRadius: 10,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            cursorColor: Color(0xFF4CA6A8),
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.person,
                                color: Color(0xFF4CA6A8),
                              ),
                              filled: true,
                              fillColor: Color(0xFFF5F5F5),
                              contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                              hintText: "First Name",
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                              errorStyle: TextStyle(color: Colors.white),
                              errorMaxLines: 2,
                            ),
                            validator: (var value) {
                              if (value!.isEmpty) {
                                return "Enter Your First Name";
                              }
                              return null;
                            },
                            onSaved: (name) {
                              t_name = name.toString().trim();
                            },
                            onChanged: (var name) {
                              t_name = name.trim();
                            },
                          ),
                        ),
                      ),

                      SizedBox(
                        height: 17.0,
                      ),

                      // ************************************
                      // Address Field
                      //*************************************
                      Container(
                        width: container_width,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                blurRadius: 10,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            cursorColor:Color(0xFF4CA6A8),
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.person,
                                color: Color(0xFF4CA6A8),
                              ),
                              filled: true,
                              fillColor: Color(0xFFF5F5F5),
                              contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                              hintText: "Last Name",
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                              errorStyle: TextStyle(color: Colors.white),
                              errorMaxLines: 2,
                            ),
                            validator: (var value) {
                              if (value!.isEmpty) {
                                return "Enter Your Last Name";
                              }
                              return null;
                            },
                            onSaved: (name) {
                              t_lname = name.toString().trim();
                            },
                            onChanged: (var name) {
                              t_lname = name.trim();
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 17.0,
                      ),
                      Container(
                        width: container_width,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                blurRadius: 10,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            keyboardType: TextInputType.text,
                            cursorColor: Color(0xFF4CA6A8),
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.add_location,
                                color: Color(0xFF4CA6A8),
                              ),
                              filled: true,
                              fillColor: Color(0xFFF5F5F5),
                              contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                              hintText: "Address",
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                              errorStyle: TextStyle(color: Colors.white),
                              errorMaxLines: 2,
                            ),
                            onChanged: (address) {
                              t_address = address;
                            },
                            validator: (value) {
                              final inputValue = value ?? '';
                              if (inputValue.isEmpty) {
                                return "Enter Your Address";
                              }
                              return null;
                            },
                            onSaved: (address) {
                              t_address = address;
                            },
                          ),
                        ),
                      ),

                      SizedBox(
                        height: 17.0,
                      ),
                      Container(
                        width: container_width,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                blurRadius: 10,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            cursorColor: Color(0xFF4CA6A8),
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.add_location,
                                color: Color(0xFF4CA6A8),
                              ),
                              filled: true,
                              fillColor: Color(0xFFF5F5F5),
                              contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                              hintText: "City",
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                              errorStyle: TextStyle(color: Colors.white),
                              errorMaxLines: 2,
                            ),
                            onChanged: (city) {
                              t_city = city;
                            },
                            validator: (var value) {
                              if (value!.isEmpty) {
                                return "Enter Your City";
                              }
                              return null;
                            },
                            onSaved: (var city) {
                              t_city = city;
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 17.0,
                      ),
                      // email Field
                      //*************************************
                      Container(
                        width: container_width,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                blurRadius: 10,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            cursorColor: Color(0xFF4CA6A8),
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.email,
                                color: Color(0xFF4CA6A8),
                              ),
                              filled: true,
                              fillColor: Color(0xFFF5F5F5),
                              contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                              hintText: "Your Email",
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                              errorStyle: TextStyle(color: Colors.white),
                              errorMaxLines: 2,
                            ),
                            onChanged: (email) {
                              t_email = email.trim();
                              print("Email: " + t_email + ":");
                            },
                            validator: (email) {
                              if (isEmailValid(email!))
                                return null;
                              else {
                                return 'Enter a valid email address';
                              }
                            },
                            onSaved: (var email) {
                              t_email = email.toString().trim();
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 17.0,
                      ),
                      // ************************************
                      // Mobile number Field
                      //*************************************
                      Container(
                        width: 380,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30.0),

                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(25.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.0),
                            child: IntlPhoneField(
                              cursorColor: Color(0xFF4CA6A8),
                              style: TextStyle(fontSize: 16),
                              disableLengthCheck: false,
                              textAlignVertical: TextAlignVertical.center,
                              dropdownTextStyle: TextStyle(fontSize: 16),
                              dropdownIcon: Icon(Icons.arrow_drop_down, color: Color(0xFF4CA6A8)),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Contact Number",
                                hintStyle: TextStyle(color: Colors.grey),
                              ),
                              initialCountryCode: 'MA',
                              onChanged: (phone) {
                                print(phone.completeNumber);
                                phoneController = phone.completeNumber.toString();
                              },
                            ),
                          ),
                        ),
                      ),

                      SizedBox(
                        height: 10.0,
                      ),

                      // ************************************
                      // Date of Birth Field
                      //*************************************
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(25.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: TextFieldContainer(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Row(
                                children: <Widget>[
                                  Text(
                                    "Date Of Birth ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF4CA6A8),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Center(
                                        child: t_date == null
                                            ? Padding(
                                          padding: const EdgeInsets.only(left: 20.0),
                                          child: Text(
                                            "Select Date",
                                            style: TextStyle(color: Colors.black54),
                                          ),
                                        )
                                            : Text(
                                          t_date,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () async {
                                          mydate = await showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(1950),
                                            lastDate: DateTime.now(),
                                          );

                                          setState(() {
                                            t_date = DateFormat('dd-MM-yyyy').format(mydate);
                                          });
                                        },
                                        icon: Icon(
                                          Icons.calendar_today,
                                          color: Color(0xFF4CA6A8),
                                          size: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              c_data == true
                                  ? Text(
                                "*Select Date",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w400,
                                ),
                              )
                                  : SizedBox(),
                            ],
                          ),
                        ),
                      ),

                      // ************************************
                      // Age Field
                      //*************************************
                      SizedBox(
                        height: 10.0,
                      ),
                Container(
                  width: container_width,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      cursorColor: Color(0xFF4CA6A8),
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.accessibility,
                          color: Color(0xFF4CA6A8),
                        ),
                        filled: true,
                        fillColor: Color(0xFFF5F5F5),
                        contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                        hintText: "Age",
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        errorStyle: TextStyle(color: Colors.white),
                        errorMaxLines: 2,
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter Your Age";
                        }
                        return null;
                      },
                      onChanged: (age) {
                        t_age = age;
                      },
                      onSaved: (age) {
                        t_age = age;
                      },
                    ),
                  ),
                ),

                // ************************************
                      // Gender Field
                      //*************************************
                      SizedBox(
                        height: 10.0,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(25.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: TextFieldContainer(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Row(
                                children: <Widget>[
                                  ButtonBar(
                                    alignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Gender ",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF4CA6A8),
                                        ),
                                      ),
                                      Radio(
                                        value: 1,
                                        groupValue: gender,
                                        activeColor: Color(0xFF4CA6A8),
                                        onChanged: (val) {
                                          setSelectedgender(val as int);
                                        },
                                      ),
                                      Text("Male"),
                                      Radio(
                                        value: 2,
                                        activeColor: Color(0xFF4CA6A8),
                                        groupValue: gender,
                                        onChanged: (val) {
                                          setSelectedgender(val as int);
                                        },
                                      ),
                                      Text("Female"),
                                    ],
                                  ),
                                ],
                              ),
                              c_gender == true
                                  ? Text(
                                "*Select Gender",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w400,
                                ),
                              )
                                  : SizedBox(),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      // ************************************
                      // Status Field
                      //*************************************
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(25.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: TextFieldContainer(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                children: <Widget>[
                                  Text(
                                    "Marital Status ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF4CA6A8),
                                    ),
                                  ),
                                  ButtonBar(
                                    alignment: MainAxisAlignment.center,
                                    children: [
                                      Radio(
                                        value: 1,
                                        groupValue: m_status,
                                        activeColor: kPrimaryColor,
                                        onChanged: (val) {
                                          setSelectedstatus(val as int);
                                        },
                                      ),
                                      Text("Unmarried"),
                                      Radio(
                                        value: 2,
                                        groupValue: m_status,
                                        activeColor: kPrimaryColor,
                                        onChanged: (val) {
                                          setSelectedstatus(val as int);
                                        },
                                      ),
                                      Text("Married"),
                                    ],
                                  ),
                                ],
                              ),
                              c_status == true
                                  ? Text(
                                "*Select status",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w400,
                                ),
                              )
                                  : SizedBox(),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 12.0),


                      //************************************
                      //Password
                      //************************************
                Container(
                  width: container_width,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      obscureText: _isObscure,
                      cursorColor: Color(0xFF4CA6A8),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide(
                            color: Color(0xFFF5F5F5),
                            width: 2,
                          ),
                        ),
                        prefixIcon: Icon(
                          Icons.lock,
                          color: Color(0xFF4CA6A8),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isObscure ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _isObscure = !_isObscure;
                              print("on password");
                            });
                          },
                        ),
                        fillColor: Color(0xFFF5F5F5),
                        filled: true,
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide(color: Colors.red, width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide(color: Color(0xFFF5F5F5), width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide(
                            color: Color(0xFFF5F5F5),
                            width: 2,
                          ),
                        ),
                        hintText: "Password",
                      ),
                      validator: (value) {
                        RegExp regex = new RegExp(r'^.{6,}$');
                        if (value!.isEmpty) {
                          return "Password is required for login";
                        }
                        if (!regex.hasMatch(value)) {
                          return "Enter Valid Password (Min. 6 Characters)";
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
                      SizedBox(
                        height: 10.0,
                      ),
                Container(
                  width: container_width,
                  margin: EdgeInsets.all(10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: kPrimaryLightColor,
                      borderRadius: BorderRadius.circular(25.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      obscureText: _isObscure1,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide(
                            color: Color(0xFFF5F5F5),
                            width: 2,
                          ),
                        ),
                        prefixIcon: Icon(
                          Icons.lock,
                          color: Color(0xFF4CA6A8),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isObscure1 ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _isObscure1 = !_isObscure1;
                              print("on password");
                            });
                          },
                        ),
                        fillColor:Color(0xFFF5F5F5),
                        filled: true,
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide(color: Colors.red, width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide(color: Color(0xFFF5F5F5), width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide(
                            color: Color(0xFFF5F5F5),
                            width: 2,
                          ),
                        ),
                        hintText: "Confirm Password",
                      ),
                      onChanged: (value) {
                        tc_password = value;
                      },
                      validator: (value) {
                        if (tc_password != t_password) {
                          return "Password don't match";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        tc_password.text = value!;
                      },
                    ),
                  ),
                ),

                SizedBox(
                        height: 15,
                      ),
                      // ************************************
                      // Submit Button
                      //*************************************
                      Positioned(
                        top: size.height * 0.62,
                        left: size.width * 0.1,
                        child: Column(
                          children: [
                            Container(
                              width: 200,
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
                                    if (_formKey.currentState!.validate() &&
                                        t_date != null &&
                                        gender != null &&
                                        m_status != null) {
                                      try {
                                        userCredential = await _auth
                                            .createUserWithEmailAndPassword(
                                          email: t_email!,
                                          password: t_password!,
                                        );
                                        showLoadingDialog(context: context);
                                      } on FirebaseAuthException catch (error) {
                                        print("FirebaseError: " + error.code);
                                        if (error.code == "invalid-email") {
                                          errorMessage =
                                          "Your email address appears to be malformed.";
                                        } else if (error.code ==
                                            "user-disabled") {
                                          errorMessage =
                                          "User with this email has been disabled.";
                                        } else if (error.code ==
                                            "too-many-requests") {
                                          errorMessage = "Too many requests";
                                        } else if (error.code ==
                                            "email-already-in-use") {
                                          errorMessage = "email already in use";
                                        }
                                        Fluttertoast.showToast(
                                            msg: errorMessage.toString());
                                        hideLoadingDialog(context: context);
                                        print("error data" + error.code);
                                        setState(() {});
                                      }

                                      var url;

                                      if (file != null) {
                                        url = await uploadImage();
                                        print("URL ===== " + url.toString());
                                        //map['profileImage'] = url;
                                      }

                                      FirebaseFirestore firebaseFirestore =
                                          FirebaseFirestore.instance;
                                      firebaseFirestore
                                          .collection('parent')
                                          .doc(userCredential.user!.uid)
                                          .set({
                                        'uid': userCredential.user!.uid,
                                        'name': t_name,
                                        'last name': t_lname,
                                        'address': t_address,
                                        'city':t_city,
                                        'email': userCredential.user!.email,
                                        'age': t_age,
                                        'dob': t_date,
                                        'password': t_password,
                                        'gender':
                                        gender == 1 ? "male" : "female",
                                        'status': gender == 1
                                            ? "unmarried"
                                            : "married",
                                        'phone': phoneController,
                                        'profileImage':
                                        url == null ? false : url,
                                      })
                                          .then((value) =>
                                          Fluttertoast.showToast(
                                              msg:
                                              "Registration Successful",
                                              toastLength:
                                              Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.BOTTOM,
                                              timeInSecForIosWeb: 1,
                                              backgroundColor:
                                              Color(0xFF4CA6A8),
                                              textColor: Colors.white,
                                              fontSize: 16.0))
                                          .then((value) => Navigator
                                          .pushAndRemoveUntil<dynamic>(
                                          context,
                                          MaterialPageRoute<dynamic>(
                                              builder: (BuildContext
                                              context) =>
                                                  login_page()),
                                              (route) => false))
                                          .catchError((e) {
                                        print("+++++++++" + e);
                                      });
                                    } else {
                                      if (t_date == null) {
                                        c_data = true;
                                      }
                                      if (gender == null) {
                                        c_gender = true;
                                      }
                                      if (m_status == null) {
                                        c_status = true;
                                      }
                                    }
                                  }

                                  setState(() {});
                                },
                                child: Text(
                                  'Sign In',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),

                            SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<String> uploadImage() async {
    TaskSnapshot taskSnapshot = await FirebaseStorage.instance
        .ref()
        .child("profile")
        .child(
        FirebaseAuth.instance.currentUser!.uid + "_" + basename(file.path))
        .putFile(file);

    return taskSnapshot.ref.getDownloadURL();
  }

  chooseImage() async {
    XFile? xfile = await ImagePicker().pickImage(source: ImageSource.gallery);
    print("file " + xfile!.path);
    file = File(xfile.path);
    setState(() {});
  }
}
