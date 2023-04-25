import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:preconsult_app/chatfetch.dart';
import 'package:preconsult_app/user_search_page.dart';
import 'UI/auth/login_screen.dart';
import 'UI/post_screen/mainscreen.dart';
import 'Utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{
  final FirebaseAuth auth = FirebaseAuth.instance;
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final userEmail= FirebaseAuth.instance.currentUser!.email;
  @override
  void initState(){
    super.initState();
    userDoc();


  }
  void userDoc()async{
    FirebaseFirestore.instance.collection('preConsult').doc(userId).snapshots().listen((snapshot){
      if (!snapshot.exists)
      {
        FirebaseFirestore.instance.collection('preConsult').doc(userId).set(
            {'id': userId});
        FirebaseFirestore.instance.collection('preConsult').doc(userId).update(
            {'email': userEmail});
      }
    });


  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double itemWidth = size.width * 0.45;
    final double itemHeight = size.height * 0.2;

    return WillPopScope(
        onWillPop: () async {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Confirm Logout'),
                content: Text('Are you sure you want to logout?'),
                actions: <Widget>[
                  TextButton(
                    child: Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                  ),
                  TextButton(
                    child: Text('Logout'),
                    onPressed: () {
                      auth.signOut().then((value) {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginScreen()));
                      }).onError((error, stackTrace) {
                        Utils().toastMessage(error.toString());
                      });
                    },
                  ),
                ],
              );
            },
          );
          return false;
        },
        child: Scaffold(
          appBar: AppBar(automaticallyImplyLeading: false,
            title: const Text('PRE-CONSULT TAB'),
            actions: [
              IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Confirm Logout'),
                        content: const Text('Are you sure you want to logout?'),
                        actions: <Widget>[
                          TextButton(
                            child: Text('Cancel'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: Text('Logout'),
                            onPressed: () {
                              auth.signOut().then((value) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => LoginScreen()));
                              }).onError((error, stackTrace) {
                                Utils().toastMessage(error.toString());
                              });
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: Icon(Icons.logout),
              ),
              const SizedBox(
                width: 10,
              )
            ],
          ),
          body: SingleChildScrollView(
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  const SizedBox(height: 25,),
                  Center(
                    child: CarouselSlider(
                      items: [
                        Image.asset('assets/jan.png'),
                        Image.asset('assets/axilogo.png'),
                        Image.asset('assets/iyon.jpg'),
                        Image.asset('assets/medongo.png'),
                      ],
                      options: CarouselOptions(
                        autoPlay: true,
                        enlargeCenterPage: true,
                        aspectRatio: 2.1,
                        viewportFraction: 0.89,
                        onPageChanged: (index, reason) {
                        },
                      ),
                    ),
                  ),
                  Divider(thickness: 1,),
                  const SizedBox(height: 45,),

                  Center(
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        SizedBox(
                          width: itemWidth,
                          height: itemHeight,
                          child: Material(
                            color: Colors.white,
                            elevation: 4,
                            borderRadius: BorderRadius.circular(16),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) => ChatFetch())
                                );
                              },
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,

                                  children: [
                                    Container(
                                      height: 100,
                                      width: 100,
                                      color: Colors.white,
                                      child: Image.asset(
                                        'assets/112454-form-registration.gif',
                                        repeat: ImageRepeat.noRepeat,
                                      ),
                                    ),
                                    SizedBox(height: 10,),
                                    Text('Patient Registration',
                                      style: TextStyle(
                                          color:Colors.black54,
                                          fontWeight: FontWeight.lerp(FontWeight.w600, FontWeight.bold, 7),fontSize:20 ),
                                      textAlign: TextAlign.center,),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: itemWidth,
                          height: itemHeight,
                          child: Material(
                            color: Colors.white,
                            elevation: 4,
                            borderRadius: BorderRadius.circular(16),
                            child: InkWell(
                              onTap: () {
                                DateTime now=DateTime.now();
                                String formattedDateTime= DateFormat('dd-MM-yyyy').format(now);
                                String timestamp=formattedDateTime;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SearchBarScreen(timestamp: timestamp,),
                                  ),
                                );
                              },
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 100,
                                      width: 100,
                                      color: Colors.white,
                                      child: Image.asset(
                                        'assets/95434-history.gif',
                                        repeat: ImageRepeat.noRepeat,
                                      ),
                                    ),
                                    SizedBox(height: 10,),
                                    Text("Today's Consultation",style: TextStyle(color:Colors.black54,fontWeight: FontWeight.lerp(FontWeight.w600, FontWeight.bold, 7),fontSize:20 ),textAlign: TextAlign.center,),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: itemWidth,
                          height: itemHeight,
                          child: Material(
                            color: Colors.white,
                            elevation: 4,
                            borderRadius: BorderRadius.circular(16),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) => SearchBarScreen())
                                );
                              },
                              child: Center(

                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 100,
                                      width: 100,
                                      color: Colors.white,
                                      child: Image.asset(
                                        'assets/114398-no-transaction-history.gif',
                                        repeat: ImageRepeat.noRepeat,
                                      ),
                                    ),
                                    SizedBox(height: 10,),

                                    Text('Consultations',style: TextStyle(color:Colors.black54,fontWeight: FontWeight.lerp(FontWeight.w600, FontWeight.bold, 7),fontSize:20 ),textAlign: TextAlign.center,),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: itemWidth,
                          height: itemHeight,
                          child: Material(
                            color: Colors.white,
                            elevation: 4,
                            borderRadius: BorderRadius.circular(16),
                            child: InkWell(
                              onTap: () {
                                Navigator.pushNamed(context, '/settings');
                              },
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 100,
                                      width: 100,
                                      color: Colors.white,
                                      child: Image.asset(
                                        'assets/114427-attendance-loader.gif',
                                        repeat: ImageRepeat.noRepeat,
                                      ),
                                    ),
                                    SizedBox(height: 10,),
                                    Text('Attendance',style: TextStyle(color:Colors.black54,fontWeight: FontWeight.lerp(FontWeight.w600, FontWeight.bold, 7),fontSize:20 ),textAlign: TextAlign.center,),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}