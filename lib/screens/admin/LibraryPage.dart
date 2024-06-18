import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  _LibraryPageState createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String selectedFolder = 'none';
  final FirebaseStorage storage = FirebaseStorage.instance;

  int filterIndex = -1;

  Future<void> _uploadFile() async {
    String? customFileName = await _promptForFileName();
    if (customFileName == null || customFileName.isEmpty) {
      print('No file name provided');
      return;
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      Uint8List fileData = result.files.first.bytes!;
      String fileExtension = result.files.first.extension ?? '';
      print(fileExtension);
      // Generate the file path
      String filePath =
          'files/$customFileName.$fileExtension'.replaceAll(' ', '_');

      try {
        Reference uploadRef = storage.ref().child(filePath);
        await uploadRef.putData(fileData);
        String downloadUrl = await uploadRef.getDownloadURL();

        // Save file details along with the storage path in Firestore
        await _firestore
            .collection('library')
            .doc(selectedFolder)
            .collection('files')
            .add({
          'name': customFileName,
          'type': fileExtension,
          'url': downloadUrl,
          'storagePath': filePath, // Save the path in Storage for later access
          'timestamp': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        print('Error uploading file: $e');
      }
    } else {
      print('No file selected');
    }
  }

  Future<String?> _promptForFileName() async {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        TextEditingController fileNameController = TextEditingController();
        return AlertDialog(
          title: const Text('Enter File Name'),
          content: TextField(
            controller: fileNameController,
            decoration: const InputDecoration(hintText: "File name"),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss and return nothing
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                if (fileNameController.text.isNotEmpty) {
                  Navigator.of(context)
                      .pop(fileNameController.text); // Return the file name
                } else {
                  print('File name cannot be empty');
                  // Optionally, you could shake the dialog or show a message here
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Library',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: _buildFoldersSection(),
            ),
            Expanded(
              flex: 3,
              child: selectedFolder == 'none'
                  ? const Center(child: Text('Please Select Folder First'))
                  : _buildFilesSection(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoldersSection() {
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
            child: Text('Folders',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('library').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                var folders = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: folders.length,
                  itemBuilder: (context, index) {
                    return _buildSquareButton(
                        folders[index]['name'], folders[index].id, index);
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
                onPressed: _addNewFolder,
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
                      "Add Folder",
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

  void _addNewFolder() async {
    String? folderName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        TextEditingController folderNameController = TextEditingController();
        return AlertDialog(
          title: const Text('Add New Folder'),
          content: TextField(
            controller: folderNameController,
            decoration: const InputDecoration(hintText: "Enter folder name"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Dismiss the dialog without any action
              },
            ),
            TextButton(
              child: const Text('Create'),
              onPressed: () {
                if (folderNameController.text.isNotEmpty) {
                  Navigator.of(context).pop(
                      folderNameController.text); // Return the entered text
                } else {
                  // Optionally show an error or shake animation if the field is empty
                  print('Folder name cannot be empty');
                }
              },
            ),
          ],
        );
      },
    );

    // Check if a folder name was entered and returned from the dialog
    if (folderName != null && folderName.isNotEmpty) {
      // Add new folder to Firestore
      await _firestore
          .collection('library')
          .add({
            'name': folderName,
            // You can add more fields as needed
          })
          .then((value) => print('Folder added'))
          .catchError((error) => print('Failed to add folder: $error'));
    }
  }

  Widget _buildFilesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Files',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('library')
                  .doc(selectedFolder)
                  .collection('files')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                }
                if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Folder is empty'));
                }
                var files = snapshot.data!.docs;
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8,
                    crossAxisSpacing: 15.0,
                    mainAxisSpacing: 15.0,
                  ),
                  itemCount: files.length,
                  itemBuilder: (context, index) {
                    var file = files[index];
                    return _buildFileItem(file);
                  },
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.upload_file_rounded,
                    size: 60, color: Colors.deepPurpleAccent),
                onPressed: _uploadFile,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFileItem(QueryDocumentSnapshot file) {
    return InkWell(
      onTap: () async {
        String url = file['url'];
        if (await canLaunch(url)) {
          await launch(url, webOnlyWindowName: '_blank');
        } else {
          print('Could not launch $url');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open the file.')),
          );
        }
      },
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white54,
          boxShadow: [
            BoxShadow(
                blurRadius: 9, spreadRadius: 2, color: Colors.grey.shade300)
          ],
          border: Border.all(color: Colors.deepPurple.shade100),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              flex: 2,
              child: Center(
                child: Icon(
                  _getFileIcon(file['type'].toString().toLowerCase()),
                  size: 50,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              flex: 1,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10)),
                ),
                padding: const EdgeInsets.only(left: 10),
                width: 200,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(shortenText(file['name']),
                        overflow: TextOverflow.fade, maxLines: 1),
                    IconButton(
                        onPressed: () {
                          _deleteFile(file.id);
                        },
                        icon: const Icon(Icons.delete, size: 20)),
                  ],
                ),
              ),
            ),
          ],
        ),
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

  Widget _buildSquareButton(String text, String folderId, int index) {
    return InkWell(
      onTap: () {
        setState(() {
          filterIndex = index;
          selectedFolder = folderId;
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: 60,
          padding: const EdgeInsets.only(left: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                width: 2,
                color:
                    (filterIndex == index) ? Colors.deepPurple : Colors.grey),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          _deleteFolder(folderId);
                        },
                        icon: const Icon(Icons.delete, size: 20)),
                    const Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String shortenText(String inputText) {
    return inputText.length <= 7 ? inputText : inputText.substring(0, 7);
  }

  void _deleteFile(String fileId) async {
    bool confirmDelete = await _showDeleteConfirmationDialog(
        'Are you sure you want to delete this file?');
    if (confirmDelete) {
      // Retrieve the document to get the storage path
      var fileDoc = await _firestore.collection('files').doc(fileId).get();
      if (fileDoc.exists) {
        String storagePath = fileDoc.data()!['storagePath'];

        // Delete the file from Firestore
        await _firestore
            .collection('files')
            .doc(fileId)
            .delete()
            .then((_) async {
          // Delete the file from Firebase Storage
          await storage
              .ref()
              .child(storagePath)
              .delete()
              .then((_) => print('File deleted from Firebase Storage'))
              .catchError((error) =>
                  print('Failed to delete file from Storage: $error'));
          print('File deleted successfully from Firestore');
        }).catchError(
                // ignore: invalid_return_type_for_catch_error
                (error) => print('Failed to delete file: ${error ?? ""}'));
      }
    }
  }

  void _deleteFolder(String folderId) async {
    bool confirmDelete = await _showDeleteConfirmationDialog(
        'Are you sure you want to delete this folder? All contained files will be lost.');
    if (confirmDelete) {
      _firestore
          .collection('library')
          .doc(folderId)
          .delete()
          .then((_) => print('Folder deleted successfully'))
          .catchError((error) => print('Failed to delete folder: $error'));
    }
  }

  Future<bool> _showDeleteConfirmationDialog(String message) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm Deletion'),
              content: Text(message),
              actions: <Widget>[
                TextButton(
                  child: const Text('No'),
                  onPressed: () {
                    Navigator.of(context)
                        .pop(false); // User pressed 'No', do not delete.
                  },
                ),
                TextButton(
                  child: const Text('Yes'),
                  onPressed: () {
                    Navigator.of(context).pop(
                        true); // User pressed 'Yes', proceed with deletion.
                  },
                ),
              ],
            );
          },
        ) ??
        false; // Returning false if null is returned (dialog dismissed).
  }
}
