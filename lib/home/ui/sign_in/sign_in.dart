import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:job_task/firebase/firestore.dart';
import 'package:job_task/home/ui/home/home.dart';
import 'package:job_task/home/ui/sign_in/register.dart';
import 'package:job_task/home/ui/sign_in/componenets/custom_button.dart' as custom_button;
import 'package:job_task/home/ui/sign_in/componenets/cutom_textfeild.dart';
import 'package:job_task/home/ui/sign_in/componenets/password_reset_modal.dart';
import 'package:job_task/main.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isSigningIn = false;
  bool _isGoogleSigningIn = false;
  bool _isFacebookSigningIn = false;
  String? _errorMessage;

  Future<UserCredential?> _signIn() async {
    setState(() {
      _isSigningIn = true;
      _errorMessage = null;
    });

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      _navigateToHome();
      return credential;
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage =
            e.code == 'user-not-found'
                ? 'No user found for that email.'
                : e.code == 'wrong-password'
                ? 'Incorrect password.'
                : 'Sign in failed. Please try again.';
      });
    } catch (e) {
      setState(() => _errorMessage = 'An unexpected error occurred.');
      print("Email/password sign-in error: $e");
    } finally {
      setState(() => _isSigningIn = false);
    }
    return null;
  }

  Future<UserCredential?> _signInWithGoogle() async {
    setState(() {
      _isGoogleSigningIn = true;
      _errorMessage = null;
    });

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        setState(() => _errorMessage = 'Google sign-in was cancelled.');
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.idToken == null) {
        setState(
          () => _errorMessage = 'Failed to get Google authentication tokens.',
        );
        return null;
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      _handleSocialSignIn(
        googleUser.email,
        "google",
        googleUser.photoUrl,
        googleUser.displayName,
      );

      return userCredential;
    } catch (e) {
      print("Google sign-in error: $e");
      setState(() => _errorMessage = 'Google sign-in failed. Try again.');
      return null;
    } finally {
      setState(() => _isGoogleSigningIn = false);
    }
  }

  Future<UserCredential?> _signInWithFacebook() async {
    setState(() {
      _isFacebookSigningIn = true;
      _errorMessage = null;
    });

    try {
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        final String? token = result.accessToken?.tokenString;

        if (token == null) {
          setState(
            () => _errorMessage = 'Failed to get Facebook access token.',
          );
          return null;
        }

        final credential = FacebookAuthProvider.credential(token);
        final userCredential = await FirebaseAuth.instance.signInWithCredential(
          credential,
        );

        var profile = userCredential.additionalUserInfo?.profile;
        _handleSocialSignIn(
          profile?['email'],
          "facebook",
          profile?['picture']?['data']?['url'],
          "${profile?['first_name'] ?? ''} ${profile?['last_name'] ?? ''}",
        );

        return userCredential;
      } else if (result.status == LoginStatus.cancelled) {
        setState(() => _errorMessage = 'Facebook login cancelled.');
      } else {
        setState(
          () => _errorMessage = 'Facebook login failed: ${result.message}',
        );
      }
      return null;
    } catch (e) {
      print("Facebook sign-in error: $e");

      if (e.toString().contains('PigeonUserDetails')) {
        setState(
          () =>
              _errorMessage =
                  'Facebook login plugin error. Try updating the app.',
        );
      } else {
        setState(
          () => _errorMessage = 'Facebook sign-in failed. Please try again.',
        );
      }
      return null;
    } finally {
      setState(() => _isFacebookSigningIn = false);
    }
  }

  Future<void> _handleSocialSignIn(
    String? email,
    String loginType,
    String? photoUrl,
    String? displayName,
  ) async {
    globalUser?.setEmail(email!);
    var isExist = await fireStoreCheckUserExists();

    if (isExist == false) {
      globalUser?.setIsSignIn(true);
      globalUser?.setLogin(loginType);

      if (photoUrl != null) {
        globalUser?.setProfilePictureLink(photoUrl);
      }

      if (displayName != null) {
        List<String> nameParts = displayName.trim().split(" ");
        globalUser?.setFirstName(nameParts.isNotEmpty ? nameParts[0] : "");
        globalUser?.setLastName(
          nameParts.length > 1 ? nameParts.sublist(1).join(" ") : "",
        );
      }

      if (loginType == "facebook") {
        await fireStoreCreateUser();
      }

      _navigateToSignUp();
    } else {
      if (loginType == "facebook") {
        await fireStoreReadUser();
      }
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) =>  HomeScreen()),
    );
  }

  void _navigateToSignUp() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignUpScreen()),
    );
  }

  void _showPasswordResetModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => const PasswordResetDialog(),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Login',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text(
                'Welcome Back',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              CustomTextField(label: 'Email', controller: _emailController),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Password',
                controller: _passwordController,
                obscureText: true,
              ),
              const SizedBox(height: 16),
              if (_errorMessage != null) ErrorMessage(message: _errorMessage!),
              custom_button.AuthButton(
                text: 'Sign In',
                isLoading: _isSigningIn,
                onPressed: () {
                  if (_emailController.text.isEmpty ||
                      _passwordController.text.isEmpty) {
                    setState(
                      () => _errorMessage = 'Please enter email and password.',
                    );
                  } else {
                    _signIn();
                  }
                },
              ),
              const SizedBox(height: 16),
              custom_button.AuthButton(
                text: 'Forgot Password',
                backgroundColor: Colors.grey.shade300,
                textColor: Colors.black,
                onPressed: _showPasswordResetModal,
              ),
              const SizedBox(height: 16),
              custom_button.AuthButton(
                text: 'Create Account',
                outlined: true,
                onPressed: _navigateToSignUp,
              ),
              const SizedBox(height: 24),
              const DividerWithText(text: "OR"),
              const SizedBox(height: 24),
              custom_button.SocialAuthButton(
                text: 'Continue with Facebook',
                icon: Icons.facebook,
                backgroundColor: Colors.blue.shade800,
                isLoading: _isFacebookSigningIn,
                onPressed: _signInWithFacebook,
              ),
              const SizedBox(height: 16),
              custom_button.SocialAuthButton(
                text: 'Continue with Google',
                icon: Icons.g_mobiledata,
                backgroundColor: Colors.white,
                textColor: Colors.black,
                iconColor: Colors.black,
                outlined: true,
                isLoading: _isGoogleSigningIn,
                onPressed: _signInWithGoogle,
              ),
              const SizedBox(height: 16),
              custom_button.SocialAuthButton(
                text: 'Continue with Apple',
                icon: Icons.apple,
                backgroundColor: Colors.blueGrey,
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class ErrorMessage extends StatelessWidget {
  final String message;

  const ErrorMessage({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        message,
        style: const TextStyle(color: Colors.red, fontSize: 14),
        textAlign: TextAlign.center,
      ),
    );
  }
} 


class DividerWithText extends StatelessWidget {
  final String text;

  const DividerWithText({
    Key? key,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(text),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}