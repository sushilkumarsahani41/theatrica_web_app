import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserLeaveScreen extends StatefulWidget {
  const UserLeaveScreen({super.key});

  @override
  State<UserLeaveScreen> createState() => _UserLeaveScreenState();
}

class _UserLeaveScreenState extends State<UserLeaveScreen> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  String _selectedItem = 'Casual';
  final List<String> _items = ['Casual', 'Sick'];
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _subject = TextEditingController();
  final TextEditingController _reason = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Leave',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: Colors.deepPurple,
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 20),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history),
                SizedBox(width: 10),
                Text("Leave History"),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<String?>(
                future: _getUID(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  var uid = snapshot.data;
                  return StreamBuilder(
                    stream: db
                        .collection('leaves')
                        .orderBy('created-at', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        print(snapshot.error);
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData ||
                          snapshot.data!.docs.isEmpty) {
                        return const Center(
                            child: Text('No leave history found.'));
                      }
                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          var document = snapshot.data!.docs[index].data();
                          if (document['uid'] == uid) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    border:
                                        Border.all(color: Colors.grey.shade400),
                                    boxShadow: [
                                      BoxShadow(
                                          spreadRadius: .1,
                                          blurRadius: 50,
                                          color: Colors.grey.shade300)
                                    ],
                                    borderRadius: BorderRadius.circular(10)),
                                child: _buildLeaveItem(document),
                              ),
                            );
                          } else {
                            return Container();
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddLeaveDialog(context);
        },
        elevation: 5,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildLeaveItem(Map<String, dynamic> document) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              timestampToDate(document['created-at']),
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            LeaveStatus(document['status'])
          ],
        ),
        Divider(thickness: 1, color: Colors.grey.shade400),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            document['subject'],
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            document['type'],
            style: const TextStyle(color: Colors.black87, fontSize: 12),
          ),
        ),
        DataTable(
          dividerThickness: 0,
          columns: const [
            DataColumn(
                label: Text("From",
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label:
                    Text("To", style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: [
            DataRow(
              cells: [
                DataCell(Text(timestampToDate(document['start-date']))),
                DataCell(Text(timestampToDate(document['end-date']))),
              ],
            )
          ],
        )
      ],
    );
  }

  Widget LeaveStatus(String status) {
    Color bgColor = Colors.yellow.shade100;
    Color textColor = const Color.fromARGB(255, 247, 184, 13);
    String text = "Awaited";

    switch (status) {
      case 'rejected':
        bgColor = Colors.red.shade100;
        textColor = Colors.red;
        text = "Rejected";
        break;
      case 'approved':
        bgColor = Colors.green.shade100;
        textColor = Colors.green;
        text = "Approved";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: bgColor,
          border: Border.all(color: textColor)),
      child: Text(text, style: TextStyle(color: textColor)),
    );
  }

  String timestampToDate(Timestamp timestamp) {
    // Convert Timestamp to DateTime
    DateTime dateTime = timestamp.toDate();

    // Format DateTime to "MMMM dd, yyyy" format (e.g., "April 13, 2024")
    String formattedDate = DateFormat('MMMM dd, yyyy').format(dateTime);

    return formattedDate;
  }

  Future<String?> _getUID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('uid');
  }

  void _showAddLeaveDialog(BuildContext context) {
    DateTime? selectedFromDate;
    DateTime? selectedToDate;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('New Leave'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    TextField(
                      controller: _subject,
                      decoration: const InputDecoration(labelText: 'Subject'),
                    ),
                    TextField(
                      decoration: InputDecoration(
                        labelText: "From Date",
                        suffixIcon: IconButton(
                          onPressed: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2101),
                            );
                            if (picked != null && picked != selectedFromDate) {
                              setState(() {
                                selectedFromDate = picked;
                                _startDateController.text =
                                    DateFormat('dd-MM-yyyy').format(picked);
                              });
                            }
                          },
                          icon: const Icon(Icons.calendar_today),
                        ),
                      ),
                      controller: _startDateController,
                    ),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'To Date',
                        suffixIcon: IconButton(
                          onPressed: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2101),
                            );
                            if (picked != null && picked != selectedToDate) {
                              setState(() {
                                selectedToDate = picked;
                                _endDateController.text =
                                    DateFormat('dd-MM-yyyy').format(picked);
                              });
                            }
                          },
                          icon: const Icon(Icons.calendar_today),
                        ),
                      ),
                      controller: _endDateController,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const Text("Type"),
                        DropdownButton<String>(
                          value: _selectedItem,
                          onChanged: (newValue) {
                            setState(() {
                              _selectedItem = newValue!;
                            });
                          },
                          items: _items.map((item) {
                            return DropdownMenuItem<String>(
                              value: item,
                              child: Text(item),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    TextField(
                      controller: _reason,
                      maxLines: 3,
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (selectedFromDate != null && selectedToDate != null) {
                  await _addLeave(
                    Timestamp.fromDate(selectedFromDate!),
                    Timestamp.fromDate(selectedToDate!),
                    _selectedItem,
                  );
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addLeave(
      Timestamp startDate, Timestamp endDate, String type) async {
    String? uid = await _getUID();
    var userData = await _getUserInfo(uid);
    var data = {
      'name': userData?['name'],
      'created-at': Timestamp.now(),
      'reason': _reason.text,
      'subject': _subject.text,
      'start-date': startDate,
      'end-date': endDate,
      'status': 'awaited',
      'type': type,
      'uid': uid,
    };
    await db.collection('leaves').add(data);
  }

  Future<Map<String, dynamic>?> _getUserInfo(String? uid) async {
    if (uid == null) return null;
    var res = await db.collection('users').doc(uid).get();
    return res.data();
  }
}
