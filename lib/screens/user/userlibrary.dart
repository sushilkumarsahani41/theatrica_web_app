import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class UserLibrary extends StatefulWidget {
  const UserLibrary({super.key});

  @override
  State<UserLibrary> createState() => _UserLibraryState();
}

class _UserLibraryState extends State<UserLibrary> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        foregroundColor: Colors.white,
        title: const Text(
          'Library',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: Colors.deepPurple,
      body: Container(
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30))),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('library')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    var folders = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: folders.length,
                      itemBuilder: (context, index) {
                        var doc = folders[index];
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        FolderScreen(folder: doc.id)));
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            child: Container(
                              height: 60,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 25),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                      blurRadius: 4,
                                      spreadRadius: 2,
                                      color: Colors.grey.shade400,
                                      offset: const Offset(3, 2))
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    doc['name'],
                                    // "sample",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const Icon(Icons.arrow_circle_right_outlined)
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
      ),
    );
  }
}

class FolderScreen extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  final folder;
  const FolderScreen({super.key, required this.folder});

  @override
  State<FolderScreen> createState() => _FolderScreenState();
}

class _FolderScreenState extends State<FolderScreen> {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  String folderName = '';

  getFolderName(id) async {
    DocumentSnapshot<Map<String, dynamic>> data =
        await db.collection('library').doc(id).get();
    setState(() {
      folderName = data['name'];
    });
  }

  @override
  void initState() {
    getFolderName(widget.folder);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (folderName.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          foregroundColor: Colors.white,
          title: Text(
            widget.folder,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.deepPurple,
        ),
        backgroundColor: Colors.deepPurple,
        body: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              color: Colors.deepPurple,
            ),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        foregroundColor: Colors.white,
        title: Text(
          folderName,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: Colors.deepPurple,
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('library')
                      .doc(widget.folder)
                      .collection('files')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    var folders = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: folders.length,
                      itemBuilder: (context, index) {
                        var doc = folders[index];
                        return InkWell(
                          onTap: () async {
                            var fileUrl = doc['url'];
                            if (fileUrl != null) {
                              await _launchUrl(fileUrl);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('No URL found for this item')));
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            child: Container(
                              height: 60,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 25),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                      blurRadius: 4,
                                      spreadRadius: 2,
                                      color: Colors.grey.shade400,
                                      offset: const Offset(3, 2))
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${doc['name']}.${doc['type']}",
                                    // "sample",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const Icon(
                                      Icons.download_for_offline_outlined)
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
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url),
        mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }
}
