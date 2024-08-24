import "package:flutter/material.dart";
import "package:learn_database/Screens/note_detail.dart";
import "package:learn_database/utils/database_helper.dart";
import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:learn_database/models/note.dart';

import "../models/note.dart";

class NoteList extends StatefulWidget {
  const NoteList({super.key});

  @override
  State<NoteList> createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Note> noteList = [];
  int count = 0;

  @override
  Widget build(BuildContext context) {
    if(noteList == null){
      updateListView();
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notes"),
        backgroundColor: Colors.lightGreen,
      ),
      body: getNoteListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          debugPrint('FAB clicked');
          navigateToDetail(Note(
            id: 0,
            title: '',
            description: '',
            date: '',
            priority: 2, // Default priority or any other default value
          ), 'Add Note');
        },
        tooltip: 'Add Note',
        child: Icon(Icons.add),
      ),

    );
  }

  ListView getNoteListView() {
    TextStyle? titleStyle = Theme.of(context).textTheme.headlineSmall;
    return ListView.builder(
        itemCount: count,
        itemBuilder: (BuildContext context, int position) {
          return Card(
            color: Colors.white,
            elevation: 2.0,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    getPriorityColor(this.noteList[position].priority),
                child: getPriorityIcon(this.noteList[position].priority),
              ),
              title: Text(
                this.noteList[position].title,
                style: titleStyle,
              ),
              subtitle: Text(this.noteList[position].date),
              trailing: GestureDetector(
                onTap: () {
                  _delete(context, noteList[position]);
                },
                child: const Icon(
                  Icons.delete,
                  color: Colors.grey,
                ),
              ),
              onTap: () {
                navigateToDetail(this.noteList[position],"Edit Note");
              },
            ),
          );
        });
  }

  //Returns the priority color
  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.yellow;
      default:
        return Colors.yellow;
    }
  }

  //Returns the priority icon
  Icon getPriorityIcon(int priority) {
    switch (priority) {
      case 1:
        return Icon(Icons.play_arrow);
      case 2:
        return Icon(Icons.keyboard_arrow_right);
      default:
        return Icon(Icons.keyboard_arrow_right);
    }
  }

  void _delete(BuildContext context, Note note) async {
    int result = await databaseHelper.deleteNote(note.id);
    if (result != 0) {
      _showSnackBar(context, 'Note Deleted Successfully');
      updateListView();
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void navigateToDetail(Note note,String title) async{
    bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return NoteDetail(note,title);
    }));
    if(result == true){
      updateListView();
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
      noteListFuture.then((noteList){
        setState(() {
          this.noteList = noteList;
          this.count = noteList.length;
        });
      });
    });
  }
}
