import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hospital_appointment/cells/detail_cell.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hospital_appointment/Screens/home/patient_home_page.dart';
import '../componets/loadingindicator.dart';
import '../constants.dart';
import '../he_color.dart';
import '../models/patient_data.dart';
import 'Rating_Review.dart';
import 'appointment_time_page.dart';

class DetailPage extends StatefulWidget {
  var uid;
  var name;
  var email;
  var address;
  var city;
  var experience;
  var specialist;
  var profileImage;
  var description;
  var phone;
  var available;
  var gender;

  DetailPage({
    required this.uid,
    required this.name,
    required this.email,
    required this.address,
    required this.city,
    required this.experience,
    required this.specialist,
    required this.profileImage,
    required this.description,
    required this.phone,
    required this.available,
    required this.gender,
    required doctor,
  });

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  /// **********************************************
  /// LIFE CYCLE METHODS
  /// **********************************************
  var rating = 0.0;

  List<double> rating_no = [];
  var sum = 0.0;

  var myDocuments = 0;

  bool isLoading = true;
  int today_app2 = 0;

  double rating1 = 0.0;
  var reviewController;
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();

  // bool review =false;
  bool _validate = false;

  var appointment = FirebaseFirestore.instance;

  var rating_len;
  var patient_count;

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
      this.loggedInUser = UserModel.fromMap(value.data());

