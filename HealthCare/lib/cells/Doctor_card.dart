import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../constants.dart';

class SelectCard extends StatefulWidget {
  final name;
  final email;
  final specialist;
  final profileImage;
  final rating;
  final did;

  SelectCard({
    required this.name,
    required this.email,
    required this.specialist,
    required this.profileImage,
    required this.rating,
    required this.did,
    //   required this.onTap,
  });

  @override
  State<SelectCard> createState() => _SelectCardState();
}

class _SelectCardState extends State<SelectCard> {
  var patient_count = 0;

  @override
  void initState() {
    // TODO: implement initState

    FutureBuilder(
      future: FirebaseFirestore.instance
          .collection('pending')
          .where('did', isEqualTo: widget.did)
          .get()
          .then((myDocuments) {
        setState(() {
          patient_count = myDocuments.docs.length;
        });

        print("${"lenght = " + myDocuments.docs.length.toString()}");

        return myDocuments;
      }),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(child: CircularProgressIndicator());
        }
        return SizedBox();
      },
    );

    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return GestureDetector(
      child: Container(
        width: size.width * 1,
        height: 200,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: 16,
              child: SizedBox(
                width: 180,
                height: 200,
                child: Image(
                  image: AssetImage('assets/images/bg_shape.png'),
                ),
              ),
            ),
            Positioned(
              top: 15,
              left: size.width / 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: TextStyle(
                      color: Color(0xFF151313),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Text(
                    widget.specialist,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    patient_count.toString() + " Parent Visited",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Row(
                    children: new List.generate(
                      5,
                          (index) => buildStar(
                        context,
                        index,
                        double.parse(widget.rating) != 'NaN'
                            ? double.parse(widget.rating)
                            : 0.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              bottom: 0,
              child: Container(
                width: 77,
                height: 54,
                decoration: BoxDecoration(
                  color: Color(0xFF4CA6A8),
                  borderRadius: BorderRadius.only(topRight: Radius.circular(32)),
                ),
                child: Icon(
                  Icons.arrow_forward,
                  color: Color(0xFFFFFFFF),
                  size: 25,
                ),
              ),
            ),
            Positioned(
              top: 15,
              left: 20,
              child: Container(
                child: CircleAvatar(
                  radius: 65,
                  backgroundColor: Color(0xFF4CA6A8),
                  child: widget.profileImage == false
                      ? CircleAvatar(
                    radius: 60,
                    backgroundImage: AssetImage('assets/images/account.png'),
                  )
                      : CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(widget.profileImage),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

    );
  }

  Widget buildStar(BuildContext context, int index, double doc) {
    var icon;
    if (index >= doc) {
      icon = Icon(
        Icons.star_border,
        color: Colors.amber,
        size: 30,
      );
    } else if (index > doc - 1 && index < doc) {
      icon = Icon(
        Icons.star_half,
        color: Colors.amber,
        size: 30,
      );
    } else {
      icon = Icon(
        Icons.star,
        color: Colors.amber,
        size: 30,
      );
    }
    return icon;
  }
}
