import 'package:ecommerceapp/bottomNaviBar/bottomNavigationBar.dart';
import 'package:ecommerceapp/admin/AdminPanel.dart'; // Import AdminPanel
import 'package:ecommerceapp/registrationPage/userRegistration.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();
  bool _rememberMe = false; // Remember Me toggle state

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  // Load saved email and password if Remember Me was checked
  Future<void> _loadSavedCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _email.text = prefs.getString('email') ?? '';
      _password.text = prefs.getString('password') ?? '';
      _rememberMe = prefs.getBool('rememberMe') ?? false;
    });
  }

  // Save credentials if Remember Me is checked
  Future<void> _saveCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('email', _email.text);
      await prefs.setString('password', _password.text);
      await prefs.setBool('rememberMe', _rememberMe);
    } else {
      await prefs.remove('email');
      await prefs.remove('password');
      await prefs.remove('rememberMe');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.green[700],
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 150),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Text(
                    "Sign in",
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  height: MediaQuery.of(context).size.height - 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(20),
                          topLeft: Radius.circular(20))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Text(
                          "Welcome Back",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                              color: Colors.green[700]),
                        ),
                      ),
                      SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Text(
                          "Glad to see you back..",
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w200,
                              color: Colors.green[700]),
                        ),
                      ),
                      SizedBox(height: 40),
                      Padding(
                        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: Column(
                          children: [
                            TextField(
                              controller: _email,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.email),
                                  hintText: "Enter your email"),
                            ),
                            SizedBox(height: 10),
                            TextField(
                              controller: _password,
                              obscureText: true, // Hide password
                              keyboardType: TextInputType.visiblePassword,
                              decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.password),
                                  hintText: "Enter your password"),
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Checkbox(
                                      value: _rememberMe,
                                      onChanged: (value) {
                                        setState(() {
                                          _rememberMe = value ?? false;
                                        });
                                      },
                                      activeColor: Colors.green[700],
                                    ),
                                    Text("Remember Me")
                                  ],
                                ),
                                TextButton(
                                  onPressed: _resetPassword,
                                  child: Text(
                                    "Forgot Password?",
                                    style: TextStyle(
                                        color: Colors.green[700],
                                        fontWeight: FontWeight.bold),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 25),
                      Center(
                        child: Container(
                          width: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.green[700],
                          ),
                          child: RawMaterialButton(
                            onPressed: () async {
                              if (_email.text == "admin@gmail.com" &&
                                  _password.text == "admin123") {
                                // Navigate to AdminPanel
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (_) => AdminPanel()),
                                );
                              } else {
                                User? user = await _login(
                                    email: _email.text, pass: _password.text);
                                if (user != null) {
                                  await _saveCredentials();
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (_) => BottomNavigation(),
                                    ),
                                  );
                                }
                              }
                            },
                            child: Text(
                              "Login",
                              style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Don't have an account?"),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => UserRegistration()));
                            },
                            child: Text(
                              "Register here...",
                              style: TextStyle(color: Colors.green[700]),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<User?> _login({required String email, required String pass}) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;
    try {
      UserCredential userCredential =
          await auth.signInWithEmailAndPassword(email: email, password: pass);
      user = userCredential.user;
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Login failed")),
      );
    }
    return user;
  }

  // Reset Password
  void _resetPassword() async {
    if (_email.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter your email to reset password")),
      );
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _email.text);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Password reset email sent")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }
}
