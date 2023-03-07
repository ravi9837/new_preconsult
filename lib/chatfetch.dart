import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ChatFetch extends StatefulWidget {
  final String mobile,ageYear,ageMonth;
  const ChatFetch({Key? key ,required this.mobile,required this.ageYear, required this.ageMonth}) : super(key: key);

  @override
  State<ChatFetch> createState() => _ChatFetchState();

}

class _ChatFetchState extends State<ChatFetch> {
  late double age=18;
  List _data = [];
  int currentQuestionIndex = 0;
  Map<String, dynamic> answers = {};
  @override
  void initState() {
    super.initState();
    age = double.parse(widget.ageYear) + double.parse(widget.ageMonth) / 12;
    fetchQuestions();
  }

  Future<void> fetchQuestions() async {

    String dataKey;
    if(age<1){
      dataKey='neonatal';
    }
    else if(age <8&&age>=1){
      dataKey='kid';
    }
    else{
      dataKey='id';
    }
    try {
      // Get a reference to the "questions" node in the database
      final dataKeyRef = FirebaseDatabase.instance.ref().child(dataKey);
      // Listen for changes to the data at the "questions" node
      dataKeyRef.onValue.listen((event) {
        // Extract the data from the event's DataSnapshot
        final dataSnapshot = event.snapshot;
        final data = dataSnapshot.value as List<dynamic>;

        setState(() {
          _data = data;
        });
      });
    } catch (e) {
      Text('Error getting data from Realtime Database: $e');
    }
  }

  Future<void> saveAnswers() async {
    final answersCollection = FirebaseFirestore.instance.collection('patientData').doc(widget.mobile);
    final answersToSave = answers.entries.map((e) => {'question': _data[int.parse(e.key)]['text'], 'answer': e.value}).toList();
    await answersCollection.update({'answers': answersToSave});
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
        body: Container(
            padding: const EdgeInsets.all(9.0),
            child: Column(children: <Widget>[
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(height: 10),

                        load(currentQuestionIndex, _data,answers),
                      ])),
              Container(height: 20),
              Visibility(visible: answers.length == _data.length,
                child: ElevatedButton(
                  onPressed: answers.length == _data.length ? submitAnswers : null,
                  child: const Center(child: Text("Submit")),
                ),
              ),

            ])));
  }

  Widget load(int x, List data, Map<String, dynamic> answers) {
    if (data.isNotEmpty && x < data.length) {
      return Column(
        children: [
          if (data[x]["options"][0] == 'yes') ...{
            Text(data[x]["text"]),
            TextButton(
                onPressed: () {
                  setState(() {
                    answers[x.toString()] = "Yes";
                    currentQuestionIndex = data[x]["branches"]["yes"];
                  });
                },
                child: const Text("Yes")),
            TextButton(
                onPressed: () {
                  setState(() {
                    answers[x.toString()] = "No";
                    currentQuestionIndex = data[x]["branches"]["no"];
                  });
                },
                child: const Text("No"))
          } else ...{
            Text(data[x]["text"]),
            TextField( onChanged: (text) {
              setState(() {
                answers[x.toString()] = text;
              });
            },),
            TextButton(
                onPressed: () {
                  setState(() {
                    currentQuestionIndex = data[x]["branches"]["yes"];
                  });
                },
                child: const Text("OK")),

            // Text(data[x]["options"].toString()),
          }
        ],
      );
    } else {
      return Container(
      );
    }
  }
  void submitAnswers() async {
    // Check if all questions have been answered
    if (answers.length < _data.length) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Incomplete Form'),
            content: const Text('Please answer all questions before submitting.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    // Get a reference to the 'patientData' collection in Firestore
    final patientDataCollectionRef = FirebaseFirestore.instance.collection('patientData').doc(widget.mobile);

    // Create a new map to store the answers for this questionnaire
    Map<String, dynamic> questionnaireAnswers = {};

    // Iterate over the entries in the 'answers' map and add each question and its answer to the 'questionnaireAnswers' map
    for (final entry in answers.entries) {
      final int questionIndex = int.tryParse(entry.key) ?? 0;
      if (questionIndex < _data.length) {
        questionnaireAnswers[_data[questionIndex]['text']] = entry.value;
      }
    }

    // Create a new document in the 'patientData' collection and set its data to the questionnaire answers
    try {
      await patientDataCollectionRef.update({
        'questionnaireAnswers': questionnaireAnswers,
      });
      print('Data saved successfully.');
    } catch (e) {
      print('Error saving data: $e');
    }

    // Show a success dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Form Submitted'),
          content: const Text('Your form has been submitted.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


}