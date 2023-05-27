import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../componets/loadingindicator.dart';
import '../../../constants.dart';
import '../../../models/doctor.dart';

class Patient_RecentList extends StatefulWidget {
  const Patient_RecentList({Key? key}) : super(key: key);

  @override
  State<Patient_RecentList> createState() => _Patient_RecentListState();
}

var today_date = Timestamp.fromDate(DateTime.now());


class _Patient_RecentListState extends State<Patient_RecentList> {
  var appointment = FirebaseFirestore.instance;
  DoctorModel loggedInUser = DoctorModel();
  var user = FirebaseAuth.instance.currentUser;
  bool isLoading = true;
  var firebase;
  var t_date;
  var mydate;

  String dropdownValue = 'All';

  @override
  void initState() {
    super.initState();
    loggedInUser = DoctorModel();
    FirebaseFirestore.instance
        .collection("parent")
        .doc(user!.uid)
        .get()
        .then((value) {
      loggedInUser = DoctorModel.fromMap(value.data()!);
      firebase = appointment
          .collection('pending')
          .orderBy('date', descending: true)
          .where('pid', isEqualTo: loggedInUser.uid)
          .where('date', isGreaterThanOrEqualTo: today_date)
          .snapshots();

      setState(() {
        sleep(Duration(seconds: 0));
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            Container(
              width: size.width * 1,
              margin: EdgeInsets.only(left: 10),
              child: DropdownButton2(
                isExpanded: true,
                value: dropdownValue,
                icon: Icon(Icons.arrow_drop_down),
                iconSize: 24,
                iconEnabledColor: Color(0xFF4CA6A8),
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
                      firstDate: DateTime.now(),
                      lastDate: DateTime(9999),
                    );

                    setState(() {
                      t_date = mydate != null ? Timestamp.fromDate(mydate!) : null;
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
                  DateFormat('dd-MM-yyyy').format(t_date!.toDate()),

                  style: TextStyle(fontSize: 18),
              ),
            )
                : SizedBox(),
            Container(
              child: SingleChildScrollView(
                child: StreamBuilder<QuerySnapshot>(
                  stream: firebase,
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return Container(
                        margin: EdgeInsets.only(top: size.height * 0.4),
                        child: Center(
                          child: Loading(),
                        ),
                      );
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
                            final DocumentSnapshot doc = snapshot.data!.docs[index];

                            return Container(
                              width: double.infinity,
                              margin: EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 2,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(8.0),
                                color: doc['visited'] == false ? Color(0xFFFFFFFF) : Color(0xFFFFFFFF), //kPrimaryColor,
                              ),
                              child: Center(
                                child: doc['visited'] == false
                                    ? Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(),
                                        child: Text(
                                          (doc['gender'] == 'female' ? 'Ms.  ' : 'Mrs.  ') + doc['doctor_name'],
                                          style: TextStyle(
                                            color: Color(0xFF151313),
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        margin: EdgeInsets.only(top: 3),
                                        decoration: BoxDecoration(),
                                        child: Text(
                                          "Date: " + doc['date'],
                                          style: TextStyle(
                                            color: Color(0xFF151313),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(),
                                        child: Text(
                                          "Time: " + doc['time'],
                                          style: TextStyle(
                                            color: Color(0xFF151313),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Container(
                                        child: Text(
                                          "Status : Not Visited",
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                    : Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(),
                                        child: Text(
                                          (doc['gender'] == 'female' ? 'Ms.  ' : 'Mrs.  ') + doc['doctor_name'],
                                          style: TextStyle(
                                            color: Color(0xFF151313),
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        margin: EdgeInsets.only(top: 3),
                                        decoration: BoxDecoration(),
                                        child: Text(
                                          "Date: " + doc['date'],
                                          style: TextStyle(
                                            color: Color(0xFF151313),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(),
                                        child: Text(
                                          "Time: " + doc['time'],
                                          style: TextStyle(
                                            color: Color(0xFF151313),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Container(
                                        child: Text(
                                          "Status : Visited",
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
