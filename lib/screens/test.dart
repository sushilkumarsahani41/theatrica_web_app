import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseFirestore _db = FirebaseFirestore.instance;

void pushSampleData() async {
  var schoolA = _db.collection('schools').doc('schoolA');
  var schoolB = _db.collection('schools').doc('schoolB');

  await schoolA.set({'name': 'School A'});
  await schoolB.set({'name': 'School B'});

  // Adding classes to School A
  await schoolA.collection('classes').doc('classA1').set({
    'name': 'Class A1',
    'students': ['Student 1', 'Student 2', 'Student 3']
  });
  await schoolA.collection('classes').doc('classA2').set({
    'name': 'Class A2',
    'students': ['Student 4', 'Student 5', 'Student 6']
  });

  // Adding classes to School B
  await schoolB.collection('classes').doc('classB1').set({
    'name': 'Class B1',
    'students': ['Student 7', 'Student 8', 'Student 9']
  });
  await schoolB.collection('classes').doc('classB2').set({
    'name': 'Class B2',
    'students': ['Student 10', 'Student 11', 'Student 12']
  });
}