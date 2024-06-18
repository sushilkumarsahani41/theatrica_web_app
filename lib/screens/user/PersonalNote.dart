import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class PersonalNote extends StatefulWidget {
  const PersonalNote({super.key});

  @override
  State<PersonalNote> createState() => _PersonalNoteState();
}

class _PersonalNoteState extends State<PersonalNote> {
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
    if (uid.isEmpty) {
      return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            foregroundColor: Colors.white,
            title: const Text(
              'Personal Notes',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.deepPurple,
          ),
          backgroundColor: Colors.deepPurple,
          body: Container(
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30))),
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.deepPurple,
              ),
            ),
          ));
    }
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        foregroundColor: Colors.white,
        title: const Text(
          'Personal Notes',
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
                      .collection('users')
                      .doc(uid)
                      .collection('notes')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.data!.docs.isEmpty) {
                      return const Center(
                          child: Text("There is No Personal Notes..."));
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
                                    builder: (context) => NoteViewScreen(
                                          uid: uid,
                                          noteId: doc.id,
                                        )));
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
                                    doc['title'],
                                    // "sample",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                          onPressed: () async {
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(uid)
                                                .collection('notes')
                                                .doc(doc.id)
                                                .delete();
                                          },
                                          icon: const Icon(Icons.delete)),
                                      const Icon(
                                          Icons.arrow_circle_right_outlined)
                                    ],
                                  )
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => AddNotePage(uid: uid)));
        },
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.white,
        elevation: 5,
        child: const Icon(Icons.post_add),
      ),
    );
  }
}

class AddNotePage extends StatefulWidget {
  final String uid;
  const AddNotePage({super.key, required this.uid});

