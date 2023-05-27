import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Rating_Review extends StatefulWidget {
  var did;

  Rating_Review({required this.did});

  @override
  State<Rating_Review> createState() => _Rating_ReviewState();
}

class _Rating_ReviewState extends State<Rating_Review> {
  var appointment = FirebaseFirestore.instance;

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor:Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xFFF5F5F5),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            size: 20,
            color:Color(0xFF4CA6A8),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Rating & Review',
          style: TextStyle(
              color: Color(0xFF4CA6A8), fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            child: StreamBuilder<QuerySnapshot>(
                stream: appointment
                    .collection('Sitter/' + widget.did + '/rating')
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return new Text("There is no expense");
                  } else {
                    return ListView.builder(
                      shrinkWrap: true,
                      // shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      itemCount: snapshot.data?.docs.length,
                      itemBuilder: (BuildContext context, int index) {
                        final DocumentSnapshot doc = snapshot.data!.docs[index];
                        return SingleChildScrollView(
                          child: Container(
                            margin: EdgeInsets.only(bottom: 5),
                            decoration: BoxDecoration(
                              color: Color(0xFFFFFFFF),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      margin: EdgeInsets.only(top: 5),
                                      child: Text(
                                        doc['name'],
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                            fontSize: 18),
                                      )),
                                  Row(
                                      children: new List.generate(
                                          5,
                                          (index) => buildStar(context, index,
                                              double.parse(doc['rating_s'])))),
                                  Container(
                                      margin: EdgeInsets.only(top: 5),
                                      child: Text(
                                        doc['review'],
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black38),
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
