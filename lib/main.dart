import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'model/lesson.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        home: MyHomePage());
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var formKey = GlobalKey<FormState>();
  int selectedCourseCredit = 1;
  double selectedCourseGrade = 4;
  double average = 0;
  int uniqID = 1;
  late List<Lesson> createdLessons;
  late TextEditingController nameController;

  @override
  void initState() {
    super.initState();
    createdLessons = [];
    nameController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Grade Calculator"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            margin: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Form(
                  key: formKey,
                  child: TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.fact_check),
                      hintText: "Enter your score",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                      ),
                    ),
                    maxLength: 20,
                    validator: (value) {
                      if (value!.length > 0) {
                        return null;
                      } else
                        return "Can not assign empty value!";
                    },
                    onSaved: (newValue) {
                      setState(() {
                        createdLessons.add(
                          Lesson(newValue!, selectedCourseGrade,
                              selectedCourseCredit, randomColor()),
                        );
                        selectedCourseCredit = 1;
                        selectedCourseGrade = 4;
                        nameController.text = "";
                        calculateAverage();
                      });
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: selectedCourseCredit,
                            items: courseCredits(),
                            onChanged: (value) {
                              setState(() {
                                selectedCourseCredit = value!;
                              });
                            },
                          ),
                        ),
                      ),
                      Container(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<double>(
                            value: selectedCourseGrade,
                            items: courseGrades(),
                            onChanged: (value) {
                              setState(() {
                                selectedCourseGrade = value!;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(18),
                      ),
                      color: Colors.blue.shade500),
                  margin: EdgeInsets.only(top: 15),
                  height: 50,
                  child: Center(
                    child: createdLessons.length != 0
                        ? Text(
                            "Your average is : ${average.toStringAsFixed(2)}",
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          )
                        : Text(
                            "Please enter your scores",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 15),
              child: ListView.builder(
                itemCount: createdLessons.length,
                itemBuilder: _myListBuilder,
              ),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (formKey.currentState!.validate()) {
            formKey.currentState!.save();
          }
        },
        child: Icon(Icons.add),
        elevation: 12,
      ),
    );
  }

  courseCredits() {
    List<DropdownMenuItem<int>> data = [];
    for (int i = 1; i <= 10; i++) {
      data.add(
        DropdownMenuItem(
          value: i,
          child: Text("$i Credit"),
        ),
      );
    }
    return data;
  }

  courseGrades() {
    List<DropdownMenuItem<double>> data = [];
    var grades = [
      ["AA", 4],
      ["BA", 3.5],
      ["BB", 3],
      ["CB", 2.5],
      ["CC", 2],
      ["DC", 1.5],
      ["DD", 1],
      ["FF", 0]
    ];

    for (var item in grades) {
      data.add(
        DropdownMenuItem(
          child: Text(item[0].toString()),
          value: double.parse(item[1].toString()),
        ),
      );
    }
    return data;
  }

  Widget _myListBuilder(BuildContext context, int index) {
    uniqID++;
    calculateAverage();
    return Dismissible(
      key: Key(uniqID.toString()),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) {
        setState(() {
          createdLessons.removeAt(index);
          calculateAverage();
        });
      },
      child: Card(
          margin: EdgeInsets.symmetric(vertical: 5),
          elevation: 8,
          child: Container(
            decoration: BoxDecoration(
                border:
                    Border.all(width: 2, color: createdLessons[index].color)),
            child: ListTile(
              title: Text(createdLessons[index].name),
              subtitle: Text(
                  "Course credit: ${createdLessons[index].courseCredit.toString()}"),
              leading: CircleAvatar(
                backgroundColor: createdLessons[index].color,
                child: Text(createdLessons[index].name[0]),
              ),
              trailing:
                  Text(checkCourseGrade(createdLessons[index].courseGrade)),
            ),
          )),
    );
  }

  checkCourseGrade(grade) {
    var data = {
      4: "AA",
      3.5: "BA",
      3: "BB",
      2.5: "CB",
      2: "CC",
      1.5: "DC",
      1: "DD",
      0: "FF"
    };
    return data[grade];
  }

  Color randomColor() {
    return Color.fromARGB(
      255,
      math.Random().nextInt(255),
      math.Random().nextInt(255),
      math.Random().nextInt(255),
    );
  }

  calculateAverage() {
    double totalGrade = 0;
    double totalCredit = 0;

    for (var l in createdLessons) {
      var kredi = l.courseCredit;
      var harfDegeri = l.courseGrade;
      totalGrade = totalGrade + (harfDegeri * kredi);
      totalCredit += kredi;
    }

    average = totalGrade / totalCredit;
  }
}
