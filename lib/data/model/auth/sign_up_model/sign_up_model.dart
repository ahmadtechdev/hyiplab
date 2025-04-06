class SignUpModel{
  final String firstName;
  final String lastName;
  // final String country;
  final String email;
  final String password;
  final String refference;
  final bool? agree;

  SignUpModel({
    required this.firstName,
    required this.lastName,
    // required this.country,
    required this.email,
    required this.password,
    this.refference="",
    required this.agree,
  });

  Map<String, dynamic> toMap() {
    return {
      'firstname': firstName,
      'lastname': lastName,
      // 'country': country,
      'email': email,
      'password': password,
      'password_confirmation':password,
      'reference':refference,
      'agree': agree.toString()=='true'?'true':'',
    };
  }

  factory SignUpModel.fromMap(Map<String, dynamic> map) {
    return SignUpModel(
      firstName: map['firstname'] as String,
      lastName: map['lastname'] as String,
      // country: map['country'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      refference: map['reference'] as String,
      agree: map['agree'] as bool,
    );
  }
}