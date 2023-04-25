import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//import 'package:preconsult_app/patient_form.dart';
import 'package:preconsult_app/widgets/round_button.dart';

class ChatFetch extends StatefulWidget {
  const ChatFetch({Key? key,}) : super(key: key);

  @override
  State<ChatFetch> createState() => _ChatFetchState();
}

class _ChatFetchState extends State<ChatFetch> {
  List flowData = [];
  int currentQuestionIndex = 0;
  List<Map<String, dynamic>> qaList = [];
  final TextEditingController controller = TextEditingController();
  final TextEditingController ageYearController = TextEditingController();
  final TextEditingController ageMonthController = TextEditingController();
  String finalText = '';
  int finalYearText = 0;
  int finalMonthText = 0;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final userId = FirebaseAuth.instance.currentUser!.uid;
  String dest = '';
  bool loading = false;
  String easyid='';
  String name='';
  String mobile='';
  String gender='';
  String age='';
  bool showProgressIndicator = false;
  int start=0;
  bool personal=true;
  final ScrollController _scrollController = ScrollController();


  @override
  void initState() {
    super.initState();
    showProgressIndicator = true;
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        showProgressIndicator = false;
      });
    });
    fetchQuestions();
  }





  Future<void> fetchQuestions() async {
    try {
      final docsSnapshot = await FirebaseFirestore.instance
          .collection("dash")
          .doc("info")
          .get();

      if (!docsSnapshot.exists) {
        print("Dashboard data does not exist in Firestore.");
        return;
      }
      final jsonMapOfQuestion = docsSnapshot.data() as Map<String, dynamic>;
      final elementListOfQuestion = jsonMapOfQuestion['elements'];
      final jsonDataOfInfo = json.encode(elementListOfQuestion);
      setState(() {
        flowData= json.decode(jsonDataOfInfo);
      });
    } catch (e) {
      print("Error loading dashboard from Firestore: $e");
    }
  }
  Future<void> fetchFlow() async {
    setState(() {
      loading = true;
      easyid = (name+mobile).toLowerCase().replaceAll(' ', '');
    });
    print("hahahahah");
    String dataKey;
    final age = (finalYearText + (finalMonthText / 12)).toString();
    double _age= double.tryParse(age) ?? 0;
    print("age");
    print(age);
    print("_age");
    print(_age);
    print(gender);
    print(easyid);
    if (_age < 0.3) {
      dataKey = 'NeoNatal';
    } else if (_age < 2 && _age >= 0.4) {
      dataKey = 'Toddler';
    } else if (_age < 13 && _age >= 3) {
      dataKey = 'Pediatric';
    } else if (_age < 18 && _age >= 12) {
      dataKey = 'Adolescent';
    } else if (_age < 31 && _age >= 18) {
      dataKey = 'Adult 18-30';
    } else if (_age < 41 && _age >= 31 && gender=='male') {
      dataKey = 'ADULT (31Y - 40Y) Male';
    } else if (_age < 41 && _age >= 31 && gender=='female') {
      dataKey = 'ADULT (31Y - 40Y) Female';
    } else if (_age < 61 && _age >= 41) {
      dataKey = 'Middle Age 41-60';
    } else if (_age < 71 && _age >= 61) {
      dataKey = 'Aged 61-70';
    } else if (_age < 86 && _age >= 71) {
      dataKey = 'Old Aged 71-85';
    } else {
      dataKey = 'Old Aged 85+';
    }
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection("dash")
          .doc(dataKey)
          .get();

      if (!docSnapshot.exists) {
        print("Dashboard data does not exist in Firestore.");
        return;
      }
      final jsonMap = docSnapshot.data() as Map<String, dynamic>;
      final elementList = jsonMap['elements'];
      final jsonData = json.encode(elementList);
      setState(() {
        flowData = json.decode(jsonData);
        loading = false;

      });
    } catch (e) {
      print("Error loading dashboard from Firestore: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'PATIENT TAB',
        ),
      ),
      body:showProgressIndicator
          ? Center(child: CircularProgressIndicator())
          : Column(
      children:[
        //...........................List View Builder...............................
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(9.0),
              child: ListView.builder(
                controller: _scrollController,
                shrinkWrap: true,
                reverse: false,
                itemCount: qaList.length,
                itemBuilder: (context, index) {
                  final question = qaList[index]['question'];
                  final answer = qaList[index]['answer'];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.7,
                          ),
                          margin: const EdgeInsets.only(bottom: 4, left: 4),
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Text(
                            question,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                                ),
                                margin: const EdgeInsets.only(left: 24, right: 4),
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.blue[100],
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                child: Text(
                                  answer,
                                  style: const TextStyle(fontSize: 18),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      String newAnswer = answer;
                                      return AlertDialog(
                                        title: Text('Edit Answer'),
                                        content: TextField(
                                          onChanged: (value) {
                                            newAnswer = value;
                                          },
                                          decoration: const InputDecoration(
                                            labelText: 'Answer',
                                            hintText: 'Enter new answer',
                                            border: OutlineInputBorder(),
                                          ),
                                          controller: TextEditingController(text: answer),
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            child: Text('Cancel'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          TextButton(
                                            child: Text('Save'),
                                            onPressed: () {
                                              setState(() {
                                                qaList[index]['answer'] = newAnswer;
                                              });
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: Icon(
                                  Icons.edit_note_outlined,
                                  size: 20,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              )

            ),
          ),
        ),
        //.......................................................................
      SizedBox(
        child: Padding(
          padding: const EdgeInsets.all(9.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 8, left: 4),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.blueGrey[50],
                ),
                child: Text(
                  flowData[currentQuestionIndex]["text"],
                  style: const TextStyle(fontSize: 17),
                ),
              ),
              if (flowData[currentQuestionIndex]["kind"] == 1) ...{
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.green,
                        ),
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              String question = flowData[currentQuestionIndex]["text"];
                              String answer = flowData[currentQuestionIndex]["text"] == 'Gender' ? "Male" : "Yes";
                              qaList.add({'question': question, 'answer': answer});
                              if (flowData[currentQuestionIndex]["text"] == 'Gender') {
                                gender = 'male';
                              }
                                if (flowData[currentQuestionIndex]["next"].length == 1) {
                                dest = flowData[currentQuestionIndex]["next"][0]["destElementId"];
                                int index = flowData
                                    .indexWhere((element) => element['id'] == dest);
                                dest = '';
                                currentQuestionIndex = index;
                              } else {
                                for (var i = 0; i < flowData[currentQuestionIndex]["next"].length; i++) {
                                  if (flowData[currentQuestionIndex]["next"][i]['arrowParams']
                                  ["startArrowPositionX"]
                                      .toString() ==
                                      '0' &&
                                      flowData[currentQuestionIndex]["next"][i]['arrowParams']
                                      ["endArrowPositionX"]
                                          .toString() ==
                                          '0') {
                                    dest = flowData[currentQuestionIndex]["next"][i]["destElementId"];
                                    break;
                                  }
                                }
                                int index = flowData
                                    .indexWhere((element) => element['id'] == dest);
                                dest = '';
                                currentQuestionIndex = index;
                              }
                            });
                          },
                          child: flowData[currentQuestionIndex]["text"] == 'Gender' ? const Text(
                            "Male",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ) : const Text(
                            "Yes",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(left: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.red,
                        ),
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              String question = flowData[currentQuestionIndex]["text"];
                              String answer = flowData[currentQuestionIndex]["text"] == 'Gender'?"Female":"No";
                              if (flowData[currentQuestionIndex]["text"] == 'Gender') {
                                gender = 'female';
                              }
                              qaList.add({'question': question, 'answer': answer});
                              if (flowData[currentQuestionIndex]["next"].length == 1) {
                                dest = flowData[currentQuestionIndex]["next"][0]["destElementId"];
                                int index = flowData
                                    .indexWhere((element) => element['id'] == dest);
                                dest = '';
                                currentQuestionIndex = index;
                              } else {
                                for (var i = 0; i < flowData[currentQuestionIndex]["next"].length; i++) {
                                  if (flowData[currentQuestionIndex]["next"][i]['arrowParams']
                                  ["startArrowPositionX"]
                                      .toString() ==
                                      '-1' ||
                                      flowData[currentQuestionIndex]["next"][i]['arrowParams']
                                      ["startArrowPositionX"]
                                          .toString() ==
                                          '1') {
                                    dest = flowData[currentQuestionIndex]["next"][i]["destElementId"];
                                    break;
                                  }
                                }
                                int index = flowData
                                    .indexWhere((element) => element['id'] == dest);
                                dest = '';
                                currentQuestionIndex = index;
                              }
                            });
                          },
                          child: flowData[currentQuestionIndex]["text"] == 'Gender' ? const Text(
                            "Female",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ) : const Text(
                            "No",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              } else
                ...{
                  if(flowData[currentQuestionIndex]["text"] ==
                      "Proceed with questions")...{
                    RoundButton(
                      title: 'OK',
                      loading: loading,
                      onTap: () async {
                        await fetchFlow();
                        setState(() {
                          currentQuestionIndex=0;
                        });
                      },
                    )}
                  else if(flowData[currentQuestionIndex]["text"] ==
                      "Press on submit button")...{
                    RoundButton(
                      title: 'SUBMIT',
                      loading: loading,
                      onTap: () async {
                        //submitAnswers();
                        setState(() {
                          loading = true;
                        });
                      },
                    )}
                  else...{
                  Container(
                    margin: const EdgeInsets.only(left: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.green.shade50,
                              ),
                              child: flowData[currentQuestionIndex]["text"] == 'Age' ? Row(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 10.0),
                                      child: TextFormField(
                                        controller: ageYearController,
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
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          hintText: "Age in years",
                                          // contentPadding:
                                          // EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          border: InputBorder.none,
                                        ),
                                        onChanged: (text) {
                                          setState(() {
                                            finalYearText = int.tryParse(text) ?? 0;
                                            // _scrollToBottom();
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(3.0),
                                      child: TextFormField(
                                        controller: ageMonthController,
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
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          hintText: "Age in months",
                                          contentPadding:
                                          EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                          border: InputBorder.none,
                                        ),
                                        onChanged: (text) {
                                          setState(() {
                                            finalMonthText =
                                                int.tryParse(text) ?? 0;
                                            // _scrollToBottom();
                                          });
                                        },
                                      ),
                                    ),
                                  )
                                ],
                              )
                                  : Padding(
                                padding: const EdgeInsets.only(
                                    top: 3.0, bottom: 3, right: 3, left: 6),
                                child: TextField(
                                  controller: controller,
                                  decoration: const InputDecoration(
                                    hintText: "Type answer...",
                                    // contentPadding:
                                    // EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    border: InputBorder.none,
                                  ),
                                  onChanged: (text) {
                                    setState(() {
                                      finalText = text;
                                      // _scrollToBottom();
                                    });
                                  },
                                ),
                              )
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              String question = flowData[currentQuestionIndex]["text"];
                              if (flowData[currentQuestionIndex]["text"] == 'Age') {
                                String answer=( finalYearText + (finalMonthText / 12)).toString();
                                qaList.add({'question': question, 'answer': answer});
                              }
                              else {
                                String answer = finalText;
                                if (flowData[currentQuestionIndex]["text"] == "Patient's Name") {
                                   name = finalText;
                                }
                                if (flowData[currentQuestionIndex]["text"] == 'Mobile Number') {
                                   mobile = finalText;
                                }
                                qaList.add({'question': question, 'answer': answer});
                              }

                              int index = flowData.indexWhere((element) =>
                              element['id'] ==
                                  flowData[currentQuestionIndex]["next"][0]["destElementId"]);
                              currentQuestionIndex = index;
                              controller.text = '';
                              finalText = '';
                            });
                          },
                          icon: Icon(Icons.send, color: Colors.green[400]),
                        ),
                      ],
                    ),
                  ),
                  }
                },
            ],
          ),
        ),
      ),
      ],
      ),
    );
  }
  loadQuestions(){

  }
  // void submitAnswers() async {
  //   final patientDataCollectionRef = FirebaseFirestore.instance
  //       .collection('preConsult')
  //       .doc(userId)
  //       .collection('patientData')
  //       .doc(easyid);
  //
  //   // Create a new map to store the answers for this questionnaire
  //   List<Map<String, dynamic>> questionnaireAnswers = [];
  //
  //   // Iterate over the entries in the 'answers' map and add each question and its answer to the 'questionnaireAnswers' map
  //   for (final entry in answers.entries) {
  //     final int questionIndex = int.tryParse(entry.key) ?? 0;
  //     if (questionIndex < flowData.length) {
  //       final Map<String, dynamic> answer = {
  //         'question': flowData[questionIndex]['text'],
  //         'answer': entry.value,
  //       };
  //       questionnaireAnswers.add(answer);
  //     }
  //   }
  //
  //   // Create a new document in the 'patientData' collection and set its data to the questionnaire answers
  //   try {
  //     await patientDataCollectionRef.update({
  //       'questionnaireAnswers': questionnaireAnswers,
  //     });
  //     print('Data saved successfully.');
  //   } catch (e) {
  //     print('Error saving data: $e');
  //   }
  //
  //   // Show a success dialog
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Form Submitted'),
  //         content: const Text('Your form has been submitted.'),
  //         actions: <Widget>[
  //           TextButton(
  //             child: const Text('OK'),
  //             onPressed: () {
  //               Navigator.push(
  //                   context,
  //                   MaterialPageRoute(
  //                       builder: (context) =>
  //                           PatientForm(easyid:easyid)));
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  //   setState(() {
  //     loading = false;
  //   });
  // }
}
