import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hospital_appointment/constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:path/path.dart';
import '../../componets/loadingindicator.dart';
import '../../componets/text_field_container.dart';
import '../../models/doctor.dart';
import '../../widget/Alert_Dialog.dart';
import '../home/doctor_home_page.dart';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';


class DProfile_page extends StatefulWidget {
  const DProfile_page({Key? key}) : super(key: key);

  @override
  _Profile_pageState createState() => _Profile_pageState();
}

DoctorModel loggedInUser = DoctorModel();

class _Profile_pageState extends State<DProfile_page> {
  User? user = FirebaseAuth.instance.currentUser;

  bool isLoading = true;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var t_address;
  var t_city;
  var mydate;
  var t_date;
  var t_age;
  var name;
  var last_name;
  var file;
  var phoneController;
  var gender;
  var status;
  var email;
  var selectedStatus;
  var selectedGender ;
  setSelectedgender(int val) {
    setState(() {
      gender = val;
    });
  }
  setSelectedstatus(int val1) {
    setState(() {
      status = val1;
    });
  }
  chooseImage2() async {
    XFile? xfile2 = await ImagePicker().pickImage(source: ImageSource.gallery);
    print("file " + xfile2!.path);
    file= File(xfile2.path);
    Fluttertoast.showToast(msg: "Chosen File:" + file.path);
    setState(() {});
  }
  var subscription;

// Declare a variable to store the selected file

// Declare a variable to store the selected file
  File? file1;

// Declare a variable to store the download URL
  String? url1;

// Function to choose the file
  void chooseFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      file1 = File(result.files.single.path!);
      print('File selected: ${file1!.path}');

      // Automatically upload the file and get the URL
      await uploadFileAndGetURL();
    } else {
      // User canceled the file selection
      print('No file selected');
    }
  }