      Future<void>.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          // Check that the widget is still mounted
          setState(() {
            isLoading = false;
          });
        }
      });
      print("++++++++++++++++++++++++++++++++++++++++++" + user!.uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    setState(() {});
    SizedBox(
        child: FutureBuilder(
      future: FirebaseFirestore.instance
          .collection('Sitter')
          .doc(widget.uid)
          .collection('rating')
          .where('pid', isEqualTo: loggedInUser.uid)
          .get()
          .then((myDocuments) {
        setState(() {
          rating_len = myDocuments.docs.length;
        });
        print("${"lenght rating_len = " + myDocuments.docs.length.toString()}");
        return myDocuments;
      }),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return SizedBox();
        }

        return SizedBox();
      },
    ));
    return Scaffold(
      appBar: _buildAppBar(size),
      body: isLoading == true
          ? Center(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Loading(),
                    SizedBox(
                      child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('Sitter/' + widget.uid + '/rating')
                              .snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (widget.available == false) {
                              Fluttertoast.showToast(
                                  msg: (widget.gender == 'female' ? 'Ms.  ' : 'Mrs.  ') +
                                      widget.name +
                                      " is not available...Visit later",
                                  textColor: Colors.white,
                                  backgroundColor: Color(0xFFF5F5F5));
                            }
                            if (!snapshot.hasData) {
                              return SizedBox();
                            } else {
                              today_app2 = snapshot.data!.docs.length;

                              print("snapshot: " + snapshot.hasData.toString());
                              snapshot.data?.docs.asMap().forEach((index, doc) {
                                if (today_app2 > index) {
                                  rating_no.add(double.parse(doc['rating_s']));
                                }
                              });
                              sum = 0;
                              rating_no.asMap().forEach((index, element) {
                                if (index < today_app2) {
                                  sum = sum + element.toDouble();
                                  print("element = " + element.toString());
                                  print("rating_no" +
                                      rating_no.length.toString());
                                }
                              });

                              print(
                                  "=========================================");
                              print("Sum=" + sum.toString());
                              rating = sum / today_app2;
                              print("rating=" + rating.toString());
                              FirebaseFirestore.instance
                                  .collection("Sitter")
                                  .doc(widget.uid)
                                  .update({
                                'rating': rating != null
                                    ? rating.toStringAsFixed(1).toString()
                                    : "0.0"
                              });
                              return SizedBox();
                            }
                          }),
                    ),
                    SizedBox(

                        child: FutureBuilder(
                      future: FirebaseFirestore.instance
                          .collection('pending')
                          .where('did', isEqualTo: widget.uid)
                          .get()
                          .then((myDocuments) {
                        setState(() {
                          patient_count = myDocuments.docs.length;
                          isLoading = false;
                        });
                        print(
                            "${"lenght = " + myDocuments.docs.length.toString()}");
                        print("rating count = " + rating_len);
                        return myDocuments;
                      }),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return SizedBox();
                        }

                        return SizedBox();
                      },
                    )),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.only(bottom: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _titleSection(size),
                  SizedBox(

                    height: 8,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (widget.gender == 'female' ? 'Ms.  ' : 'Mrs.  ') + widget.name,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Container(

                          margin: EdgeInsets.only(left: 8),
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          decoration: BoxDecoration(
                            color: Color(0xFF4CA6A8),
                            border: Border.all(color: Color(0xFF4CA6A8), width: 1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            widget.specialist,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),

                        SizedBox(
                          height: 8,
                        ),


                        SizedBox(
                          height: 10,
                        ),
                        rating_len == 0
                            ? InkWell(
                          onTap: () {
                            dialog();
                          },
                          child: Container(
                            margin: EdgeInsets.only(bottom: 5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(width: 1.0, color: Colors.grey),
                              borderRadius: BorderRadius.circular(10.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Write a Review",
                                    style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),
                                  ),
                                  Row(
                                    children: [
                                      for (int i = 0; i < 5; i++)
                                        Padding(
                                          padding: const EdgeInsets.only(left: 8.0, top: 8.0, bottom: 8.0),
                                          child: Icon(
                                            Icons.star,
                                            color: Colors.grey,
                                            size: 30,
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )


          : Text(
                                'Update Review',
                                style: TextStyle(color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          child: StreamBuilder<QuerySnapshot>(
                              stream: appointment
                                  .collection(
                                      'Sitter/' + widget.uid + '/rating')
                                  .where('pid', isEqualTo: loggedInUser.uid)
                                  .snapshots(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<QuerySnapshot> snapshot) {
                                if (!snapshot.hasData) {
                                  return SizedBox();
                                } else {
                                  return ListView.builder(
                                    shrinkWrap: true,
                                    // shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    scrollDirection: Axis.vertical,
                                    itemCount: snapshot.data?.docs.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      final DocumentSnapshot doc =
                                          snapshot.data!.docs[index];
                                      return SingleChildScrollView(
                                        child: InkWell(
                                          onTap: () {
                                            updatedialog(
                                                doc.id,
                                                double.parse(doc['rating_s']),
                                                doc['review']);
                                          },
                                          child: Container(
                                            margin: EdgeInsets.only(bottom: 5),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                width: 1.0,
                                                color: Color(0xFFFFFFFF),
                                              ),
                                              borderRadius: BorderRadius.circular(10.0),
                                              color: Colors.white,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.withOpacity(0.2),
                                                  spreadRadius: 2,
                                                  blurRadius: 4,
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
                                            ),

                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                      margin: EdgeInsets.only(
                                                          top: 5),
                                                      child: Text(
                                                        doc['name'],
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Colors.black),
                                                      )),
                                                  Row(
                                                      children: new List
                                                              .generate(
                                                          5,
                                                          (index) => buildStar(
                                                              context,
                                                              index,
                                                              double.parse(doc[
                                                                  'rating_s'])))),
                                                  Container(
                                                      margin: EdgeInsets.only(
                                                          top: 5),
                                                      child: Text(
                                                        doc['review'],
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Colors.black38),
                                                      ))
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }
                              }),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          // crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Rating & Review',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),


                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          Rating_Review(did: widget.uid)),
                                );
                              },
                              child: Text(
                                'Show All',
                                style: TextStyle(
                                  color: Color(0xFF6A6A6A),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              )

                            )
                          ],
                        ),
                        Container(
                          child: StreamBuilder<QuerySnapshot>(
                              stream: appointment
                                  .collection(
                                      'Sitter/' + widget.uid + '/rating')
                                  .snapshots(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<QuerySnapshot> snapshot) {
                                if (!snapshot.hasData) {
                                  return new Text("There is no expense");
                                } else {
                                  ub() {
                                    if (snapshot.data?.docs.length == 0) {
                                      return 0;
                                    } else if (snapshot.data?.docs.length ==
                                        1) {
                                      return 1;
                                    } else if (snapshot.data?.docs.length ==
                                        2) {
                                      return 2;
                                    } else {
                                      return 3;
                                    }
                                  }

                                  return ListView.builder(
                                    shrinkWrap: true,
                                    // shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    scrollDirection: Axis.vertical,
                                    itemCount: ub(),
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      final DocumentSnapshot doc =
                                          snapshot.data!.docs[index];
                                      return SingleChildScrollView(
                                        child: Container(
                                          margin: EdgeInsets.only(bottom: 5),
                                          decoration:BoxDecoration(
                                            color:Color(0xFFFFFFFF),
                                            border: Border.all(
                                              width: 1.0,
                                              color: Color(0xFFFFFFFF),
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey.withOpacity(0.2),
                                                spreadRadius: 2,
                                                blurRadius: 4,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(10.0),
                                            ),
                                          ),

                                            child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                    margin:
                                                        EdgeInsets.only(top: 5),
                                                    child: Text(
                                                      doc['name'],
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black),
                                                    )),
                                                Row(
                                                    children: new List.generate(
                                                        5,
                                                        (index) => buildStar(
                                                            context,
                                                            index,
                                                            double.parse(doc[
                                                                'rating_s'])))),
                                                Container(
                                                    margin:
                                                        EdgeInsets.only(top: 5),
                                                    child: Text(
                                                      doc['review'],
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              Colors.black38),
                                                    ))
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }
                              }),
                        ),
                        SizedBox(
                          height: 10,
                        ),


                        SizedBox(
                          height: 32,
                        ),
                        SizedBox(
                          height: 91,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              DetailCell(
                                  title: patient_count.toString(),
                                  subTitle: 'Parents'),
                              DetailCell(
                                  title: widget.experience + '+',
                                  subTitle: 'Exp. Years'),
                              DetailCell(
                                  title: today_app2.toString(),
                                  subTitle: 'Rating'),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 32,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                        Container(
                        padding: EdgeInsets.all(10),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF4CA6A8),

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),


        onPressed: () {
                                  Navigator.pushAndRemoveUntil<dynamic>(
                                      context,
                                      MaterialPageRoute<dynamic>(
                                          builder: (BuildContext context) =>
                                              HomePage()),
                                      (route) => false);
                                },
                                child: Container(
                                  margin: EdgeInsets.only(left: 5, right: 5),
                                  padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "Cancel",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: widget.available == true
                                  ? ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:Color(0xFF4CA6A8),





                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              12), // <-- Radius
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => Appoin_time(
                                                    uid: widget.uid,
                                                    name: widget.name,
                                                  gender:widget.gender,)),
                                        );
                                      },
                                      child: Container(
                                        margin:
                                            EdgeInsets.only(left: 5, right: 5),
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Text(
                                            "Appointment",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    )
                                  : ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              12), // <-- Radius
                                        ),
                                      ),
                                      onPressed: () {
                                        Fluttertoast.showToast(
                                            msg: (widget.gender== 'female' ? 'Ms.  ' : 'Mrs.  ') +
                                                widget.name +
                                                " is not available...Visit later",
                                            textColor: Colors.white,
                                            backgroundColor: Color(0xFF3879C7));
                                        ;
                                      },
                                      child: Container(
                                        margin:
                                            EdgeInsets.only(left: 5, right: 5),
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Text(
                                            "Appointment",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      ),
                                    ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  /// **********************************************
  /// WIDGETS
  /// **********************************************

  /// App Bar
  AppBar _buildAppBar(Size size) {
    final Uri smsLaunchUri = Uri(
      scheme: 'sms',
      path: widget.phone,
      queryParameters: <String, String>{
        'body': Uri.encodeComponent('Hello'),
      },
    );
    return AppBar(
      backgroundColor: Color(0xFFF5F5F5),
      elevation: 0,
      iconTheme: IconThemeData(color: Color(0xFF4CA6A8)),
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        Container(
          child: IconButton(
            icon: Icon(Icons.call,
                size: 25,
              color: Color(0xFF4CA6A8),
            ),
            onPressed: () async {
              final Uri _teleLaunchUri = Uri(
                scheme: 'tel',
                path: widget.phone, // your number
              );
              launchUrl(_teleLaunchUri);
            },
          ),
        ),
        Container(
          child: IconButton(
            icon: ImageIcon(
              AssetImage("assets/images/chat.png"),
              size: 25,
              color: Color(0xFF4CA6A8),
            ),
            onPressed: () {
              launchUrl(smsLaunchUri);
            },
          ),
        ),
      ],
    );
  }

  //Title Section
  Container _titleSection(Size size) {
    return Container(

      height: 250,
      color: Color(0xFFFFFFFF),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: 207,
              height: 178,
              child: Image(
                filterQuality: FilterQuality.high,
                fit: BoxFit.fitHeight,
                image: AssetImage('assets/images/bg_shape.png'),
              ),
            ),
          ),
          Positioned(
            right: size.width / 3.5,
            bottom: -3,
            child: Container(
              height: 250,
              child: AspectRatio(
                aspectRatio: 196 / 285,
                child: Hero(
                    tag: widget.name,
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Color(0xFF4CA6A8),
                      child: widget.profileImage == false
                          ? CircleAvatar(
                              radius: 80,
                              backgroundImage:
                                  AssetImage('assets/images/account.png'),
                            )
                          : CircleAvatar(
                              radius: 80,
                              backgroundImage:
                                  NetworkImage(widget.profileImage),
                            ),
                    )),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 15,
              color: Colors.white,
            ),
          ),
          Positioned(
            right: 32,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: HexColor('#FFBB23'),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text(
                    rating.toStringAsFixed(1).toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    width: 4,
                  ),
                  Icon(
                    Icons.star,
                    color: Colors.white,
                    size: 14,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRating() => RatingBar.builder(
        itemBuilder: (context, _) => Icon(
          Icons.star,
          color: Colors.amber,
        ),
        initialRating: rating1,
        itemSize: 40,
        itemPadding: EdgeInsets.symmetric(horizontal: 4),
        updateOnDrag: true,
        onRatingUpdate: (velue) {
          setState(() {
            rating1 = velue;
          });
        },
        maxRating: 1,
      );

  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Select Star and giving Review '),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                    backgroundColor: Color(0xFF4CA6A8),
                    foregroundColor: Colors.white),
                child: Text('OK'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
  }

  void dialog() => showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0)),
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.50,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 90, 10, 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text(
                            'Doctor Rating',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        buildRating(), //child: ),
                        SizedBox(

                          height: 15,
                        ),
                        Padding(

                          padding: EdgeInsets.all(15),
                          child: TextField(
                            // controller: reviewController,
                            decoration: InputDecoration(


                              border: OutlineInputBorder(),
                              labelText: 'Review',
                              hintText: 'Review',
                              errorText: _validate ? 'Enter Review' : null,
                            ),
                            onChanged: (var name) {
                              reviewController = name.trim();
                            },
                          ),
                        ),

                        Container(
                          margin: EdgeInsets.only(top: 1, left: 20, right: 20),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF4CA6A8)),
                                  child: Text(
                                    'CANCEL',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    if (rating1 != 0.0 &&
                                        reviewController != null) {
                                      FirebaseFirestore.instance
                                          .collection('Sitter/' +
                                              widget.uid +
                                              '/rating')
                                          .add({
                                        'rating_s': rating1.toString(),
                                        'review': reviewController,
                                        'name': loggedInUser.name.toString() +
                                            ' ' +
                                            loggedInUser.last_name.toString(),
                                        'pid': loggedInUser.uid
                                      });
                                      isLoading = true;
                                      Navigator.of(context).pop();
                                    } else {
                                      _displayTextInputDialog(context);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF4CA6A8)),
                                  child: Text(
                                    'OK',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  child: widget.profileImage == false
                      ? CircleAvatar(
                          backgroundImage:
                              AssetImage('assets/images/account.png'),
                          backgroundColor: Colors.transparent,
                          radius: 50,
                        )
                      : CircleAvatar(
                          backgroundImage: NetworkImage(widget.profileImage),
                          backgroundColor: Colors.transparent,
                          radius: 50,
                        ),
                ),
              ],
            ),
          ));

  void updatedialog(var id, double rating_s, var review) => showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0)),
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.50,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 90, 10, 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text(
                            'Doctor Rating',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        RatingBar.builder(
                          itemBuilder: (context, _) => Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          initialRating: rating_s,
                          itemSize: 40,
                          itemPadding: EdgeInsets.symmetric(horizontal: 4),
                          updateOnDrag: true,
                          onRatingUpdate: (velue) {
                            setState(() {
                              rating_s = velue;
                            });
                          },
                          maxRating: 1,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: EdgeInsets.all(15),
                          child: TextField(
                            //  controller: reviewController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Review',
                              hintText: 'Review',
                              errorText: _validate ? 'Enter Review' : null,
                            ),
                            onChanged: (var name) {
                              reviewController = name.trim();
                            },
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 20, left: 20, right: 20),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor:Color(0xFF4CA6A8)),
                                  child: Text(
                                    'CANCEL',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    if (rating_s != 0.0 &&
                                        reviewController != null) {
                                      FirebaseFirestore.instance
                                          .collection('Sitter/' +
                                              widget.uid +
                                              '/rating')
                                          .doc(id)
                                          .update({
                                        'rating_s': rating_s.toString(),
                                        'review': reviewController,
                                      });
                                      Navigator.of(context).pop();
                                    } else {
                                      _displayTextInputDialog(context);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF4CA6A8)),
                                  child: Text(
                                    'OK',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  child: widget.profileImage == false
                      ? CircleAvatar(
                          backgroundImage:
                              AssetImage('assets/images/account.png'),
                          backgroundColor: Colors.transparent,
                          radius: 50,
                        )
                      : CircleAvatar(
                          backgroundImage: NetworkImage(widget.profileImage),
                          backgroundColor: Colors.transparent,
                          radius: 50,
                        ),
                ),

                // Positioned(
                //     top: 10,
                //     child: CircleAvatar(
                //       backgroundColor: Colors.white,
                //       radius: 50,
                //       child: Image.asset(
                //         'assets/images/account.png',
                //         fit: BoxFit.cover,
                //       ),
                //     )),
              ],
            ),
          ));

  Widget buildStar(BuildContext context, int index, double doc) {
    var icon;
    if (index >= doc) {
      icon = Icon(
        Icons.star_border,
        color: Colors.amber,
        size: 20,
      );
    } else if (index > doc - 1 && index < doc) {
      icon = Icon(
        Icons.star_half,
        color: Colors.amber,
        size: 20,
      );
    } else {
      icon = Icon(
        Icons.star,
        color: Colors.amber,
        size: 20,
      );
    }
    return icon;
  }
}

class StarDisplay extends StatelessWidget {
  final double value;

  const StarDisplay({this.value = 0}) : assert(value != null);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < value ? Icons.star : Icons.star_border,
          size: 25,
        );
      }),
    );
  }
}