  @override
  _AddNotePageState createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  List<Uint8List> fileDataList = [];
  List<String> fileNameList = [];
  List<UploadTask> tasks = [];

  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: true // Allow multiple files to be picked
        );
    if (result != null) {
      setState(() {
        for (var pickedFile in result.files) {
          fileDataList.add(pickedFile.bytes!);
          fileNameList.add(pickedFile.name);
        }
      });
    }
  }

  Future<void> _uploadFiles() async {
    DocumentReference noteRef = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .collection('notes')
        .doc(); // Create a reference to a new note document

    await noteRef.set({
      'title': _titleController.text,
      'content': _contentController.text,
      'timestamp': Timestamp.now(),
    }); // Set the basic note details

    for (int i = 0; i < fileDataList.length; i++) {
      final String fileName = fileNameList[i];
      final String filePath = 'notes/${noteRef.id}/$fileName'
          .replaceAll(' ', '_'); // Use noteRef.id to create unique paths

      try {
        Reference uploadRef = FirebaseStorage.instance.ref().child(filePath);
        UploadTask task = uploadRef.putData(fileDataList[i]);
        tasks.add(task);

        final snapshot = await task.whenComplete(() {});
        final fileUrl = await snapshot.ref.getDownloadURL();

        // Create a new document for each file in the 'files' subcollection of the note
        await noteRef.collection('files').add({
          'fileName': fileName,
          'fileUrl': fileUrl,
          'filePath': filePath,
        });
      } catch (e) {
        print('Error uploading file: $e');
      }
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        foregroundColor: Colors.white,
        title: const Text(
          'Add Personal Note',
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            children: <Widget>[
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                    labelText: 'Add Title',
                    labelStyle:
                        TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              ),
              TextField(
                controller: _contentController,
                decoration: const InputDecoration(labelText: 'Content'),
                maxLines: 20,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: fileNameList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(fileNameList[index]),
                      trailing: const Icon(Icons.check, color: Colors.green),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _pickFile,
                    child: const Text('Attach More Files'),
                  ),
                  ElevatedButton(
                    onPressed: _uploadFiles,
                    child: const Text('Save Note'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NoteViewScreen extends StatefulWidget {
  final String uid;
  final String noteId; // Document ID for the note
  const NoteViewScreen({super.key, required this.uid, required this.noteId});

  @override
  State<NoteViewScreen> createState() => _NoteViewScreenState();
}

class _NoteViewScreenState extends State<NoteViewScreen> {
  late Stream<QuerySnapshot> filesStream;

  @override
  void initState() {
    super.initState();
    // Setting up the stream to fetch files from the subcollection
    filesStream = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .collection('notes')
        .doc(widget.noteId)
        .collection('files')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text('Note Details'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      EditNotePage(uid: widget.uid, noteId: widget.noteId),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteNote,
          ),
        ],
      ),
      backgroundColor: Colors.deepPurple,
      body: Container(
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30))),
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.uid)
                    .collection('notes')
                    .doc(widget.noteId)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: Text("No Data Available"));
                  }
                  var noteData = snapshot.data!;
                  var title = noteData['title'] ?? 'Untitled';
                  var content = noteData['content'] ?? '';

                  return Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Text(content, style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 20),
                        Expanded(
                          child: StreamBuilder<QuerySnapshot>(
                            stream: filesStream,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              if (!snapshot.hasData ||
                                  snapshot.data!.docs.isEmpty) {
                                return const Center(child: Text("No Files Attached"));
                              }
                              return ListView.builder(
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder: (context, index) {
                                  var file = snapshot.data!.docs[index].data()
                                      as Map<String, dynamic>;
                                  return ListTile(
                                    title: Text(file['fileName']),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.download),
                                      onPressed: () =>
                                          _downloadFile(file['fileUrl']),
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
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteNote() async {
    // Confirm deletion with the user
    bool confirm = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm Delete'),
              content: const Text(
                  'Are you sure you want to delete this note and all attached files?'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: const Text('Delete'),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirm) return;

    // Delete associated files from Firebase Storage
    QuerySnapshot filesSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .collection('notes')
        .doc(widget.noteId)
        .collection('files')
        .get();

    for (DocumentSnapshot fileDoc in filesSnapshot.docs) {
      var data = fileDoc.data()
          as Map<String, dynamic>; // Correctly access and cast the data
      if (data.containsKey('fileUrl')) {
        // Check if the key exists
        String fileUrl = data['fileUrl']; // Access the file URL
        try {
          await FirebaseStorage.instance
              .refFromURL(fileUrl)
              .delete(); // Attempt to delete the file
        } catch (e) {
          print("Error deleting file from storage: $e");
        }
      }
      await fileDoc.reference
          .delete(); // Delete the Firestore document regardless of storage deletion success
    }

    // Delete the note document
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .collection('notes')
        .doc(widget.noteId)
        .delete();

    Navigator.pop(context); // Go back to the previous screen
  }

  void _downloadFile(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Could not open the file.')));
    }
  }
}

class EditNotePage extends StatefulWidget {
  final String uid;
  final String noteId;
  const EditNotePage({super.key, required this.uid, required this.noteId});

  @override
  _EditNotePageState createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  List<Uint8List> fileDataList = [];
  List<String> fileNameList = [];
  List<String> fileUrlList = [];

  @override
  void initState() {
    super.initState();
    _loadNote();
  }

  void _loadNote() async {
    // Load the existing note details
    DocumentSnapshot noteSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .collection('notes')
        .doc(widget.noteId)
        .get();

    var noteData = noteSnapshot.data() as Map<String, dynamic>;
    _titleController.text = noteData['title'];
    _contentController.text = noteData['content'];

    // Load the existing files
    QuerySnapshot filesSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .collection('notes')
        .doc(widget.noteId)
        .collection('files')
        .get();

    for (var doc in filesSnapshot.docs) {
      var fileData = doc.data() as Map<String, dynamic>;
      fileUrlList.add(fileData['fileUrl']);
      fileNameList.add(fileData['fileName']);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text('Edit Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveUpdatedNote,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Content',
              ),
              maxLines: 16,
              keyboardType: TextInputType.multiline,
            ),
            const SizedBox(height: 20),
            ...fileNameList.asMap().entries.map((entry) {
              int index = entry.key;
              String fileName = entry.value;
              return ListTile(
                title: Text(fileName),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.download),
                      onPressed: () => _downloadFile(fileUrlList[index]),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteFile(index),
                    ),
                  ],
                ),
              );
            }),
            ElevatedButton(
              onPressed: _pickFile,
              child: const Text('Add More Files'),
            ),
          ],
        ),
      ),
    );
  }

  void _downloadFile(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Could not open the file.')));
    }
  }

  void _deleteFile(int index) async {
    // Delete file from Firebase Storage and Firestore
    await FirebaseStorage.instance.refFromURL(fileUrlList[index]).delete();
    // Remove from Firestore
    // Assume each file has a unique URL or some ID stored that can be used to find it
  }

  void _pickFile() async {
    // Similar to the AddNotePage, allow adding more files
  }

  void _saveUpdatedNote() async {
    // Save the updated note details and any new files that were added
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .collection('notes')
        .doc(widget.noteId)
        .update({
      'title': _titleController.text,
      'content': _contentController.text,
    });
    // Update files if necessary
    Navigator.pop(context);
  }
}
