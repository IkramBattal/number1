import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:typicons_flutter/typicons_flutter.dart';
import '../Screens/detail_page.dart';

class SearchList extends StatefulWidget {
  final String searchKey;

  const SearchList({Key? key, required this.searchKey}) : super(key: key);

  @override
  _SearchListState createState() => _SearchListState();
}

class _SearchListState extends State<SearchList> {
  TextEditingController _doctorName = TextEditingController();
  final CollectionReference firebase =
      FirebaseFirestore.instance.collection('Sitter');
  var appointment = FirebaseFirestore.instance;
  var a='Mr  ';
  User? user = FirebaseAuth.instance.currentUser;

  bool isLoading = true;
  double rating = 0.0;

  get doc => null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: SafeArea(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('Sitter')
              .orderBy('name')
              .where('valid', isEqualTo: true)
              .startAt([widget.searchKey]).endAt(
                  [widget.searchKey + '\uf8ff']).snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData)
              return Center(
                child: CircularProgressIndicator(),
              );
            return snapshot.data!.size == 0
                ? Center(
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'No service provider found!',
                            style: TextStyle(
                              color:  Color(0xFF4CA6A8),
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Image(
                            image: AssetImage('assets/images/error-404.jpg'),
                            height: 250,
                            width: 250,
                          ),
                        ],
                      ),
                    ),
                  )
                : Scrollbar(
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      physics: ClampingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: snapshot.data!.size,
                      itemBuilder: (context, index) {
                        DocumentSnapshot doctor = snapshot.data!.docs[index];
                        if (doctor['gender']=='female'){a='Ms.  ';}
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                          child: Card(
                            color:Color(0xFFF5F5F5),
                            elevation: 5,

                            child:Container(
                              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color:  Color(0xFF4CA6A8),
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Material(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DetailPage(
                                          uid: doctor['uid'],
                                          name: doctor['name'],
                                          email: doctor['email'],
                                          address: doctor['address'],
                                          city: doctor['city'],
                                          experience: doctor['experience'],
                                          specialist: doctor['specialist'],
                                          profileImage: doctor['profileImage'],
                                          description: doctor['description'],
                                          phone: doctor['phone'],
                                          gender: doctor['gender'],
                                          available: doctor['available'],
                                          doctor: _doctorName,
                                        ),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(10),
                                  child: Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        doctor['profileImage'] == false
                                            ? CircleAvatar(
                                          backgroundImage: AssetImage('assets/images/account.png'),
                                          backgroundColor: Colors.transparent,
                                          radius: 25,
                                        )
                                            : CircleAvatar(
                                          backgroundImage: NetworkImage(doctor['profileImage']),
                                          backgroundColor: Colors.transparent,
                                          radius: 25,
                                        ),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                a + doctor['name'],
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 17,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              Text(
                                                doctor['specialist'] + ' Specialist',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Icon(
                                              Typicons.star_full_outline,
                                              size: 20,
                                              color: Colors.yellow[400],
                                            ),
                                            SizedBox(width: 3),
                                            Text(
                                              doctor['rating'].toString(),
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),


                          ),
                        );
                      },
                    ),
                  );
          },
        ),
      ),
    );
  }
}
