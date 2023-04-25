import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:preconsult_app/patient_form.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class SearchBarScreen extends StatefulWidget {
  final String? timestamp;

  SearchBarScreen({this.timestamp, Key? key}) : super(key: key);

  @override
  _SearchBarScreenState createState() => _SearchBarScreenState();
}

class _SearchBarScreenState extends State<SearchBarScreen>
    with WidgetsBindingObserver {
  Map<String, dynamic>? userMap;
  bool isLoading = false;
  final TextEditingController _search = TextEditingController();
  final userId = FirebaseAuth.instance.currentUser!.uid;
  bool isSearchVisible = false;
  List<Map<String, dynamic>> allPatients = [];
  List<Map<String, dynamic>> filteredPatients = [];
  List<Map<String, dynamic>> searchSuggestions = [];
  bool hasSearchText = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    FirebaseFirestore _firestore = FirebaseFirestore.instance;
    _firestore
        .collection('preConsult')
        .doc(userId)
        .collection('patientData')
        .get()
        .then((value) {
      setState(() {
        if (widget.timestamp != null) {
          allPatients = value.docs.map((e) => e.data()).toList();
          filteredPatients = allPatients
              .where((patient) =>
          widget.timestamp == null ||
              patient['timestamp'] == widget.timestamp)
              .toList();
        } else {
          allPatients = value.docs.map((e) => e.data()).toList();
          filteredPatients = allPatients;
        }
        isLoading = false;
      });
    });
  }

  void onSearch() {
    try {
      setState(() {
        userMap = filteredPatients.firstWhere(
              (patient) => patient['easyid'] == (_search.text ?? ''),
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No matching patient found.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: widget.timestamp != null
            ? Text("Today's Consultations")
            : Text("Consultation's History"),
      ),
      body: isLoading
          ? Center(
        child: Container(
          height: size.height / 20,
          width: size.height / 20,
          child: CircularProgressIndicator(),
        ),
      )
          : Column(
        children: [
          SizedBox(
            height: size.height / 50,
          ),
          Container(
            height: size.height / 16,
            width: size.width,
            alignment: Alignment.center,
            child: Container(
              height: size.height / 15,
              width: size.width / 1.06,
              child: TypeAheadField<Map<String, dynamic>>(
                textFieldConfiguration: TextFieldConfiguration(
                  controller: _search,
                  decoration: InputDecoration(
                    label: const Text(
                        "Search (Enter easyid 'name' 'number')"),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (text) {
                    setState(() {
                      hasSearchText = text.isNotEmpty;
                    });
                  },
                ),
                suggestionsCallback: (pattern) {
                  if (pattern.isEmpty) {
                    return [];
                  }
                  searchSuggestions = filteredPatients
                      .where((patient) => patient['easyid']
                      .toLowerCase()
                      .contains(pattern.toLowerCase()))
                      .toList();
                  return searchSuggestions;
                },
                itemBuilder: (context, suggestion) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Card(
                      elevation: 10,
                      margin: const EdgeInsets.symmetric(vertical: 1),
                      color: Colors.cyan.shade100,
                      child: ListTile(
                        leading: CircleAvatar(
                            child: Icon(Icons.person),
                            foregroundImage:
                            NetworkImage(suggestion['image'])
                        ),
                        title: Text(suggestion['name']),
                        subtitle: Text(suggestion['mobile_number']),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 20,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  );
                },
                onSuggestionSelected: (suggestion) {
                  var easyid = suggestion['easyid'];
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => PatientForm(
                          easyid: easyid, patient: suggestion)));
                },
              ),
            ),
          ),
          SizedBox(
            height: size.height / 50,
          ),
          Expanded(
            child: hasSearchText
                ? Container() // hide the list if there is search text
                : StreamBuilder<QuerySnapshot>(
              builder: (context, snapshot) {
                if (filteredPatients.isEmpty) {
                  return const Center(
                      child: Text(
                        'NO RECORDS FOUND',
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            color: Colors.grey),
                      ));
                }
                return ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: filteredPatients.length,
                  itemBuilder: (context, index) {
                    final showName =
                    filteredPatients[index]['name'];
                    return Padding(
                      padding: const EdgeInsets.only(
                          left: 8, right: 8, top: 5),
                      child: Container(
                        width: 40,
                        child: GestureDetector(
                          onTap: () {
                            var easyid =
                            (filteredPatients[index]['easyid']);
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => PatientForm(
                                  easyid: easyid,
                                  patient: filteredPatients[index],
                                ),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Card(
                              elevation: 10,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 1),
                              color: Colors.teal.shade50,
                              child: ListTile(
                                contentPadding:
                                const EdgeInsets.symmetric(
                                    vertical: 5,
                                    horizontal: 15),
                                leading: CircleAvatar(
                                    backgroundColor: Colors.white70,
                                    child: Icon(Icons.person),
                                    foregroundImage: NetworkImage(
                                        filteredPatients[index]
                                        ['image'])),
                                title: Text(
                                  filteredPatients[index]['name'],
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  filteredPatients[index]
                                  ['mobile_number'],
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight:
                                      FontWeight.normal),
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 20,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}