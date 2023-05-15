class Doctor {
  String? firstName;
  String? lastName;
  String? image;
  String? type;
  double? rating;

  Doctor({
    this.firstName,
    this.lastName,
    this.image,
    this.type,
    this.rating,
  });
}

class DoctorModel {
  String? uid;
  String? name;
  String? gender;
  String? address;
  String? city;
  String? email;
  String? experience;
  String? specialist;
  String? password;
  String? description;
  String? age;
  String? phone;
  String? dob;
  String? rating;
  var available;
  var valid;
  var profileImage;
  var proof;

  DoctorModel({
    this.uid,
    this.name,
    this.gender,
    this.address,
    this.city,
    this.email,
    this.experience,
    this.specialist,
    this.password,
    this.description,
    this.dob,
    this.phone,
    this.rating,
    this.available,
    this.valid,
    this.age,
    this.proof,
    this.profileImage,
  });

//reciving data from server
  factory DoctorModel.fromMap(map) {
    return DoctorModel(
      uid: map['uid'],
      name: map['name'],
      gender: map['gender'],
      address: map['address'],
      city: map['city'],
      email: map['email'],
      experience: map['experience'],
      specialist: map['specialist'],
      password: map['password'],
      description: map['description'],
      phone: map['phone'],
      profileImage: map['profileImage'],
      proof:map['proof'],
      age:map['age'],
      dob:map['dob'],
      rating: map['rating'],
      available: map['available'],
      valid: map['valid'],
    );
  }




//sending data to our server
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'gender': gender,
      'address': address,
      'city': city,
      'email': email,
      'experience': experience,
      'specialist': specialist,
      'password': password,
      'description': description,
      'age':age,
      'dob':dob,
      'proof':proof,
      'phone': phone,
      'profileImage': profileImage,
      'rating': rating,
      'available': available,
      'valid':valid,
    };
  }
}
