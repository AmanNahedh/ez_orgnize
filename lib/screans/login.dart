import 'package:ez_orgnize/General/Text_Filled.dart';
import 'package:ez_orgnize/General/buttons.dart';
import 'package:ez_orgnize/fire_base/Cheak.dart';
import 'package:ez_orgnize/screans/register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'Forget_pass.dart';

class LogIn extends StatefulWidget {
final Function()? onPressed;
const LogIn({super.key,required this.onPressed});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  // text editing controllers
  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  // sign user in method
  void logIn() async {
    //Loading
    showDialog(
      context: context,
      builder: (context) {
        return const Center(child: CircularProgressIndicator());
      }, //builder
    ); //showDialog

    //sign in
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);
      print('doneeeee');
      //finish
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const cheak(),
        ),
      );
    } on FirebaseAuthException catch (a) {
      print('Failed with error code: ${a.code}');
      print(a.message);
      //finish
      Navigator.pop(context);
      if (a.code == 'INVALID_LOGIN_CREDENTIALS') {
        wrongInfo(context);
      }
    }
  }

  void wrongInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          title: Text('Wrong Email or Password'),
        );
      },
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 100,
                ),

                //Company logo
                const Icon(
                  color: Colors.teal,
                  Icons.lock,
                  size: 100,
                ),
                const SizedBox(
                  height: 25,
                ),

                // login massage
                const Text(
                  "Sign IN !",
                  style: TextStyle(
                    color: Colors.teal,
                    fontSize: 36,
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
                //email
                Text_Filled(
                  controller: emailController,
                  hintText: 'Please Enter Email',
                  obscureText: false,
                ),
                const SizedBox(
                  height: 25,
                ),
                //pass
                Text_Filled(
                  controller: passwordController,
                  hintText: 'Please Enter Password',
                  obscureText: true,
                ),
                const SizedBox(
                  height: 12,
                ),
                //forget pass
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context, MaterialPageRoute(
                              builder: (context) {
                                return Forget_pass(onPressed: () {  },);

                                //error
                              }
                          )
                          );
                        },
                        child: const Text(
                          'Forgot Password?',
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),
                //sign in button
                button(
                  text: "Sign In",
                  onPressed: logIn,
                ),
                const SizedBox(height: 20),
                //not member
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Not a member?',
                    ),
                    const SizedBox(width: 4),
                    TextButton(
                      onPressed: () =>
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const Register(),
                            ),
                          ),
                      child: const Text('Register now'),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