// Function to upload the file to Firebase Storage and get the download URL
  Future<void> uploadFileAndGetURL() async {
    if (file1 != null) {
      try {
        // Upload the file to Firebase Storage
        String fileName = 'proof.pdf'; // Assign a filename for the file
        firebase_storage.Reference ref =
        firebase_storage.FirebaseStorage.instance.ref().child('files/$fileName');
        await ref.putFile(file1!);

        // Get the download URL
        url1 = await ref.getDownloadURL();

        print('File uploaded. URL: $url1');
      } catch (e) {
        print('Error uploading the file: $e');
      }
    } else {
      print('No file selected');
    }
  }
  var result;

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
  void initState() {
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
    loggedInUser = DoctorModel();
    FirebaseFirestore.instance
        .collection("Sitter")
        .doc(user!.uid)
        .get()
        .then((value) {
      loggedInUser = DoctorModel.fromMap(value.data());
      setState(() {
        isLoading = false;
      });
      print("++++++++++++++++++++++++++++++++++++++++++" + user!.uid);
    });
  }

  String dropdownValue = 'male';

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var margin_left = size.width * 0.07;
    var margin_top = size.width * 0.03;
    var margin_right = size.width * 0.07;
    var boder = size.width * 0.6;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              size: 30,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          centerTitle: true,
          title: Text(
              'Profile',

              style: TextStyle(
                fontSize: 22, // Adjust the font size as needed
              ),
            ),

            backgroundColor: Color(0xFF4CA6A8),
        ),
        body: isLoading
            ? Loading()
            : SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: size.height * 0.01),
                  child: Center(
                    child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border:
                          Border.all(width: 3, color: Colors.black12),
                        ),
                        child: Stack(
                          children: [
                            loggedInUser.profileImage == false
                                ? CircleAvatar(
                              backgroundImage: AssetImage(
                                  'assets/images/account.png'),
                              radius: 50,
                            )
                                : Container(
                              child: InkWell(
                                onTap: () {
                                  chooseImage();
                                },
                                child: file == null
                                    ? CircleAvatar(
                                  backgroundImage:
                                  NetworkImage(
                                      loggedInUser
                                          .profileImage),
                                  backgroundColor:
                                  Colors.grey,
                                  radius: 50,
                                )
                                    : CircleAvatar(
                                  radius: 50.00,
                                  backgroundImage:
                                  FileImage(file),
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
                          ],
                        )),
                  ),
                ),
                // ************************************
                // Name Field
                //*************************************
                Container(
                  margin: EdgeInsets.only(
                      left: size.width * 0.06, top: margin_top),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "First Name",
                        style: TextStyle(
                            color: Color(0xFF3A8183),
                            fontWeight: FontWeight.w600),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                            left: margin_left, right: margin_right),
                        width: boder,
                        decoration: BoxDecoration(
                          border: Border.all(
                              width: 1.0, color: Colors.black12),
                          borderRadius: BorderRadius.all(
                              Radius.circular(15.0)
                            //                 <--- border radius here
                          ),
                        ),
                        padding: EdgeInsets.all(8),
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          cursorColor: Color(0xFF3A8183),
                          initialValue: loggedInUser.name,
                          onChanged: (name) {
                            name = name;
                          },
                          validator: (var value) {
                            if (value!.isEmpty) {
                              return "Enter Your First Name";
                            }
                            return null;
                          },
                          onSaved: (var name) {
                            name = name;
                          },
                          decoration: InputDecoration(
                            border: InputBorder.none, // Set the border to none
                          ),
                        ),
                      )
                    ],
                  ),
                ),

                // ************************************
                // Email Field
                //*************************************

                Container(
                  margin:
                  EdgeInsets.only(left: margin_left, top: margin_top),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "Email",
                        style: TextStyle(
                            color: Color(0xFF3A8183),
                            fontWeight: FontWeight.w600),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                            left: margin_left, right: margin_right),
                        width: boder,
                        decoration: BoxDecoration(
                          border: Border.all(
                              width: 1.0, color: Colors.black12),
                          borderRadius: BorderRadius.all(
                              Radius.circular(15.0)
                            //                 <--- border radius here
                          ),
                        ),
                        padding: EdgeInsets.all(8),
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          cursorColor: Color(0xFF3A8183),
                          initialValue: loggedInUser.email,
                          onChanged: (email) {
                            email = email;

                          },
                          validator: (var value) {
                            if (value!.isEmpty) {
                              return "Enter Your email";
                            }
                            return null;
                          },
                          onSaved: (var email) {
                            email = email;
                          },
                          decoration: InputDecoration(
                            border: InputBorder.none, // Set the border to none
                          ),
                        ),
                      )
                    ],
                  ),
                ),

                //*************************************
                //address
                //*************************************

                Container(
                  margin:
                  EdgeInsets.only(left: margin_left, top: margin_top),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "address",
                        style: TextStyle(
                            color: Color(0xFF3A8183),
                            fontWeight: FontWeight.w600),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                            left: margin_left, right: margin_right),
                        width: boder,
                        decoration: BoxDecoration(
                          border: Border.all(
                              width: 1.0, color: Colors.black12),
                          borderRadius: BorderRadius.all(
                              Radius.circular(15.0)
                            //                 <--- border radius here
                          ),
                        ),
                        padding: EdgeInsets.all(8),
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          cursorColor: Color(0xFF3A8183),
                          initialValue: loggedInUser.address,
                          onChanged: (address) {
                            t_address = address;
                          },
                          validator: (var value) {
                            if (value!.isEmpty) {
                              return "Enter Your Address";
                            }
                            return null;
                          },
                          onSaved: (var address) {
                            t_address =address;
                          },
                          decoration: InputDecoration(
                            border: InputBorder.none, // Set the border to none
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  margin:
                  EdgeInsets.only(left: margin_left, top: margin_top),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "city",
                        style: TextStyle(
                            color: Color(0xFF3A8183),
                            fontWeight: FontWeight.w600),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                            left: margin_left, right: margin_right),
                        width: boder,
                        decoration: BoxDecoration(
                          border: Border.all(
                              width: 1.0, color: Colors.black12),
                          borderRadius: BorderRadius.all(
                              Radius.circular(15.0)
                            //                 <--- border radius here
                          ),
                        ),
                        padding: EdgeInsets.all(8),
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          cursorColor: Color(0xFF3A8183),
                          initialValue: loggedInUser.city,
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
                          decoration: InputDecoration(
                            border: InputBorder.none, // Set the border to none
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                // ************************************
                // Date of Birth Field
                //*************************************
                Container(
                  margin: EdgeInsets.only(left: margin_left, top: margin_top),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "Date Of Birth",
                        style: TextStyle(
                          color: Color(0xFF3A8183),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(right: margin_right),
                        width: boder,
                        decoration: BoxDecoration(
                          border: Border.all(
                              width: 1.0, color: Colors.black12),
                          borderRadius: BorderRadius.all(Radius.circular(15.0)),
                        ),
                        padding: EdgeInsets.all(8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Center(
                              child: t_date == null
                                  ? Text(
                                loggedInUser.dob.toString(),
                                style: TextStyle(color: Colors.black),
                              )
                                  : Text(
                                t_date,
                                style: TextStyle(
                                    color: Colors.black,
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
                                color: Color(0xFF4A7879),
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ************************************
                // Age Field
                //*************************************
                Container(
                  margin:
                  EdgeInsets.only(left: margin_left, top: margin_top),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "Age",
                        style: TextStyle(
                            color: Color(0xFF3A8183),
                            fontWeight: FontWeight.w600),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                            left: margin_left, right: margin_right),
                        width: boder,
                        decoration: BoxDecoration(
                          border: Border.all(
                              width: 1.0, color: Colors.black12),
                          borderRadius: BorderRadius.all(Radius.circular(15.0)),
                        ),
                        padding: EdgeInsets.all(8),
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          cursorColor: Color(0xFF3A8183),
                          initialValue: loggedInUser.age,
                          onChanged: (age) {
                            t_age = age;
                          },
                          validator: (var value) {
                            if (value!.isEmpty) {
                              return "Enter Your Age";
                            }
                            return null;
                          },
                          onSaved: (var age) {
                            t_age = age;
                          },
                          decoration: InputDecoration(
                            border: InputBorder.none, // Set the border to none
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                // ************************************
                // Gender Field
                //*************************************

                Container(
                  margin:
                  EdgeInsets.only(left: margin_left, top: margin_top),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "Gender",
                        style: TextStyle(
                            color: Color(0xFF3A8183),
                            fontWeight: FontWeight.w600),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: margin_left, right: margin_right),
                        width: boder,
                        decoration: BoxDecoration(
                          border: Border.all(width: 1.0, color: Colors.black12),
                          borderRadius: BorderRadius.all(Radius.circular(15.0)),
                        ),
                        padding: EdgeInsets.all(8),
                        child: Row(
                          children: <Widget>[
                            ButtonBar(
                              alignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Radio(
                                      value: "male",
                                      groupValue: loggedInUser.gender,
                                      activeColor: Color(0xFF59C5CC),
                                      onChanged: (val) {
                                        setState(() {
                                          loggedInUser.gender = val as String;
                                          selectedGender = val as String;
                                          // Update the user's gender in loggedInUser
                                        });
                                      },
                                    ),
                                    Text("Male"),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Radio(
                                      value: "female",
                                      activeColor: Color(0xFF59C5CC),
                                      groupValue: loggedInUser.gender,
                                      onChanged: (val) {
                                        setState(() {
                                          loggedInUser.gender = val as String;
                                          selectedGender = val as String;// Update the user's gender in loggedInUser
                                        });

                                      },
                                    ),
                                    Text("Female"),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],),),
                // ************************************
                // Countact Number
                //*************************************

                Container(
                  margin:
                  EdgeInsets.only(left: margin_left, top: margin_top),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "Contact No",
                        style: TextStyle(
                            color: Color(0xFF3A8183),
                            fontWeight: FontWeight.w600),
                      ),
                      Container(
                        margin: EdgeInsets.only(right: margin_right),
                        width: boder,

                        decoration: BoxDecoration(
                          border: Border.all(
                              width: 1.0, color: Colors.black12),
                          borderRadius:
                          BorderRadius.all(Radius.circular(15.0),
                            //  <--- border radius here
                          ),
                        ),
                        padding: EdgeInsets.all(8),
                        child: IntlPhoneField(
                          cursorColor: kPrimaryColor,
                          style: TextStyle(fontSize: 16),
                          disableLengthCheck: false,
                          initialValue: loggedInUser.phone?.substring(4),
                          textAlignVertical: TextAlignVertical.center,
                          dropdownTextStyle: TextStyle(fontSize: 16),
                          dropdownIcon: Icon(Icons.arrow_drop_down,
                              color: kPrimaryColor),
                          initialCountryCode: 'MA',
                          onChanged: (phone) {
                            print(phone.completeNumber);
                            phoneController =
                                phone.completeNumber.toString();
                          },
                          decoration: InputDecoration(
                            border: InputBorder.none, // Set the border to none
                          ),
                        ),
                        //  child: Text("${loggedInUser.phone}"),
                      )
                    ],
                  ),
                ),



            // Usage example

               Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: <Widget>[
                      ButtonBar(
                        alignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "      Upload A Valid Proof",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3A8183),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 40.0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF66C9CC),
                                shape: StadiumBorder(),
                              ),
                              onPressed: () async {
                                chooseFile();
                              },
                              child: Text("Choose File"),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),



                Container(
                  margin: EdgeInsets.only(left: margin_left, top: margin_top),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "Status",
                        style: TextStyle(
                          color: Color(0xFF3A8183),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: margin_left, right: margin_right),
                        width: boder,
                        decoration: BoxDecoration(
                          border: Border.all(width: 1.0, color: Colors.black12),
                          borderRadius: BorderRadius.all(Radius.circular(15.0)),
                        ),
                        padding: EdgeInsets.all(8),
                        child: Row(
                          children: <Widget>[
                            ButtonBar(
                              alignment: MainAxisAlignment.center,
                              children: [
                                Row(

                                  children: [
                                    Radio(

                                      value: "unmarried",
                                      groupValue: loggedInUser.status,
                                      activeColor: Color(0xFF59C5CC),
                                      onChanged: (val) {
                                        setState(() {
                                          loggedInUser.status = val as String;
                                          selectedStatus = val as String;
                                        });
                                      },
                                    ),
                                    Container(
                                      // Adjust the size of the Text widget here
                                      child: Text(
                                        "Unmarried",
                                        style: TextStyle(
                                          fontSize: 13, // Adjust the font size as needed
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Radio(
                                      value: "married",
                                      groupValue: loggedInUser.status,
                                      activeColor:Color(0xFF59C5CC),
                                      onChanged: (val) {
                                        setState(() {
                                          loggedInUser.status = val as String;
                                          selectedStatus = val as String;
                                        });
                                      },
                                    ),
                                    Container(
                                      // Adjust the size of the Text widget here
                                      child: Text(
                                        "Married",
                                        style: TextStyle(
                                          fontSize: 13, // Adjust the font size as needed
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),



                Container(
                  width: size.width * 0.8,
                  margin: EdgeInsets.all(10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: StadiumBorder(),
                      padding: EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                      backgroundColor: Color(0xFF3A8183),
                    ),
                    onPressed: () async {
                      var url;
                      if (status == false) {
                        showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) =>
                                AdvanceCustomAlert());
                      } else {
                        showLoadingDialog(context: context);
                        if (file != null) {
                          url = await uploadImage();
                          print("URL ===== " + url.toString());
                        }
                        if (_formKey.currentState!.validate()) {
                          print("Done");
                          FirebaseFirestore firebaseFirestore =
                              FirebaseFirestore.instance;
                          firebaseFirestore
                              .collection('Sitter')
                              .doc(loggedInUser.uid)
                              .update({
                            'name': name == null
                                ? loggedInUser.name
                                : name,
                            'city': t_city == null
                                ? loggedInUser.city
                                : t_city,
                            'age': t_age == null
                                ? loggedInUser.age
                                : t_age,
                            'proof':url1==null
                                ?loggedInUser.proof
                                :url1,

                            'dob': t_date == null
                                ? loggedInUser.dob
                                : t_date,
                            'phone': phoneController == null
                                ? loggedInUser.phone
                                : phoneController,
                            'profileImage': url == null
                                ? loggedInUser.profileImage
                                : url,
                            'status': selectedStatus == null
                                ? loggedInUser.status
                                : selectedStatus,
                            'gender': selectedGender==null
                            ?loggedInUser.gender
                                :selectedGender,
                          })
                              .then((value) => Loading())
                              .then((value) =>
                              Navigator.pushAndRemoveUntil<dynamic>(
                                  context,
                                  MaterialPageRoute<dynamic>(
                                      builder:
                                          (BuildContext context) =>
                                          DocHomePage()),
                                      (route) => false));
                        }
                      }
                    },
                    child: Text(
                      'Update Profile',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  chooseImage() async {
    XFile? xfile = await ImagePicker().pickImage(source: ImageSource.gallery);
    print("file " + xfile!.path);
    file = File(xfile.path);
    setState(() {});
  }

  updateProfile(BuildContext context) async {
    var url;

    if (file != null) {
      url = await uploadImage();
      print("URL ===== " + url.toString());
    }
    print("uid =====" + user!.uid.toString());
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
}
