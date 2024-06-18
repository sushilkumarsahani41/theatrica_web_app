import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogBook extends StatefulWidget {
  const LogBook({super.key});

  @override
  State<LogBook> createState() => _LogBookState();
}

class _LogBookState extends State<LogBook> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String uid = '';
  getUid() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? dataUid = pref.getString('uid');
    setState(() {
      uid = dataUid!;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    getUid();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        foregroundColor: Colors.white,
        title: const Text(
          'Log Book',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: Colors.deepPurple,
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: _firestore
                    .collection('logbook')
                    .where('users', arrayContains: uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 50,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  } else if (!snapshot.hasData) {
                    return const Center(
                      child: Text('No Log Book Assigned to You'),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var doc = snapshot.data!.docs[index];
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ViewLogs(logBookId: doc.id)));
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 10),
                          child: Container(
                            height: 60,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 25,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 4,
                                  spreadRadius: 2,
                                  color: Colors.grey.shade400,
                                  offset: const Offset(3, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  doc['name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Icon(Icons.arrow_circle_right_outlined),
                              ],
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
      ),
    );
  }
}

class ViewLogs extends StatefulWidget {
  final bool addEntry;
  final String logBookId;
  const ViewLogs({super.key, required this.logBookId, this.addEntry = true});

  @override
  State<ViewLogs> createState() => _ViewLogsState();
}

class _ViewLogsState extends State<ViewLogs> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _logController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String uid = '';
  String uName = '';
  String logBookName = '';
  bool isIndexEven(int index) {
    return index % 2 == 0;
  }

  getInfo() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? getUid = pref.getString('uid');
    var userData = await _firestore.collection('users').doc(getUid).get();
    var logData =
        await _firestore.collection('logbook').doc(widget.logBookId).get();
    setState(() {
      uid = getUid!;
      uName = userData['name'];
      logBookName = logData['name'];
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getInfo();
    _scrollToBottom();
  }

  @override
  void dispose() {
    _logController.dispose();
    super.dispose();
  }

  void _scrollToNewEntry() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _scrollToBottom() {
    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent -
              _scrollController.offset <
          50) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _addLog() {
    var content = _logController.text.trim();
    if (content.isNotEmpty) {
      var logEntry = {
        'name': uName, // Replace with actual username logic
        'userId': uid, // Replace with actual user ID logic
        'content': content,
        'timestamp': FieldValue.serverTimestamp(),
      };
      _firestore
          .collection('logbook')
          .doc(widget.logBookId)
          .collection('logs')
          .add(logEntry);
      _logController.clear();
      // Clear the text field after sending
      setState(() {
        _scrollToNewEntry(); // Scroll to new entry after adding
        _logController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // centerTitle: true,
        foregroundColor: Colors.white,
        title: Text(
          logBookName,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: Colors.deepPurple,
      body: Container(
        padding:
            const EdgeInsets.only(left: 20, right: 20, top: 30, bottom: 10),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('logbook')
                    .doc(widget.logBookId)
                    .collection('logs')
                    .orderBy('timestamp',
                        descending:
                            false) // Make sure logs are ordered by timestamp
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text("No Logs Found"),
                    );
                  }
                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: snapshot.data!.docs.length,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 15),
                    itemBuilder: (context, index) {
                      var log = snapshot.data!.docs[index];
                      var name = log['name'] ?? "Unnamed Log";
                      var content = log['content'] ?? "No content provided";
                      Timestamp timestamp = log['timestamp'] as Timestamp;
                      DateTime date = timestamp.toDate();

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
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
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isIndexEven(index)
                                      ? Colors.deepPurple
                                      : Colors.deepOrange,
                                ),
                              ),
                              const Divider(height: 2, color: Colors.grey),
                              const SizedBox(height: 5),
                              Text(content),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Text(
                                  DateFormat('dd MMM, yyyy hh:mm a')
                                      .format(date),
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            widget.addEntry
                ? Padding(
                    padding: const EdgeInsets.only(
                      top: 8.0,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _logController,
                            decoration: InputDecoration(
                              hintText: "Enter log details",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey[200],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.note_add, color: Colors.deepPurple),
                          onPressed: _addLog,
                        ),
                      ],
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
