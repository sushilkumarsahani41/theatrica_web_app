import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminUserPage extends StatefulWidget {
  const AdminUserPage({super.key});

  @override
  State<AdminUserPage> createState() => _AdminUserPageState();
}

class _AdminUserPageState extends State<AdminUserPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String selectedUser = 'none';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Users/Trainers',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: _buildUsersSection(),
            ),
            Expanded(
              flex: 3,
              child: selectedUser == 'none'
                  ? const Center(child: Text('Please Select USer First'))
                  : _buildUserSection(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserSection() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('users').doc(selectedUser).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        var userData = snapshot.data!.data() as Map<String, dynamic>?;

        if (userData == null) {
          return const Center(child: Text("No user data found."));
        }

        return Row(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Name: ${userData['name']}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('Email: ${userData['email']}',
                        style: const TextStyle(fontSize: 16)),
                    Text('Phone: ${userData['phone'] ?? 'N/A'}',
                        style: const TextStyle(fontSize: 16)),
                    Text('Is Admin: ${userData['admin'] ? 'Yes' : 'No'}',
                        style:
                            const TextStyle(fontSize: 16, color: Colors.red)),
                    // Add more user details as required
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.all(16),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('User Attendance',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple)),
                    Expanded(
                      child: _buildAttendanceList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUsersSection() {
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
            child: Text('Users',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                var users = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    return _buildUserTile(users[index]['name'],
                        users[index]['id'], users[index].id);
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
                onPressed: _addNewUser,
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
                      "Add User",
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

  IconData _getFileIcon(String type) {
    switch (type) {
      case 'image':
      case 'png':
      case 'jpg':
      case 'jpeg':
        return Icons.image;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'video':
        return Icons.video_library;
      default:
        return Icons.insert_drive_file;
    }
  }

  String shortenText(String inputText) {
    return inputText.length <= 7 ? inputText : inputText.substring(0, 7);
  }

  Widget _buildUserTile(String name, String id, String uid) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedUser = uid; // Ensure this matches with what you check below
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: selectedUser == uid
                  ? Colors.deepPurple
                  : Colors.grey, // This comparison should be against uid
              width: 2),
          color: selectedUser == uid ? Colors.deepPurple[100] : Colors.white,
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
                  onPressed: () async {
                    // Show confirmation dialog before deleting
                    bool confirmDelete =
                        await showDeleteConfirmationDialog(context);
                    if (confirmDelete) {
                      // Call the delete function if confirmed
                      await _deleteUser(uid);

                      // Optionally, update the UI or show a message
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("User deleted successfully")));
                    }
                  },
                  icon: const Icon(Icons.delete)),
              const Icon(Icons.arrow_forward_ios, size: 16)
            ],
          ),
          title: Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(id),
        ),
      ),
    );
  }

  Future<bool> showDeleteConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false, // User must tap button!
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm Delete'),
              content: const Text(
                  'Are you sure you want to delete this user? This action cannot be undone.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context)
                      .pop(false), // Dismiss dialog and return false
                ),
                TextButton(
                  child: const Text('Delete'),
                  onPressed: () => Navigator.of(context)
                      .pop(true), // Dismiss dialog and return true
                ),
              ],
            );
          },
        ) ??
        false; // If the dialog is dismissed by clicking outside or pressing the back button, return false
  }

  Widget _buildAttendanceList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('users')
          .doc(selectedUser)
          .collection('attendance')
          .orderBy('clock-in-time', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        List<DocumentSnapshot> docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(
            child: Text("No Attendance Record"),
          );
        }
        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> document =
                docs[index].data() as Map<String, dynamic>;
            String inUrl = document['clock-in-location'] != null
                ? document['clock-in-location']['url'] ?? ''
                : '';
            String outUrl = document['clock-out-location'] != null
                ? document['clock-out-location']['url'] ?? ''
                : '';
            return _buildAttendanceCard(document, inUrl, outUrl);
          },
        );
      },
    );
  }

  Future<void> _launchUrl(String url) async {
    // Parse the URL
    final Uri uri = Uri.parse(url);

    // Check if the URL can be launched
    if (await canLaunchUrl(uri)) {
      // Launch the URL in a new tab (specifically for web)
      bool launched = await launchUrl(uri,
          mode: LaunchMode
              .externalApplication, // Opens in the default browser application
          webOnlyWindowName:
              '_blank' // Ensures it opens in a new tab on web platforms
          );

      if (!launched) {
        // If the URL could not be launched for some reason, log or handle it
        print('Could not launch $url');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to open the URL.')),
        );
      }
    } else {
      // If the URL is not valid or not launchable
      print('Invalid URL: $url');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid URL provided.')),
      );
    }
  }

  Widget _buildAttendanceCard(
      Map<String, dynamic> document, inLocation, outLocation) {
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
                ),
                DataRow(
                  cells: [
                    DataCell(IconButton(
                      icon: const Icon(
                        Icons.share_location_outlined,
                        size: 36,
                      ),
                      onPressed: () {
                        _launchUrl(inLocation);
                      },
                    )),
                    DataCell(IconButton(
                      icon: const Icon(
                        Icons.share_location_outlined,
                        size: 36,
                      ),
                      onPressed: () {
                        _launchUrl(outLocation);
                      },
                    )),
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

  Future<FirebaseApp> initializeSecondaryApp() async {
    const String appName = 'SecondaryApp';
    // Define specific Firebase options for the secondary app
    const FirebaseOptions secondaryAppOptions = FirebaseOptions(
        apiKey: "AIzaSyAa0Dd2RCDfvhwoMEyRZ9gtLpAVt5lVMDM",
        authDomain: "sar-web-77006.firebaseapp.com",
        projectId: "sar-web-77006",
        storageBucket: "sar-web-77006.appspot.com",
        messagingSenderId: "284250443352",
        appId: "1:284250443352:web:b539e964e668564114c42d",
        measurementId: "G-C7VREW2VK6");

    try {
      // Initialize a Firebase App with specific options
      return await Firebase.initializeApp(
        name: appName,
        options: secondaryAppOptions,
      );
    } catch (e) {
      // If the secondary app is already initialized, just return it
      return Firebase.app(appName);
    }
  }

  void _addNewUser() {
    showDialog(
      context: context,
      builder: (context) {
        var defaultPass = 'Theatrica&#&2024';
        return AddUserForm(
            onAddUser: (name, email, phone, id, isAdmin, photoUrl) async {
          try {
            // Initialize the secondary Firebase App
            FirebaseApp secondaryApp = await initializeSecondaryApp();
            // Use the secondary Firebase App for authentication
            FirebaseAuth secondaryAuth =
                FirebaseAuth.instanceFor(app: secondaryApp);

            UserCredential userCredential =
                await secondaryAuth.createUserWithEmailAndPassword(
                    email: email,
                    password: defaultPass // Use a secure default password
                    );

            // Add user details to Firestore using the default app
            FirebaseFirestore.instance
                .collection('users')
                .doc(userCredential.user!.uid)
                .set({
              'name': name,
              'email': email,
              'phone': phone,
              'id': id,
              'admin': isAdmin,
              'photoUrl': photoUrl,
              'password': defaultPass
            });

            // Provide feedback to admin
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("User added successfully"),
              backgroundColor: Colors.green,
            ));

            // Optionally delete the secondary app if it's no longer needed
            // await secondaryApp.delete();
          } catch (e) {
            // Handle errors
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Failed to add user: $e"),
              backgroundColor: Colors.red,
            ));
          }
        });
      },
    );
  }

  Future<void> _deleteUser(String userId) async {
    var userData =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    try {
      // Initialize Firebase Auth instance
      FirebaseApp secondaryApp = await initializeSecondaryApp();
      FirebaseAuth secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
      // Get user by UID
      await secondaryAuth.signInWithEmailAndPassword(
          email: userData['email'], password: userData['password']);
      // Delete user from Firebase Authentication
      await secondaryAuth.currentUser!.delete();

      // Delete user data from Firestore
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();

      // Show a success message (this part depends on your UI logic)
      print("User successfully deleted.");
    } catch (e) {
      // Handle errors, such as user not found or lack of permissions
      print("Failed to delete user: $e");
    }
  }
}

class AddUserForm extends StatefulWidget {
  final void Function(String name, String email, String phone, String id,
      bool isAdmin, String photoUrl) onAddUser;

  const AddUserForm({super.key, required this.onAddUser});

  @override
  _AddUserFormState createState() => _AddUserFormState();
}

class _AddUserFormState extends State<AddUserForm> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _email = '';
  String _phone = '';
  String _id = '';
  bool _isAdmin = false;
  final String _photoUrl = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New User'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(labelText: 'Name'),
                onSaved: (value) => _name = value!,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a name' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                onSaved: (value) => _email = value!,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter an email' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Phone'),
                onSaved: (value) => _phone = value!,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a phone number' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'ID'),
                onSaved: (value) => _id = value!,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter an ID' : null,
              ),
              SwitchListTile(
                title: const Text('Is Admin?'),
                value: _isAdmin,
                onChanged: (bool value) {
                  setState(() {
                    _isAdmin = value;
                  });
                },
              ),
              // Add fields for photo upload or URL entry
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Add User'),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              widget.onAddUser(_name, _email, _phone, _id, _isAdmin, _photoUrl);
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}
