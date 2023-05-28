import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hospital_appointment/theme/extention.dart';
import 'package:intl/intl.dart';

import '../Screens/home/doctor_home_page.dart';
import '../componets/loadingindicator.dart';
import '../models/doctor.dart';
import '../theme/text_styles.dart';
import '../widget/DoctorDrawer.dart';

class SearchList2 extends StatefulWidget {
  final String searchKey;

  const SearchList2({Key? key, required this.searchKey}) : super(key: key);

  @override
  _SearchList2State createState() => _SearchList2State();
}

class _SearchList2State extends State<SearchList2> {
  String uid = FirebaseAuth.instance.currentUser!.uid;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference firebase =
  FirebaseFirestore.instance.collection("Sitter");
  var appointment = FirebaseFirestore.instance;
  User? user = FirebaseAuth.instance.currentUser;
  bool isLoading = true;
  late TabController tabController;
  DoctorModel loggedInUser = DoctorModel();

  /// ****************
  /// ACTIONS
  /// ****************

  /// ****************
  /// LIFE CYCLE METHODS
  /// ****************

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


  @override
  Widget build(BuildContext context) {
    var firebase = appointment
        .collection('pending')
        .where('did', isEqualTo: loggedInUser.uid)
        .orderBy('name')
        .startAt([widget.searchKey.toLowerCase()]).endAt(
        [widget.searchKey.toLowerCase() + '\uf8ff']).snapshots();

print(widget.searchKey);
    var size = MediaQuery.of(context).size;
    context1 = context;
    sleep(Duration(seconds: 1));
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
                "CareMate",
                style:  TextStyle (
                  fontFamily: 'Poppins',
                  fontSize: 30,
                  fontWeight:  FontWeight.w700,height: 1,
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
            Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: 20, bottom: 10),
                child: Text("Search Results For '"+widget.searchKey+"'", style:  TextStyle (
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  height: 1,
                  color: Color(0xff151313),
                ),)
            ),

            StreamBuilder<QuerySnapshot>(
                stream: firebase,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return Container(
                        height: size.height * 1,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 300),
                          child: Center(
                              child: Text(" You Do Not Have An Appointment today.", style: TextStyles.title.bold)),
                        ));
                  } else {
                    return isLoading
                        ? Container(
                      margin:
                      EdgeInsets.only(top: size.height * 0.4),
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

                          return Padding(

                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            child: Container(
                              margin: EdgeInsets.fromLTRB(0, 0, 13,10),
                              width: 353,
                              height: 100,
                              decoration:  BoxDecoration (
                                color:  Color(0xffffffff),
                                borderRadius:  BorderRadius.circular(20),
                                boxShadow:  [
                                  BoxShadow(
                                    color:  Color(0x19000000),
                                    offset:  Offset(0, 30),
                                    blurRadius:  20.5,
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  Column(
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                                          child: Text(
                                            doc['name'][0].toUpperCase()+doc['name'].substring(1),
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 20,
                                              fontWeight: FontWeight.w500,
                                              height: 1,
                                              color: Color(0xff151313),

                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        margin: EdgeInsets.only(top: 3),
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 8.0),
                                          child: Text(
                                            "Date    : "+ (DateFormat('dd-MM-yyyy').format(doc['date'].toDate())).toString(),
                                            style:  TextStyle (
                                              fontFamily: 'Poppins',
                                              fontSize: 15,

                                              fontWeight: FontWeight.w500,
                                              height: 1,
                                              color:  Color(0xff6a6a6a),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 8.0, top: 4),
                                          child: Text(
                                            "Time : "+doc['time'],
                                            style:  TextStyle (
                                              fontFamily: 'Poppins',
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                              height: 1,
                                              color:  Color(0xff6a6a6a),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        margin: EdgeInsets.only(top: 3),
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 8.0),
                                          child: Text(
                                            doc['approve']==false ?"Status : Pending":"Status : Confirmed",
                                            style:  TextStyle (
                                              fontFamily: 'Poppins',
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                              height: 1,
                                              color:  Color(0xff343434),                                              ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 10,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xD35DD982),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        minimumSize: Size(10, 10),
                                        // Adjust the size as needed
                                      ),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (BuildContext context) => confirm(id: doc.id),
                                        );

                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(left: 0, right: 0),
                                        child: Padding(
                                          padding: const EdgeInsets.only(top: 10.0, bottom: 10),
                                          child: doc['approve']
                                              ? Text(
                                            '  Visited  ',
                                            style: TextStyle(fontSize: 14),
                                          )
                                              : Icon(
                                            Icons.check,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 4,
                                    right: 10,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xE4F65656),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        minimumSize: Size(10, 10),
                                      ),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (BuildContext context) => alertdialog(id: doc.id),
                                        );
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(left: 0, right: 0),
                                        child: Padding(
                                          padding: const EdgeInsets.only(top: 10.0, bottom: 10),
                                          child: doc['approve']
                                              ? Text(
                                            'Not Visited',
                                            style: TextStyle(fontSize: 12),
                                          )
                                              : Icon(
                                            Icons.close,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],

                              ),
                            ),


                          );
                          ;
                        },
                      ),
                    );
                  }
                }),
          ],
        ),
      ),
    );
  }
}

class alertdialog extends StatelessWidget {
  var id;

  alertdialog({required this.id});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.32,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 70, 10, 10),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 45),
                    child: Text(
                      'Are you sure you want to cancel this appointment?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'No',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(8), // <-- Radius
                            ),
                          ),
                        ),


                        Container(
                          child: ElevatedButton(
                            onPressed: () {
                              FirebaseFirestore.instance
                                  .collection('pending')
                                  .doc(id)
                                  .delete();
                              Navigator.pop(context);
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 19),
                              child: Text(
                                'Yes',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(8), // <-- Radius
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }
}

class confirm extends StatelessWidget {
  var id;

  confirm({required this.id});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.32,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 70, 10, 10),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 45),
                    child: Text(
                      'Are you sure you want to confirm this appointment?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'No',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(8), // <-- Radius
                            ),
                          ),
                        ),

                        Container(
                          child: ElevatedButton(
                            onPressed: () {
                              FirebaseFirestore.instance
                                  .collection('pending')
                                  .doc(id)
                                  .update({
                                'approve': true,
                              });
                              Navigator.pop(context);
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 19),
                              child: Text(
                                'Yes',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(8), // <-- Radius
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }

}
