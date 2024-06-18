import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sar_web/screens/user/UserLogBook.dart';

class AdminLogBook extends StatefulWidget {
  const AdminLogBook({super.key});

  @override
  State<AdminLogBook> createState() => _AdminLogBookState();
}

class _AdminLogBookState extends State<AdminLogBook> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var selectedLogBook = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Log Books',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: _buildLogBookSection(),
            ),
            Expanded(
              flex: 3,
              child: selectedLogBook == ''
                  ? const Center(child: Text('Please Select Log Book'))
                  : Center(
                      child: buildLogBookInfo(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLogBookInfo() {
    return FutureBuilder<DocumentSnapshot>(
      future: _firestore.collection('logbook').doc(selectedLogBook).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData && snapshot.data!.exists) {
          var data = snapshot.data!;
          List<dynamic> userIds = data['users'] as List<dynamic>? ??
              []; // Ensure 'userIds' defaults to an empty list
          return Row(
            children: [
              Expanded(
                flex: 1,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['name'],
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      const Divider(height: 2, color: Colors.grey),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          const Text(
                            'Users',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            width: 60,
                          ),
                          ElevatedButton(
                            onPressed: () => _showUserPicker(context),
                            child: const Text("Add User"),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Expanded(child: _buildUserList(userIds)),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  // padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.deepPurple.shade100),
                    boxShadow: [
                      BoxShadow(
                          blurRadius: 7,
                          spreadRadius: 2,
                          color: Colors.grey.shade300)
                    ],
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        bottomLeft: Radius.circular(10)),
                    color: Colors.white,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ViewLogs(
                          logBookId: selectedLogBook,
                          addEntry: false,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          );
        } else {
          return const Text("No data available");
        }
      },
    );
  }

  void _showUserPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select User"),
          content: SizedBox(
            width: double.maxFinite,
            child: UserPicker(
                selectedLogBook: selectedLogBook,
                onUserAdded: () {
                  setState(() {}); // This will force a rebuild of the widget
                }),
          ),
        );
      },
    );
  }

  Widget _buildUserList(List<dynamic> userIds) {
    if (userIds.isEmpty) {
      return const Text("No User added");
    }
    return ListView.builder(
      itemCount: userIds.length,
      itemBuilder: (context, index) {
        return FutureBuilder<DocumentSnapshot>(
          future: _firestore.collection('users').doc(userIds[index]).get(),
          builder: (BuildContext context,
              AsyncSnapshot<DocumentSnapshot> userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 50,
                child: Center(child: CircularProgressIndicator()),
              );
            } else if (userSnapshot.hasError) {
              return Text('Error: ${userSnapshot.error}');
            } else if (userSnapshot.hasData && userSnapshot.data!.exists) {
              return ListTile(
                trailing: IconButton(
                  onPressed: () {
                    _firestore
                        .collection('logbook')
                        .doc(selectedLogBook)
                        .update({
                      'users': FieldValue.arrayRemove([userIds[index]])
                    });
                    setState(() {});
                  },
                  icon: const Icon(Icons.delete),
                ),
                title: Text(userSnapshot.data!['name'] ??
                    'Unknown User'), // Provide a fallback name if 'name' is not set
              );
            } else {
              return ListTile(
                trailing: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.delete),
                ),
                title: const Text(
                    "User not found"), // If user data does not exist in the database
              );
            }
          },
        );
      },
    );
  }

  Widget _buildLogBookSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.deepPurple.shade100),
        boxShadow: [
          BoxShadow(blurRadius: 7, spreadRadius: 2, color: Colors.grey.shade300)
        ],
        borderRadius: const BorderRadius.only(
            topRight: Radius.circular(10), bottomRight: Radius.circular(10)),
        color: Colors.white,
      ),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Log Books',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('logbook').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                var logBooks = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: logBooks.length,
                  itemBuilder: (context, index) {
                    return _buildLogBookTile(
                        logBooks[index]['name'], logBooks[index].id);
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent),
                onPressed: _promptAddLogBook,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Add Log Book",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogBookTile(String name, String logBookid) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedLogBook =
              logBookid; // Ensure this matches with what you check below
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: selectedLogBook == logBookid
                  ? Colors.deepPurple
                  : Colors.grey, // This comparison should be against uid
              width: 2),
          color: selectedLogBook == logBookid
              ? Colors.deepPurple[100]
              : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                  onPressed: () => _promptDeleteLogBook(logBookid, name),
                  icon: const Icon(Icons.delete)),
              const Icon(Icons.arrow_forward_ios, size: 16)
            ],
          ),
          title: Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  void _promptDeleteLogBook(String logBookId, String name) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content:
              Text('Are you sure you want to delete the log book "$name"?'),
          actions: <Widget>[
            TextButton(
              child: const Text('CANCEL'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('DELETE'),
              onPressed: () {
                _deleteLogBook(logBookId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteLogBook(String logBookId) async {
    await _firestore.collection('logbook').doc(logBookId).delete();
  }

  void _promptAddLogBook() {
    TextEditingController textFieldController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Log Book'),
          content: TextField(
            controller: textFieldController,
            decoration: const InputDecoration(hintText: "Log Book Name"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('ADD'),
              onPressed: () {
                _addLogBook(textFieldController.text);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _addLogBook(String name) async {
    if (name.isNotEmpty) {
      await _firestore.collection('logbook').add({'name': name, 'users': []});
    }
  }

  Widget buildLogs() {
    return StreamBuilder(
      stream: _firestore
          .collection('logbook')
          .doc(selectedLogBook)
          .collection('logs')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text("Error: ${snapshot.error}"),
          );
        }
        if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text("No Logs Found"),
          );
        }
        return ListView.builder(itemBuilder: (context, index) {
          return Container();
        });
      },
    );
  }
}

class UserPicker extends StatefulWidget {
  final String selectedLogBook;
  final Function() onUserAdded;
  const UserPicker(
      {super.key, required this.selectedLogBook, required this.onUserAdded});

  @override
  _UserPickerState createState() => _UserPickerState();
}

class _UserPickerState extends State<UserPicker> {
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: searchController,
            decoration: const InputDecoration(
              labelText: "Search User",
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const CircularProgressIndicator();
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var document = snapshot.data!.docs[index];
                  if (searchController.text.isEmpty) {
                    return ListTile(
                      title: Text(document['name']),
                      onTap: () async {
                        await FirebaseFirestore.instance
                            .collection('logbook')
                            .doc(widget.selectedLogBook)
                            .update({
                          'users': FieldValue.arrayUnion([document.id])
                        });
                        widget.onUserAdded(); // Call the callback function
                        Navigator.pop(context);
                      },
                    );
                  } else if (searchController.text.isNotEmpty &&
                      document['name']
                          .toString()
                          .toLowerCase()
                          .contains(searchController.text.toLowerCase())) {
                    return ListTile(
                      title: Text(document['name']),
                      onTap: () async {
                        await FirebaseFirestore.instance
                            .collection('logbook')
                            .doc(widget.selectedLogBook)
                            .update({
                          'users': FieldValue.arrayUnion([document.id])
                        });
                        widget.onUserAdded(); // Call the callback function
                        Navigator.pop(context);
                      },
                    );
                  } else {
                    return Container();
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
