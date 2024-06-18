import 'package:flutter/material.dart';

class Class {
  final String name;
  final List<String> students;

  Class({required this.name, required this.students});
}

class School {
  final String name;
  final List<Class> classes;

  School({required this.name, required this.classes});
}

class UserClassesScreen extends StatefulWidget {
  const UserClassesScreen({super.key});

  @override
  State<UserClassesScreen> createState() => _UserClassesScreenState();
}

class _UserClassesScreenState extends State<UserClassesScreen> {
  School? selectedSchool;
  Class? selectedClass;
  List<String> selectedStudents = [];

  final List<School> schools = [
    School(
      name: "School A",
      classes: [
        Class(
            name: "Class A1",
            students: ["Student 1", "Student 2", "Student 3"]),
        Class(
            name: "Class A2",
            students: ["Student 4", "Student 5", "Student 6"]),
      ],
    ),
    School(
      name: "School B",
      classes: [
        Class(
            name: "Class B1",
            students: ["Student 7", "Student 8", "Student 9"]),
        Class(
            name: "Class B2",
            students: ["Student 10", "Student 11", "Student 12"]),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Classes',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: Colors.deepPurple,
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        ),
        child: Row(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: schools.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      title: Text(
                        schools[index].name,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      onTap: () {
                        setState(() {
                          selectedSchool = schools[index];
                          selectedClass = null;
                          selectedStudents.clear();
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SchoolClassesScreen(
                              school: selectedSchool!,
                              selectedStudents: selectedStudents,
                              addTopic: (topic) {
                                setState(() {
                                  selectedSchool!.classes
                                      .add(Class(name: topic, students: []));
                                });
                              },
                            ),
                          ),
                        );
                      },
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
}

class SchoolClassesScreen extends StatelessWidget {
  final School? school;
  final List<String> selectedStudents;
  final Function(String) addTopic;

  const SchoolClassesScreen(
      {super.key, required this.school,
      required this.selectedStudents,
      required this.addTopic});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          school!.name,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.deepPurple,
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        ),
        child: Column(
          children: [
            const Text(
              'Classes',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: school!.classes.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      title: Text(
                        school!.classes[index].name,
                        style: const TextStyle(fontSize: 18),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ClassStudentsScreen(
                              classInfo: school!.classes[index],
                              selectedStudents: selectedStudents,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTopicDialog(context);
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTopicDialog(BuildContext context) {
    TextEditingController topicController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add Topic"),
          content: TextField(
            controller: topicController,
            decoration: const InputDecoration(labelText: "Topic Name"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("CANCEL"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("ADD"),
              onPressed: () {
                if (topicController.text.isNotEmpty) {
                  addTopic(topicController.text);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}

class ClassStudentsScreen extends StatefulWidget {
  final Class? classInfo;
  final List<String> selectedStudents;

  const ClassStudentsScreen(
      {super.key, required this.classInfo, required this.selectedStudents});

  @override
  _ClassStudentsScreenState createState() => _ClassStudentsScreenState();
}

class _ClassStudentsScreenState extends State<ClassStudentsScreen> {
  List<String> selectedStudents = [];

  @override
  void initState() {
    super.initState();
    selectedStudents = List.from(widget.selectedStudents);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.classInfo!.name,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.deepPurple,
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        ),
        child: Column(
          children: [
            const Text(
              'Students',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: widget.classInfo!.students.length,
                itemBuilder: (context, index) {
                  final student = widget.classInfo!.students[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      title: Text(
                        student,
                        style: const TextStyle(fontSize: 18),
                      ),
                      onTap: () {
                        setState(() {
                          if (selectedStudents.contains(student)) {
                            selectedStudents.remove(student);
                          } else {
                            selectedStudents.add(student);
                          }
                        });
                      },
                      trailing: Checkbox(
                        value: selectedStudents.contains(student),
                        onChanged: (value) {
                          setState(() {
                            if (value!) {
                              selectedStudents.add(student);
                            } else {
                              selectedStudents.remove(student);
                            }
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TopicsScreen(
                      classInfo: widget.classInfo!,
                    ),
                  ),
                );
              },
              child: const Text('Submit Attendance'),
            ),
          ],
        ),
      ),
    );
  }
}

class TopicsScreen extends StatefulWidget {
  final Class classInfo; // You need to pass the current class to this screen

  const TopicsScreen({super.key, required this.classInfo});

  @override
  _TopicsScreenState createState() => _TopicsScreenState();
}

class _TopicsScreenState extends State<TopicsScreen> {
  List<List<bool>> subtopicCompletionStatus = List.generate(
    5,
    (index) => List.generate(2, (index) => false),
  );

  bool get allSubtopicsCompleted {
    return subtopicCompletionStatus
        .every((subtopicList) => subtopicList.every((status) => status));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Topics',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.deepPurple,
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: subtopicCompletionStatus.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ExpansionTile(
                      title: Text('Topic ${index + 1}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      children: List.generate(
                          2,
                          (subIndex) => ListTile(
                                title: Text('Subtopic ${subIndex + 1}',
                                    style: const TextStyle(fontSize: 16)),
                                trailing: Checkbox(
                                  value: subtopicCompletionStatus[index]
                                      [subIndex],
                                  onChanged: (value) {
                                    setState(() {
                                      subtopicCompletionStatus[index]
                                          [subIndex] = value!;
                                    });
                                  },
                                ),
                              )),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: allSubtopicsCompleted
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              GradeStudentScreen(classInfo: widget.classInfo),
                        ),
                      );
                    }
                  : null,
              child: const Text('Grade Students'),
            ),
          ],
        ),
      ),
    );
  }
}

class GradeStudentScreen extends StatefulWidget {
  final Class classInfo;

  const GradeStudentScreen({super.key, required this.classInfo});

  @override
  _GradeStudentScreenState createState() => _GradeStudentScreenState();
}

class _GradeStudentScreenState extends State<GradeStudentScreen> {
  Map<String, Map<String, double>> grades = {};

  @override
  void initState() {
    super.initState();
    for (var student in widget.classInfo.students) {
      grades[student] = {
        'interaction': 0,
        'performance': 0,
        'progress': 0,
      };
    }
  }

  Widget _buildSlider(String student, String criteria) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$criteria: ${grades[student]![criteria]!.toStringAsFixed(1)}"),
        Slider(
          min: 0,
          max: 5,
          divisions: 10,
          value: grades[student]![criteria]!,
          onChanged: (double value) {
            setState(() {
              grades[student]![criteria] = value;
            });
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Grade Students"),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView.builder(
        itemCount: widget.classInfo.students.length,
        itemBuilder: (context, index) {
          String student = widget.classInfo.students[index];
          return Card(
            child: ExpansionTile(
              title: Text(student),
              children: [
                _buildSlider(student, 'interaction'),
                _buildSlider(student, 'performance'),
                _buildSlider(student, 'progress'),
              ],
            ),
          );
        },
      ),
    );
  }
}
