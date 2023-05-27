import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hospital_appointment/constants.dart';
import 'package:hospital_appointment/theme/extention.dart';
import 'package:intl/intl.dart';
import '../../../componets/loadingindicator.dart';
import '../../../models/doctor.dart';
import '../../../newapp/searchList3.dart';
import '../../../theme/light_color.dart';
import '../../../widget/DoctorDrawer.dart';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hospital_appointment/models/doctor.dart';
import 'package:hospital_appointment/theme/extention.dart';

import 'dart:ui';
import 'package:flutter/painting.dart';
class visited extends StatefulWidget {
  @override
  _visitedState createState() => _visitedState();
}

class _visitedState extends State<visited> {
  var appointment = FirebaseFirestore.instance;
  String uid = FirebaseAuth.instance.currentUser!.uid;

  var today_date = (DateFormat('dd-MM-yyyy')).format(DateTime.now()).toString();

  FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference firebase =
      FirebaseFirestore.instance.collection("Sitter");
  User? user = FirebaseAuth.instance.currentUser;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool isLoading = true;
  late TabController tabController;
  DoctorModel loggedInUser = DoctorModel();
  var t_date;
  var mydate;

  String dropdownValue = 'All';

  Future<void> _getUser() async {
    user = _auth.currentUser;
  }

