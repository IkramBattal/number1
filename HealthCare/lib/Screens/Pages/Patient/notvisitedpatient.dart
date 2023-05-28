import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hospital_appointment/constants.dart';
import 'package:hospital_appointment/theme/extention.dart';
import 'package:intl/intl.dart';
import '../../../componets/loadingindicator.dart';
import '../../../models/doctor.dart';
import '../../../newapp/searchList4.dart';
import '../../../theme/light_color.dart';
import '../../../widget/DoctorDrawer.dart';

class notvisited extends StatefulWidget {
  @override
  _notvisitedState createState() => _notvisitedState();
}

class _notvisitedState extends State<notvisited> {
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

  Future<void> _getUser() async {
    user = _auth.currentUser;
  }

  @override
  void initState() {
    super.initState();
    _getUser();

    // tabController = TabController(length: 3, initialIndex: 0, vsync: this);
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
                    builder: (context) => SearchList4(
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
        .orderBy('date', descending: false)
        .orderBy('time', descending: false)
        .where('did', isEqualTo: loggedInUser.uid)
        .where('approve', isEqualTo: false)
        .where('visited', isEqualTo: false)
    // .where('date', isGreaterThanOrEqualTo: today_date)
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
                "Pending",

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
            SingleChildScrollView(
              child: StreamBuilder<QuerySnapshot>(
                  stream: firebase,
                  builder:
                      (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return Container(
                          height: size.height * 1,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 300),
                            child: Center(child: Text("Appointment not available")),
                          ));
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
                          itemBuilder: (BuildContext context, int index) {
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
                                              "Date    : "+ DateFormat('dd-MM-yyyy').format(doc['date'].toDate()).toString(),
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
                                              "Time   : "+doc['time'],
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
                                                color:  Color(0xff6a6a6a),                                              ),
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
                                          minimumSize: Size(20, 15), // Adjust the size as needed
                                        ),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (BuildContext context) => confirm1(id: doc.id),
                                          );
                                        },
                                        child: Container(
                                          margin: EdgeInsets.only(left: 5, right: 5),
                                          child: Padding(
                                            padding: const EdgeInsets.only(top: 10.0, bottom: 10),
                                            child: Icon(
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
                                          minimumSize: Size(20, 15),
                                        ),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (BuildContext context) => alertdialog(id: doc.id),
                                          );
                                        },
                                        child: Container(
                                          margin: EdgeInsets.only(left: 5, right: 5),
                                          child: Padding(
                                            padding: const EdgeInsets.only(top: 10.0, bottom: 10),
                                            child: Icon(
                                              Icons.close,
                                              size:16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),


                                  ],

                                ),
                              ),


                            );
                          },
                        ),
                      );
                    }
                  }),
            ),
          ],),),);
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
                    padding: const EdgeInsets.only(top: 48),
                    child: Text(
                      'Are you sure this client not visited yet?',
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
                        SizedBox(
                          width: 30,
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Positioned(
                top: -50,
                child: CircleAvatar(
                  backgroundColor: Colors.grey,
                  radius: 50,
                  child: Image.asset('assets/images/logo1.jpg'),
                )),
          ),
        ],
      ),
    );
  }
}

class confirm1 extends StatelessWidget {
  var id;

  confirm1({required this.id});

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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Positioned(
                top: -50,
                child: CircleAvatar(
                  backgroundColor: Colors.grey,
                  radius: 50,
                  child: Image.asset('assets/images/logo1.jpg'),
                )),
          ),
        ],
      ),
    );
  }
}