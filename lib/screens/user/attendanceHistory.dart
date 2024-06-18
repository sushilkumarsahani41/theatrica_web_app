import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AttendanceHistory extends StatefulWidget {
  const AttendanceHistory({super.key});

  @override
  State<AttendanceHistory> createState() => _AttendanceHistoryState();
}

class _AttendanceHistoryState extends State<AttendanceHistory> {
  String uid = '';
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> getUid() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? dataUid = pref.getString('uid');
    if (dataUid != null) {
      setState(() {
        uid = dataUid;
      });
    } else {
      // Handle error or alert user if UID is not found
      print("UID not found in SharedPreferences.");
    }
  }

  @override
  void initState() {
    super.initState();
    getUid();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        foregroundColor: Colors.white,
        title: const Text(
          'Attendance History',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: Colors.deepPurple,
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: uid.isEmpty
              ? const Center(child: Text("Loading UID..."))
              : StreamBuilder<QuerySnapshot>(
                  stream: _db
                      .collection('users')
                      .doc(uid)
                      .collection('attendance')
                      .orderBy('clock-in-time', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData ||
                        snapshot.data!.docs.isEmpty) {
                      return const Center(
                          child: Text('No attendance records found.'));
                    }
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var document = snapshot.data!.docs[index].data()
                            as Map<String, dynamic>;
                        return _buildAttendanceCard(document);
                      },
                    );
                  }),
        ),
      ),
    );
  }

  Widget _buildAttendanceCard(Map<String, dynamic> document) {
    Timestamp? inTime = document['clock-in-time'] as Timestamp?;
    Timestamp? outTime = document['clock-out-time'] as Timestamp?;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              blurRadius: 4,
              spreadRadius: 2,
              color: Colors.grey.shade400,
              offset: const Offset(3, 2),
            ),
          ],
          border: Border.all(color: Colors.deepPurple, width: 2),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  inTime != null ? _timeStampToDate(inTime) : '',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ],
            ),
            Divider(thickness: 1, color: Colors.grey.shade400),
            DataTable(
              dividerThickness: 0,
              columns: const [
                DataColumn(
                    label: Text("From",
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text("To",
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: [
                DataRow(
                  cells: [
                    DataCell(Text(
                        inTime != null ? _timeStampToTime(inTime) : '-- : --')),
                    DataCell(Text(outTime != null
                        ? _timeStampToTime(outTime)
                        : '-- : --')),
                  ],
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(_calculateDuration(inTime, outTime)),
            ),
          ],
        ),
      ),
    );
  }

  String _timeStampToDate(Timestamp timestamp) {
    return DateFormat('dd, MMM yyyy').format(timestamp.toDate());
  }

  String _timeStampToTime(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return DateFormat('hh:mm a')
        .format(date); // Format time in hour-minute AM/PM format
  }

  String _calculateDuration(Timestamp? startTime, Timestamp? endTime) {
    if (startTime == null || endTime == null) {
      return 'Duration: --';
    }
    DateTime start = startTime.toDate();
    DateTime end = endTime.toDate();
    Duration difference = end.difference(start);
    int hours = difference.inHours;
    int minutes = difference.inMinutes % 60; // Minutes after subtracting hours
    return 'Duration: ${hours}h ${minutes}m';
  }
}
