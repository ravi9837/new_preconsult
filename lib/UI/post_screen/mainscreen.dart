import 'dart:io';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import '../../Utils/utils.dart';
import '../../chatfetch.dart';
import '../../widgets/round_button.dart';
import 'package:intl/intl.dart';

class PostScreen extends StatefulWidget {
  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final userId = FirebaseAuth.instance.currentUser!.uid;
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  final firestore = FirebaseFirestore.instance.collection('preConsult');
  final _formKey = GlobalKey<FormState>();

  bool loading = false;
  final ref = FirebaseDatabase.instance.ref('Post');

  final nameController = TextEditingController();
  String genderText = "male";
  String easyid = '';

  //var ageText = TextEditingController();
  var yearController = TextEditingController();
  var monthController = TextEditingController();
  var mobilenumbercontroller = TextEditingController();
  var mothersnamecontroller = TextEditingController();
  String? timestamp;
  String? fullTimestamp;
  final ScrollController _scrollController = ScrollController();

  File _image = File('');
  final ImagePicker picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 18,
        preferredCameraDevice: CameraDevice.rear);
    _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: Duration(milliseconds: 1), curve: Curves.easeInOut);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Padding(
            padding: EdgeInsets.only(left: 38),
            child: (Text('Patient Registration')),
          ),
          backgroundColor: Colors.green,
        ),
        body: SingleChildScrollView(
          controller: _scrollController,
          child: Form(
              key: _formKey,
              child: Column(children: [
                Column(mainAxisAlignment: MainAxisAlignment.center, children: <
                    Widget>[
                  Container(
                    margin: const EdgeInsets.only(bottom: 15),
                  ),
                  CircleAvatar(
                    radius: 100,
                    foregroundImage: Image.file(_image).image,

                    backgroundColor: Colors.grey.shade200,
                    child: const Icon(
                      Icons.person,
                      size: 180,
                      color: Colors.white,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10,right: 10,top:5
                        ),
                    child: Center(
                      child: ElevatedButton(
                        onPressed: () {
                          getImage();
                        },
                        child: const Text(
                          'Capture Image',
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                           left: 15,right: 15,top:5,bottom:5),
                        child: TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            label: Text('Enter your name'),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 15),
                              child: TextFormField(
                                controller: yearController,
                                decoration: const InputDecoration(
                                  label: Text('Enter age (years)'),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter your age in years';
                                  }
                                  if (int.tryParse(value) == null ||
                                      int.parse(value) < 0) {
                                    return 'Please enter a valid age in years';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 15),
                              child: TextFormField(
                                controller: monthController,
                                decoration: const InputDecoration(
                                  label: Text('Enter age (month)'),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter your age in month';
                                  }
                                  if (int.tryParse(value) == null ||
                                      int.parse(value) > 12) {
                                    return 'Please enter a valid age in month';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        child: TextFormField(
                          controller: mobilenumbercontroller,
                          decoration: const InputDecoration(
                            label: Text('Enter your Mobile number'),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your mobile number';
                            }
                            if (value.length < 10) {
                              return 'Please enter a 10-digit mobile number';
                            }
                            return null;
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        child: TextFormField(
                          controller: mothersnamecontroller,
                          decoration: const InputDecoration(
                            label: Text("Patient's mother name"),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Please enter your mother's name";
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 20.0, horizontal: 10),
                        child: DropdownButtonFormField(
                          decoration: InputDecoration(
                            labelText: 'Gender',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          value: genderText,
                          onChanged: (value) {
                            setState(() {
                              genderText = value.toString();
                            });
                          },
                          items: const [
                            DropdownMenuItem(
                              value: 'male',
                              child: Text('Male'),
                            ),
                            DropdownMenuItem(
                              value: 'female',
                              child: Text('Female'),
                            ),
                            DropdownMenuItem(
                              value: 'other',
                              child: Text('Other'),
                            ),
                          ],
                        ),
                      ),
                      Row(children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 10.0,right: 10.0,bottom: 10.0),
                            child: RoundButton(
                              title: 'Submit',
                              loading: loading,
                              onTap: () async {
                                if (nameController.text.isEmpty ||
                                    mobilenumbercontroller.text.isEmpty ||
                                    monthController.text.isEmpty ||
                                    yearController.text.isEmpty ||
                                    genderText.isEmpty ||
                                    mothersnamecontroller.text.isEmpty) {
                                  Utils().showAlertDialog(context, 'Error',
                                      'Please fill all the fields');
                                  setState(() {
                                    loading = false;
                                  });
                                  return;
                                }
                                if (!_image.isAbsolute) {
                                  Utils().showAlertDialog(context, 'Error',
                                      'Please capture the image');
                                  return;
                                }

                                setState(() {
                                  loading = true;
                                });

                                try {
                                  firebase_storage.Reference ref =
                                      firebase_storage.FirebaseStorage.instance
                                          .ref('/images/${DateTime.now()
                                                  .millisecondsSinceEpoch}');
                                  firebase_storage.UploadTask uploadTask =
                                      ref.putFile(_image.absolute);

                                  var snapshot =
                                      await uploadTask.whenComplete(() {});
                                  var newUrl = await ref.getDownloadURL();

                                  if (_formKey.currentState!.validate()) {
                                    DateTime now = DateTime.now();
                                    String formattedDate =
                                        DateFormat('dd-MM-yyyy').format(now);
                                    String formattedDateTime =
                                        DateFormat('dd-MM-yyyy hh.mm.ss')
                                            .format(now);
                                    timestamp = formattedDate;
                                    fullTimestamp = formattedDateTime;
                                    final easyid = nameController.text
                                            .toString()
                                            .toLowerCase()
                                            .replaceAll(' ', '') +
                                        mobilenumbercontroller.text.toString();
                                    await firestore
                                        .doc(userId)
                                        .collection('patientData')
                                        .doc(easyid)
                                        .set({
                                      'gender': genderText.toString(),
                                      'age(month)':
                                          monthController.text.toString(),
                                      'age(year)':
                                          yearController.text.toString(),
                                      'name': nameController.text.toString(),
                                      'mobile_number': mobilenumbercontroller
                                          .text
                                          .toString(),
                                      'id': DateTime.now()
                                          .millisecondsSinceEpoch
                                          .toString(),
                                      'image': newUrl.toString(),
                                      'timestamp': timestamp,
                                      'fullTimestamp': fullTimestamp,
                                      'mothersname':
                                          mothersnamecontroller.text.toString(),
                                      'easyid': easyid
                                    });

                                    Utils().toastMessage(
                                        'Data Added Successfully');
                                    setState(() {
                                      loading = false;
                                    });
                                    // Navigator.push(
                                    //     context,
                                    //     MaterialPageRoute(
                                    //         builder: (context) => ChatFetch(
                                    //             mobile: mobilenumbercontroller.text,
                                    //             ageYear: yearController.text,
                                    //             ageMonth: monthController.text,
                                    //             gender: genderText,
                                    //             easyid: easyid)));
                                  }
                                } catch (error) {
                                  Utils().toastMessage(error.toString());
                                  setState(() {
                                    loading = false;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ]),
                    ],
                  ),
                ])
              ])),
        ));
  }
}
