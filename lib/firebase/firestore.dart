import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:job_task/main.dart';

fireStoreCreateUser() {
  if (globalUser?.email == null || globalUser!.email!.isEmpty) {
    print("Error: User email is missing!");
    return;
  }

  FirebaseFirestore.instance
      .collection('users')
      .doc(globalUser?.email)
      .set({
        'firstName': globalUser?.firstName,
        'lastName': globalUser?.lastName,
        'email': globalUser?.email,
        'dateOfBirth': globalUser?.dateOfBirth,
        'gender': globalUser?.gender,
        'country': globalUser?.country,
        'isSignIn': globalUser?.isSignIn,
        'login': globalUser?.login,
        'profilePictureLink': globalUser?.profilePictureLink,
      })
      .then((_) => print("User Added to Firestore"))
      .catchError((error) => print("Failed to add user: $error"));
}

fireStoreReadUser() {
  if (globalUser?.email == null || globalUser!.email!.isEmpty) {
    print("Error: User email is missing!");
    return;
  }
  print(globalUser!.email);
  FirebaseFirestore.instance
      .collection('users')
      .doc(globalUser?.email)
      .get()
      .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          Map<String, dynamic> data =
              documentSnapshot.data() as Map<String, dynamic>;

          globalUser?.setAll(
            firstName: data['firstName'],
            lastName: data['lastName'],
            email: data['email'],
            dateOfBirth: data['dateOfBirth'],
            gender: data['gender'],
            country: data['country'],
            isSignIn: data['isSignIn'],
            login: data['login'],
            profilePictureLink: data['profilePictureLink'],
          );

          print('User Data Fetched: ${data['firstName']} ${data['lastName']}');
        } else {
          print('User not found in Firestore');
        }
      })
      .catchError((error) => print("Failed to read user: $error"));
}

Future<bool> fireStoreCheckUserExists() async {
  if (globalUser?.email == null || globalUser!.email!.isEmpty) {
    print("Error: User email is missing!");
    return false;
  }

  try {
    DocumentSnapshot documentSnapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(globalUser!.email)
            .get();

    if (documentSnapshot.exists) {
      print("User exists in Firestore.");
       Map<String, dynamic> data =
          documentSnapshot.data() as Map<String, dynamic>;

      globalUser?.setAll(
        firstName: data['firstName'],
        lastName: data['lastName'],
        email: globalUser!.email,
        dateOfBirth: data['dateOfBirth'],
        gender: data['gender'],
        country: data['country'],
        isSignIn: data['isSignIn'],
        login: data['login'],
        profilePictureLink: data['profilePictureLink'],
      );
      return true;
    } else {
      print("User does not exist in Firestore.");
      return false;
    }
  } catch (error) {
    print("Error checking user existence: $error");
    return false;
  }
}

fireStoreUpdateUser() async {
  if (globalUser?.email == null || globalUser!.email!.isEmpty) {
    print("Error: User email is missing!");
    return;
  }

  try {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(globalUser!.email)
        .update({
          'firstName': globalUser?.firstName,
          'lastName': globalUser?.lastName,
          'dateOfBirth': globalUser?.dateOfBirth,
          'gender': globalUser?.gender,
          'country': globalUser?.country,
        });

    print("User Profile Updated in Firestore");
  } catch (error) {
    print("Failed to update user: $error");
  }
}
