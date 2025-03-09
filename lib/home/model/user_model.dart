class UserModel {
  // Personal Details
  String firstName;
  String lastName;
  String email;
  String dateOfBirth;
  String gender;
  String country;

  // Authentication and Profile
  bool isSignIn;
  String login;
  String profilePictureLink;

  UserModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.dateOfBirth,
    required this.gender,
    required this.country,
    required this.isSignIn,
    required this.login,
    required this.profilePictureLink,
  });

  // Getters
  String getFirstName() => firstName;
  String getLastName() => lastName;
  String getEmail() => email;
  String getDateOfBirth() => dateOfBirth;
  String getGender() => gender;
  String getCountry() => country;
  bool getIsSignIn() => isSignIn;
  String getLogin() => login;
  String getProfilePictureLink() => profilePictureLink;

  // Setters
  void setFirstName(String firstName) => this.firstName = firstName;
  void setLastName(String lastName) => this.lastName = lastName;
  void setEmail(String email) => this.email = email;
  void setDateOfBirth(String dateOfBirth) => this.dateOfBirth = dateOfBirth;
  void setGender(String gender) => this.gender = gender;
  void setCountry(String country) => this.country = country;
  void setIsSignIn(bool isSignIn) => this.isSignIn = isSignIn;
  void setLogin(String login) => this.login = login;
  void setProfilePictureLink(String profilePictureLink) =>
      this.profilePictureLink = profilePictureLink;

  // Set all fields at once
  void setAll({
    required String firstName,
    required String lastName,
    required String email,
    required String dateOfBirth,
    required String gender,
    required String country,
    required bool isSignIn,
    required String login,
    required String profilePictureLink,
  }) {
    this.firstName = firstName;
    this.lastName = lastName;
    this.email = email;
    this.dateOfBirth = dateOfBirth;
    this.gender = gender;
    this.country = country;
    this.isSignIn = isSignIn;
    this.login = login;
    this.profilePictureLink = profilePictureLink;
  }

  // Convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'country': country,
      'isSignIn': isSignIn,
      'login': login,
      'profilePictureLink': profilePictureLink,
    };
  }

  // Create UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      dateOfBirth: json['dateOfBirth'] ?? '',
      gender: json['gender'] ?? '',
      country: json['country'] ?? '',
      isSignIn: json['isSignIn'] ?? false,
      login: json['login'] ?? '',
      profilePictureLink: json['profilePictureLink'] ?? '',
    );
  }

  void resetUser() {
    firstName = '';
    lastName = '';
    email = '';
    dateOfBirth = '';
    gender = '';
    country = '';
    isSignIn = false;
    login = '';
    profilePictureLink = '';
  }

}