  @override
  void initState() {
    super.initState();
    _getUser();

    loggedInUser = DoctorModel();
    FirebaseFirestore.instance
        .collection("Sitter")
        .doc(user!.uid)
        .get()
        .then((value) {
      loggedInUser = DoctorModel.fromMap(value.data());
      setState(() {
        sleep(Duration(microseconds: 10));
        isLoading = false;
      });
    });
  }
  Widget _searchField() {
    TextEditingController _searchController = TextEditingController();

    return  Container(
      height: 55,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(13)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: LightColor.grey.withOpacity(.3),
            blurRadius: 15,
            offset: Offset(5, 5),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController, // Add the controller here
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: InputBorder.none,
          hintText: "Search",
          hintStyle: TextStyle(color:Color(0xFF424040)),
          suffixIcon: SizedBox(
            width: 50,
            child: Icon(Icons.search,color: Color(0xff388081))
                .alignCenter
                .ripple(() {
              String searchKey = _searchController.text;
              if (searchKey.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchList3(
                      searchKey: searchKey,
                    ),
                  ),
                );
              }
            }, borderRadius: BorderRadius.circular(13)),
          ),
        ),
      ),
    );

  }



  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var firebase = appointment
        .collection('pending')
        .orderBy('time', descending: false)
        .where('did', isEqualTo: loggedInUser.uid)
        .where('approve', isEqualTo: true)
        .where('visited', isEqualTo: true)
        .where('date', isEqualTo: t_date)
        .snapshots();

    return Scaffold(
      backgroundColor: Color(0xfffbfbfb),
      key: _scaffoldKey,
      drawer: loggedInUser.uid == null ? SizedBox() : DocDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        flexibleSpace: Stack(
          children: [
            Positioned(
              top: 26,
              left: 3.5,
              child: Container(
                padding: EdgeInsets.fromLTRB(25 , 25, 25 , 25),
                decoration: BoxDecoration(
                  color: Color(0xff4ca6a8),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                    topLeft: Radius.circular(15),
                    bottomLeft: Radius.circular(15),
                  ),
                ),
              ),
            ),

            Container(
              padding: EdgeInsets.only(top: 46),
              alignment: Alignment.topCenter,
              child: Text(
                "Visited",
                style:  TextStyle (
                  fontFamily: 'Poppins',
                  fontSize: 30,

                  fontWeight:  FontWeight.w700,                  height: 1,
                  color:  Color(0xff4ca5a7),
                ),
              ),

            ),
          ],
        ),
      ),
      body: loggedInUser.uid == null
          ? Center(
        child: Text("Wait for few seconds"),
      )
          : SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          SizedBox(
          height: 30,
        ),
        //Search patient
        _searchField(),

            Container(
              width: size.width * 1,
              margin: EdgeInsets.only(left: 10),
              child: DropdownButton2(
                isExpanded: true,
                value: dropdownValue,
                icon: Icon(Icons.arrow_drop_down),
                iconSize: 24,
                iconEnabledColor: kPrimaryColor,
                buttonHeight: 50,
                buttonPadding: const EdgeInsets.only(left: 14, right: 14),
                buttonElevation: 2,
                itemHeight: 40,
                itemPadding: const EdgeInsets.only(left: 14, right: 14),
                dropdownMaxHeight: 200,
                dropdownDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                ),
                scrollbarRadius: const Radius.circular(40),
                scrollbarThickness: 6,
                scrollbarAlwaysShow: true,
                style: TextStyle(color: Colors.black, fontSize: 18),
                onChanged: (data) async {
                  setState(() {
                    dropdownValue = data.toString();
                  });

                  if (data == 'All') {
                    setState(() {
                      t_date = null;
                    });
                  } else {
                    mydate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1950),
                        lastDate: DateTime.now());

                    setState(() {
                      t_date = DateFormat('dd-MM-yyyy').format(mydate);
                      print(t_date);
                    });
                  }
                },
                items: [
                  DropdownMenuItem(
                    value: 'All',
                    child: Text('All'),
                  ),
                  DropdownMenuItem(
                    value: 'Custom Date',
                    child: Text('Custom Date'),
                  ),
                ],
              ),
            ),
            t_date != null
                ? Container(
                    width: size.width * 1,
                    margin: EdgeInsets.only(left: 38),
                    child: Text(
                      t_date,
                      style: TextStyle(fontSize: 18),
                    ))
                : SizedBox(),
            Container(
              child: SingleChildScrollView(
                child: StreamBuilder<QuerySnapshot>(
                    stream: firebase,
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (!snapshot.hasData) {
                        return Container(
                            height: size.height * 1,
                            child: Center(
                                child: Text("Appointment not available")));
                      } else {
                        return isLoading
                            ? Container(
                                margin: EdgeInsets.only(top: size.height * 0.4),
                                child: Center(
                                  child: Loading(),
                                ),
                              )
                            : SingleChildScrollView(
                                physics: BouncingScrollPhysics(),
                                child: ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  itemCount: snapshot.data!.docs.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final DocumentSnapshot doc =
                                        snapshot.data!.docs[index];
                                    Future.delayed(Duration(seconds: 3));
                                    return snapshot.hasData == null
                                        ? Center(
                                            child: Text(
                                                "Appointment Nottt Available"))
                                        : Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 2),
                                            child: Container(
                                              height: 104,
                                              child: Card(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(8.0)),
                                                ),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                    color:
                                                        Colors.green.shade400,
                                                  ),
                                                  child: Stack(
                                                    children: [
                                                      Column(
                                                        children: [
                                                          Container(
                                                              width: double
                                                                  .infinity,
                                                              decoration:
                                                                  BoxDecoration(),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            8.0,
                                                                        top:
                                                                            8.0),
                                                                child: Text(
                                                                  'Name: ' +
                                                                      doc['name'],
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          18,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ) // child widget, replace with your own
                                                              ),
                                                          Container(
                                                              width: double
                                                                  .infinity,
                                                              margin: EdgeInsets
                                                                  .only(top: 3),
                                                              decoration:
                                                                  BoxDecoration(),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            8.0),
                                                                child: Text(
                                                                  "Date    : "+ DateFormat('dd-MM-yyyy').format(doc['date'].toDate()).toString(),
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500),
                                                                ),
                                                              ) // child widget, replace with your own
                                                              ),
                                                          SizedBox(
                                                            height: 4,
                                                          ),
                                                          Container(
                                                              width: double
                                                                  .infinity,
                                                              decoration:
                                                                  BoxDecoration(),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            8.0),
                                                                child: Text(
                                                                  "Time: " +
                                                                      doc['time'],
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500),
                                                                ),
                                                              ) // child widget, replace with your own
                                                              ),
                                                        ],
                                                      ),
                                                      Positioned(
                                                        bottom: 5,
                                                        left: 8,
                                                        child: Text(
                                                          "Status : Visited",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                  },
                                ),
                              );
                      }
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
