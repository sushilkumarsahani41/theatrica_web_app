import 'package:flutter/material.dart';

class OrganizationsPage extends StatefulWidget {
  const OrganizationsPage({super.key});

  @override
  State<OrganizationsPage> createState() => _OrganizationsPageState();
}

class _OrganizationsPageState extends State<OrganizationsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? selectedOrganization;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Organizations Page'),
      ),
      body: GestureDetector(
        onTap: () {
          setState(() {
            selectedOrganization = null;
          });
        },
        child: Row(
          children: [
            Expanded(
              child: ListView(
                children: [
                  // List of organizations
                  _buildOrganizationTile('ABC Corporation', '123 Main St'),
                  _buildOrganizationTile('XYZ Enterprises', '456 Oak Ave'),
                  _buildOrganizationTile('PQR Industries', '789 Elm St'),
                ],
              ),
            ),
          ],
        ),
      ),
      endDrawer: selectedOrganization != null
          ? ConstrainedBox(
              constraints: BoxConstraints.expand(
                  width: MediaQuery.of(context).size.width * 0.25),
              child: Drawer(
                child: OrganizationDetailsDrawer(
                    name: selectedOrganization!, address: 'Address'),
              ),
            )
          : null,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddOrganizationDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildOrganizationTile(String name, String address) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedOrganization = name;
        });
        _scaffoldKey.currentState?.openEndDrawer();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: selectedOrganization == name
                  ? Colors.deepPurple
                  : Colors.white,
              width: 2),
          color: selectedOrganization == name
              ? Colors.deepPurple[100]
              : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 4,
              offset: const Offset(0, 2), // changes position of shadow
            ),
          ],
        ),
        child: ListTile(
          title: Text(name),
          subtitle: Text(address),
        ),
      ),
    );
  }

  void _showAddOrganizationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Organization'),
          content: const SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Address'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Add organization logic here
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}

class OrganizationDetailsDrawer extends StatelessWidget {
  final String name;
  final String address;

  const OrganizationDetailsDrawer({
    super.key,
    required this.name,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                ),
                child: Text(
                  'Organization Details',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                title: Text('Name: $name'),
              ),
              ListTile(
                title: Text('Address: $address'),
              ),
              // Add more organization details here
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: FloatingActionButton(
              onPressed: () {
                _showAddClassDialog(context);
              },
              child: const Icon(Icons.add),
            ),
          ),
        ),
      ],
    );
  }

  void _showAddClassDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Class'),
          content: const SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  decoration: InputDecoration(labelText: 'Class Name'),
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Class Time'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Add class logic here
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
