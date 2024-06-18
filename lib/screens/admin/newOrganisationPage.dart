import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminOrgPage extends StatefulWidget {
  const AdminOrgPage({super.key});

  @override
  _AdminOrgPageState createState() => _AdminOrgPageState();
}

class _AdminOrgPageState extends State<AdminOrgPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String selectedOrg = 'none';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Organisations/Schools',
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
              child: selectedOrg == 'none'
                  ? const Center(child: Text('Please Select Org First'))
                  : _buildOrgSection(),
            ),
          ],
        ),
      ),
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
            child: Text('Organisation',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('org').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                var users = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    return _buildOrgTile(users[index]['name'],
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
                onPressed: _addNewOrg,
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

  Widget _buildOrgTile(String name, String id, String uid) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedOrg = uid;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: selectedOrg == name ? Colors.deepPurple : Colors.white,
              width: 2),
          color: selectedOrg == name ? Colors.deepPurple[100] : Colors.white,
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
                      await _deleteOrg(uid);

                      // Optionally, update the UI or show a message
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Organisation deleted successfully")));
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
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm Deletion'),
              content: const Text(
                  'Are you sure you want to delete this organistaion/School? This action cannot be undone.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context)
                        .pop(false); // Dismiss the dialog and return false
                  },
                ),
                TextButton(
                  child: const Text('Delete'),
                  onPressed: () {
                    Navigator.of(context)
                        .pop(true); // Dismiss the dialog and return true
                  },
                ),
              ],
            );
          },
        ) ??
        false; // Returning false if null is returned (when the dialog is dismissed by other means than a button)
  }

  Widget _buildOrgSection() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('org').doc(selectedOrg).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        var orgData = snapshot.data!.data() as Map<String, dynamic>;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Name: ${orgData['name']}", style: const TextStyle(fontSize: 20)),
              Text("ID: ${orgData['id']}", style: const TextStyle(fontSize: 16)),
              Text("Address: ${orgData['address']}",
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _addClassDialog(context, orgData['id']),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.deepPurpleAccent,
                ),
                child: const Text("Add New Class"),
              ),
              const SizedBox(height: 10),
              const Text("Classes",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.deepPurpleAccent),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _buildClassesList(orgData['id']),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addClassDialog(BuildContext context, String orgId) {
    TextEditingController idController = TextEditingController();
    TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add New Class"),
          content: Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  controller: idController,
                  decoration: const InputDecoration(labelText: 'Class ID'),
                ),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Class Name'),
                ),
              ],
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
              child: const Text('Add'),
              onPressed: () {
                _firestore.collection('classes').add({
                  'orgId': orgId,
                  'id': idController.text,
                  'name': nameController.text,
                }).then((result) {
                  print("Class added successfully");
                  Navigator.of(context).pop();
                }).catchError((error) {
                  print("Failed to add class: $error");
                });
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildClassesList(String orgId) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('classes')
          .where('orgId', isEqualTo: orgId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        List<DocumentSnapshot> classDocs = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(), // to disable scrolling within the list
          itemCount: classDocs.length,
          itemBuilder: (context, index) {
            var classData = classDocs[index].data() as Map<String, dynamic>;
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.deepPurpleAccent),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 4,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ListTile(
                title: Text(classData['name']),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () =>
                      _confirmDeleteClass(context, classDocs[index].id),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          ClassDetailsPage(classId: classDocs[index].id),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDeleteClass(BuildContext context, String classId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Deletion"),
        content: const Text(
            "Are you sure you want to delete this class? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              _firestore.collection('classes').doc(classId).delete();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Class deleted successfully")));
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _addNewOrg() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController idController = TextEditingController();
    final TextEditingController addressController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add New Organization"),
          content: Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: idController,
                  decoration: const InputDecoration(labelText: 'ID'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an ID';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an address';
                    }
                    return null;
                  },
                ),
                // Add other fields as necessary
              ],
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
              child: const Text('Save'),
              onPressed: () {
                // Logic to save new organization
                if (Form.of(context).validate() ?? false) {
                  _firestore.collection('org').add({
                    'name': nameController.text,
                    'id': idController.text,
                    'address': addressController.text,
                    // Add other fields as necessary
                  }).then((result) {
                    print("Organization added successfully");
                    Navigator.of(context).pop();
                  }).catchError((error) {
                    print("Failed to add organization: $error");
                    Navigator.of(context).pop();
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteOrg(String orgId) async {
    try {
      await _firestore.collection('org').doc(orgId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Organization deleted successfully")));
      // Reset selectedOrg if currently viewed org is deleted
      if (selectedOrg == orgId) {
        setState(() {
          selectedOrg = 'none';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete organization: $e")));
    }
  }
}

class ClassDetailsPage extends StatelessWidget {
  final String classId;

  const ClassDetailsPage({super.key, required this.classId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Details'),
      ),
      body: Center(
        child: Text('Details for class ID: $classId'),
      ),
    );
  }
}
