import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:learn_database/utils/database_helper.dart';

import '../models/note.dart';

class NoteDetail extends StatefulWidget {
  final String appBarTitle;
  final Note note;

  NoteDetail(this.note, this.appBarTitle);

  @override
  State<StatefulWidget> createState() {
    return NoteDetailState(this.note, this.appBarTitle);
  }
}

class NoteDetailState extends State<NoteDetail> {
  String appBarTitle;
  Note note;
  static var _priorities = ['High', 'Low'];
  DatabaseHelper databaseHelper = DatabaseHelper();

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  NoteDetailState(this.note, this.appBarTitle);

  @override
  Widget build(BuildContext context) {
    TextStyle? textStyle = Theme.of(context).textTheme.bodyLarge;
    titleController.text = note.title;
    descriptionController.text = note.description;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Note',
        ),
        backgroundColor: Colors.lightGreen,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // Write some code to control things, when user press back button in AppBar
              moveToLastScreen();
            }),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
        child: ListView(
          children: <Widget>[
            // First element
            ListTile(
              title: DropdownButton(
                  items: _priorities.map((String dropDownStringItem) {
                    return DropdownMenuItem<String>(
                      value: dropDownStringItem,
                      child: Text(dropDownStringItem),
                    );
                  }).toList(),
                  style: textStyle,
                  value: getPriorityAsString(note.priority),
                  onChanged: (valueSelectedByUser) {
                    setState(() {
                      debugPrint('User selected $valueSelectedByUser');
                      updatePriorityAsInt(valueSelectedByUser!);
                    });
                  }),
            ),

            // Second Element
            Padding(
              padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: TextField(
                controller: titleController,
                style: textStyle,
                onChanged: (value) {
                  debugPrint('Something changed in Title Text Field');
                  updateTitle();
                },
                decoration: InputDecoration(
                    labelText: 'Title',
                    labelStyle: textStyle,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0))),
              ),
            ),

            // Third Element
            Padding(
              padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: TextField(
                controller: descriptionController,
                style: textStyle,
                onChanged: (value) {
                  debugPrint('Something changed in Description Text Field');
                  updateDescription();
                },
                decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: textStyle,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0))),
              ),
            ),

            // Fourth Element
            Padding(
              padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _save();
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.black, // Text color
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  Container(
                    width: 5.0,
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _delete();
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.black, // Text color
                      ),
                      child:
                          const Text('Delete', style: TextStyle(fontSize: 20)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void moveToLastScreen() {
    Navigator.pop(context,true);
  }

  //Convert the String priority in the form of Integer before saving it to Database
  void updatePriorityAsInt(String value) {
    switch (value) {
      case 'High':
        note.priority = 1;
        break;
      case 'Low':
        note.priority = 2;
        break;
    }
  }

  //Convert the Integer priority in the form of String before saving it to Database
  String getPriorityAsString(int value) {
    String priority = '';
    switch (value) {
      case 1:
        priority = _priorities[0];
        break;
      case 2:
        priority = _priorities[1];
        break;
    }
    return priority;
  }

  //Update the title of Note object
  void updateTitle(){
    note.title = titleController.text;
  }

  //Update the description of Note object
  void updateDescription(){
    note.description = descriptionController.text;
  }

  void _save() async {
    moveToLastScreen();
    note.date = DateFormat.yMMMd().format(DateTime.now());
    try {
      int result;
      if (note.id != 0) { // Update operation
        result = await databaseHelper.updateNote(note);
      } else { // Insert operation
        result = await databaseHelper.insertNote(note);
      }

      if (result != 0) {
        _showAlertDialog('Status', 'Note Saved Successfully');
      } else {
        _showAlertDialog('Status', 'Error While Saving Note');
      }
    } catch (e) {
      debugPrint('Error while saving note: $e');
      _showAlertDialog('Status', 'Error While Saving Note: $e');
    }
  }


  void _delete() async {

    //case 1: if user is trying to delete the new note like when he clicked FAB
    if(note.id == null) {
      _showAlertDialog("Status", "No Note Was Detected");
      return;
    }

    //case 2: User is trying to delete the old note
    int result =await databaseHelper.deleteNote(note.id);
    if(result!=0){
      _showAlertDialog("Status", "Note Deleted Successfully");
    } else {
      _showAlertDialog("Status", "Error Occur While Deleting Note");
    }
  }

  void _showAlertDialog(String title, String message) {
    if (!mounted) return; // Check if the widget is still mounted

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
