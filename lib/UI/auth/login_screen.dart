import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../Utils/utils.dart';
import '../../homePage.dart';
import '../../widgets/round_button.dart';
import '../forgot_password.dart';
import 'package:permission_handler/permission_handler.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  bool loading = false ;
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final _auth = FirebaseAuth.instance ;
  @override
  void initState() {
    Permission.microphone.request();
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();

  }

  void login(){
    setState(() {
      loading = true ;
    });
    _auth.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text.toString()).then((value){
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => HomePage())
      );
      setState(() {
        loading = false ;
      });
    }).onError((error, stackTrace){
      setState(() {
        loading = false ;
      });
      if (error is FirebaseAuthException) {
        String message = "";
        switch (error.code) {
          case "invalid-email":
            message = "The email address is badly formatted.";
            break;
          case "user-not-found":
            message = "There is no user record corresponding to this email.";
            break;
          case "wrong-password":
            message = "The password is invalid.";
            break;
          default:
            message = "An undefined error occurred.";
        }
        Utils().toastMessage(message);
      } else {
        debugPrint(error.toString());
        Utils().toastMessage(error.toString());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async{
        SystemNavigator.pop();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Login'),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        controller: emailController,
                        decoration: const  InputDecoration(
                            hintText: 'Email',
                            prefixIcon: Icon(Icons.alternate_email)
                        ),
                        validator: (value){
                          if(value!.isEmpty){
                            return 'Enter email';
                          }
                          return null ;
                        },
                      ),
                      const SizedBox(height: 10,),
                      TextFormField(
                        keyboardType: TextInputType.text,
                        controller: passwordController,
                        obscureText: true,
                        decoration: const  InputDecoration(
                            hintText: 'Password',
                            prefixIcon: Icon(Icons.lock_open)
                        ),
                        validator: (value){
                          if(value!.isEmpty){
                            return 'Enter password';
                          }
                          return null ;
                        },
                      ),

                    ],
                  )
              ),
              const SizedBox(height: 50,),
              RoundButton(
                title: 'Login',
                loading: loading,
                onTap: (){
                  if(_formKey.currentState!.validate()){
                    login();
                  }
                },
              ),
              TextButton(onPressed: (){
                Navigator.push(context,
                    MaterialPageRoute(
                        builder:(context) => ForgotPasswordScreen())
                );
              },
                  child: Text('Forgot Password?')),
            ],
          ),
        ),
      ),
    );
  }
}
