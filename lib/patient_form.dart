import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'homePage.dart';

class PatientForm extends StatefulWidget {
  final String easyid;
  final Map<String, dynamic>? patient;
  PatientForm({Key? key ,required this.easyid,this.patient}):super(key: key);

  @override
  State<PatientForm> createState() => _PatientFormState();

}
class _PatientFormState extends State<PatientForm>{
  String name = '';
  String ageYear = '';
  String ageMonth = '';
  String gender = '';
  String mobileNumber = '';
  String image = '';
  String easyid = '';
  List<dynamic> qAns = [];
  String? timestamp;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchForm();
  }


  Future<void> fetchForm() async{
    if(widget.patient==null) {
      FirebaseFirestore.instance.collection('preConsult').doc(userId)
          .collection('patientData')
          .doc(widget.easyid)
          .get()
          .then((DocumentSnapshot documentSnapshot) async {
        if (documentSnapshot.exists) {
// Cast the value to a Map<String, dynamic> type
          Map<String, dynamic> data =
          documentSnapshot.data() as Map<String, dynamic>;
// Access the fields using their keys
          if (data['questionnaireAnswers'] != null) {
            setState(() {
              name = data['name'];
              ageYear = data['age(year)'];
              ageMonth = data['age(month)'];
              gender = data['gender'];
              mobileNumber = data['mobile_number'];
              image = data['image'];
              qAns = data['questionnaireAnswers'];
            });
          }
          else {
            setState(() {
              name = data['name'];
              ageYear = data['age(year)'];
              ageMonth = data['age(month)'];
              gender = data['gender'];
              mobileNumber = data['mobile_number'];
              image = data['image'];
              easyid = data['easyid'];
            });
          }
        } else {
          print('Document does not exist on the database');
        }
      }).catchError((error) {
        print('Error fetching document: $error');
      });
    }
    else{
      setState(() {
        name = widget.patient!['name'];
        ageYear = widget.patient!['age(year)'];
        ageMonth = widget.patient!['age(month)'];
        gender = widget.patient!['gender'];
        mobileNumber = widget.patient!['mobile_number'];
        image = widget.patient!['image'];
        qAns = widget.patient!['questionnaireAnswers'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
        return false;
      },
      child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text(
              'PATIENT FORM',
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                widget.patient!=null?Navigator.pop(context):
                Navigator.push(context, MaterialPageRoute(builder: (context) =>HomePage()));
              },
            ),
          ),

          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Center(
                      child: Text(
                        "Patient Details",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10, left: 10, bottom: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(image),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text("Name : ",
                                      style: TextStyle(fontWeight: FontWeight.w500)),
                                  Text(name),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Text("Age : ",
                                      style: TextStyle(fontWeight: FontWeight.w500)),
                                  Text("${ageYear}.${ageMonth} years"),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Text("Gender : ",
                                      style: TextStyle(fontWeight: FontWeight.w500)),
                                  Text(gender),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Text("Mobile Number : ",
                                      style: TextStyle(fontWeight: FontWeight.w500)),
                                  Text(mobileNumber),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Center(
                      child: Text(
                        "Questionnaire",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: qAns.length,
                    itemBuilder: (context, index) {
                      final question = "Ques. ${qAns[index]['question']}";
                      final answer = "Ans. ${qAns[index]['answer']}";
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              question,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(answer),
                            const SizedBox(height: 8),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          )),
    );
  }

}