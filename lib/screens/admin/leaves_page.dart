import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LeavesPage extends StatefulWidget {
  const LeavesPage({super.key});

  @override
  State<LeavesPage> createState() => _LeavesPageState();
}

class _LeavesPageState extends State<LeavesPage> {
  int filterIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaves Page'),
      ),
      body: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRequestsContainer(),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: _buildLeaveDetailsContainer(),
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

  Widget _buildRequestsContainer() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Requests', style: TextStyle(fontSize: 18)),
          Row(
            children: List.generate(3, (index) {
              return Row(
                children: [
                  _buildSquareButton(['Awaited', 'Approved', 'Rejected'][index],
                      () {
                    setState(() {
                      filterIndex = index;
                    });
                  }, index),
                  SizedBox(width: index < 2 ? 10 : 0),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveDetailsContainer() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('leaves')
          .where('status', isEqualTo: _getStatusFilter())
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("Error loading data"));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.data?.docs.isEmpty ?? true) {
          return const Center(child: Text("No leaves available"));
        }

        final data = snapshot.data!.docs;
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 15.0,
            mainAxisSpacing: 15.0,
            mainAxisExtent: 400,
          ),
          shrinkWrap: true,
          itemCount: data.length,
          itemBuilder: (context, index) {
            final docData = data[index];
            return _buildLeaveItem(docData);
          },
        );
      },
    );
  }

  Widget _buildLeaveItem(QueryDocumentSnapshot<Map<String, dynamic>> docData) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                docData.data()['type'],
                style: const TextStyle(fontSize: 18),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: (docData.data()['status'] == 'approved')
                      ? Colors.green.shade100
                      : (docData.data()['status'] == 'rejected')
                          ? Colors.red.shade100
                          : Colors.yellow.shade100,
                  border: Border.all(
                    color: (docData.data()['status'] == 'approved')
                        ? Colors.green
                        : (docData.data()['status'] == 'rejected')
                            ? Colors.red
                            : Colors.yellow,
                  ),
                ),
                child: Text(
                  docData.data()['status'],
                  style: TextStyle(
                    color: (docData.data()['status'] == 'approved')
                        ? Colors.green
                        : (docData.data()['status'] == 'rejected')
                            ? Colors.red
                            : const Color.fromARGB(255, 247, 184, 13),
                  ),
                ),
              ),
            ],
          ),
          Divider(
            thickness: 1,
            color: Colors.grey[400],
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              docData.data()['subject'],
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Applied Date: ${timeStampToDate(docData.data()['created-at'])}',
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'User: ${docData.data()['name']}',
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Description: ${docData.data()['reason']}',
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: DataTable(
              dividerThickness: 0,
              columns: const [
                DataColumn(
                  label: Text(
                    'From',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "To",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              rows: [
                DataRow(
                  cells: [
                    DataCell(Text(
                      timeStampToDate(docData.data()['start-date']),
                    )),
                    DataCell(Text(
                      timeStampToDate(docData.data()['end-date']),
                    )),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              (filterIndex == 1)
                  ? const SizedBox()
                  : ElevatedButton(
                      onPressed: () {
                        // Accept leave logic
                        _acceptLeave(docData.id);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Accept',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
              const SizedBox(width: 10),
              (filterIndex == 2)
                  ? Container()
                  : ElevatedButton(
                      onPressed: () {
                        // Reject leave logic
                        _rejectLeave(docData.id);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Reject',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
  }

  String timeStampToDate(Timestamp time) {
    DateTime date = time.toDate();
    return DateFormat('MMM dd, yyyy').format(date);
  }

  Widget _buildSquareButton(String text, VoidCallback onPressed, int index) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: 70,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: (filterIndex == index) ? Colors.deepPurple : Colors.white,
          border: Border.all(color: Colors.black),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: (filterIndex == index) ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  String _getStatusFilter() {
    return ['awaited', 'approved', 'rejected'][filterIndex];
  }

  void _acceptLeave(String id) async {
    await _updateLeaveStatus(id, 'approved');
  }

  void _rejectLeave(String id) async {
    await _updateLeaveStatus(id, 'rejected');
  }

  Future<void> _updateLeaveStatus(String id, String status) async {
    try {
      await FirebaseFirestore.instance
          .collection('leaves')
          .doc(id)
          .update({'status': status});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating status: $e')),
        );
      }
    }
  }
}
