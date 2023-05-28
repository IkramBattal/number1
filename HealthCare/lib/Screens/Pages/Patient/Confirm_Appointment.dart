import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../componets/loadingindicator.dart';
import '../../../models/patient_data.dart';
import 'Pending.dart';


class Confirm_Appointment extends StatefulWidget {
  const Confirm_Appointment({Key? key}) : super(key: key);

  @override
  State<Confirm_Appointment> createState() => _Confirm_AppointmentState();
}

class _Confirm_AppointmentState extends State<Confirm_Appointment> {
  var appointment = FirebaseFirestore.instance;
  UserModel loggedInUser = UserModel();
  var user = FirebaseAuth.instance.currentUser;
  bool isLoading = true;
  var today_date = (DateFormat('dd-MM-yyyy')).format(DateTime.now()).toString();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    loggedInUser = UserModel();
    FirebaseFirestore.instance
        .collection("parent")
        .doc(user!.uid)
        .get()
        .then((value) {
      loggedInUser = UserModel.fromMap(value.data());
      Future<void>.delayed(const Duration(seconds: 0), () {
        if (mounted) {
          // Check that the widget is still mounted
          setState(() {
            isLoading = false;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var firebase = appointment
        .collection('pending')
        .orderBy('date', descending: true)
        .orderBy('time', descending: false)
        .where('pid', isEqualTo: loggedInUser.uid)
        .where('approve', isEqualTo: true)
        .where('date', isGreaterThanOrEqualTo: today_date)
        .snapshots();
    return Scaffold(
      body: SingleChildScrollView(
        child: StreamBuilder<QuerySnapshot>(
            stream: firebase,
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return Container(
                    height: size.height * 1,
                    child: Center(
                        child: Text("You Do Not Have An Appointment today.")));
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

                            Future.delayed(Duration(seconds: 3));
                            return snapshot.hasData == null
                                ? Center(child: Text("Not Available"))
                                : Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 6),
                                    child: Container(
                                      height: 104,
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8.0)),
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey.withOpacity(0.2),
                                                spreadRadius: 2,
                                                blurRadius: 4,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            color: Color(0xFFFFFFFF),

                                          ),
                                          child: Stack(
                                            children: [
                                              Column(
                                                children: [
                                                  Container(
                                                      width: double.infinity,
                                                      decoration:
                                                          BoxDecoration(),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 8.0,
                                                                top: 8.0),
                                                        child: Text(
                                                          (doc['gender'] == 'female' ? 'Ms.  ' : 'Mrs.  ') +
                                                              doc['doctor_name'],
                                                          style: TextStyle(
                                                              color:
                                                              Color(0xFF151313),
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ) // child widget, replace with your own
                                                      ),
                                                  Container(
                                                      width: double.infinity,
                                                      margin: EdgeInsets.only(
                                                          top: 3),
                                                      decoration:
                                                          BoxDecoration(),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 8.0),
                                                        child: Text(
                                                            "Date    : "+ DateFormat('dd-MM-yyyy').format(doc['date'].toDate()).toString(),
                                                          style: TextStyle(
                                                              color:
                                                              Color(0xFF151313),
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                        ),
                                                      ) // child widget, replace with your own
                                                      ),
                                                  Container(
                                                      width: double.infinity,
                                                      decoration:
                                                          BoxDecoration(),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 8.0),
                                                        child: Text(
                                                          "Time: " +
                                                              doc['time'],
                                                          style: TextStyle(
                                                              color:
                                                                  Color(0xFF151313),
                                                              fontSize: 14,
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
                                                  "Status : Confirm",
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              Positioned(
                                                bottom: 5,
                                                right: 10,
                                                child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:Color(0xFF4CA6A8),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12), // <-- Radius
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    showDialog(
                                                        context: context,
                                                        barrierDismissible:
                                                            false,
                                                        builder: (BuildContext
                                                                context) =>
                                                            alertdialog(
                                                                id: doc.id));
                                                  },
                                                  child: Container(
                                                    margin: EdgeInsets.only(
                                                        left: 5, right: 5),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 10.0,
                                                              bottom: 10),
                                                      child: Text(
                                                        "Cancel ",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              )
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
    );
  }
}
