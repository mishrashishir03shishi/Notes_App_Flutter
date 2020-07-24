import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_app2/models/note.dart';
import 'package:flutter_app2/utils/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';

class NoteDetail extends StatefulWidget {
  final String appBarTitle;
  final Note note;

  NoteDetail(this.note, this.appBarTitle);

  @override
  State<StatefulWidget> createState() {
    return NoteDetailState(this.note, this.appBarTitle);
    throw UnimplementedError();
  }
}

class NoteDetailState extends State<NoteDetail> {
  final _formKey = GlobalKey<FormState>();
  static var _priorities = ['High', 'Low'];
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  String appBarTitle;
  Note note;
  DatabaseHelper helper = DatabaseHelper();

  NoteDetailState(this.note, this.appBarTitle);

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;
    titleController.text = note.title;
    descriptionController.text = note.description;

    return WillPopScope(
        // ignore: missing_return
        onWillPop: () {
          moveToLastScreen();
        },
        child: Scaffold(
            appBar: AppBar(
              title: Text(
                appBarTitle,
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  moveToLastScreen();
                },
              ),
            ),
            body: Form(
              key: _formKey,
              child: Padding(
                padding: EdgeInsets.only(top: 15.0, left: 10.0, bottom: 10.0),
                child: ListView(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              'Priority',
                              style: textStyle,
                            ),
                          ),
                          Container(width: 5.0),
                          Expanded(
                              child: DropdownButton(
                            items: _priorities.map((String dropDownStringItem) {
                              return DropdownMenuItem(
                                value: dropDownStringItem,
                                child: Text(dropDownStringItem),
                              );
                            }).toList(),
                            style: textStyle,
                            value: getPriorityAsString(note.priority),
                            onChanged: (valueSelectedByUser) {
                              setState(() {
                                debugPrint(
                                    'User Selected $valueSelectedByUser');
                                updatePriorityAsInt(valueSelectedByUser);
                              });
                            },
                          )),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10.0, bottom: 15.0),
                      child: TextFormField(
                        // ignore: missing_return
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter title';
                          }
                          return null;
                        },
                        controller: titleController,
                        style: textStyle,
                        onChanged: (value) {
                          debugPrint('Something changed in title text Field');
                          updateTitle();
                        },
                        decoration: InputDecoration(
                          labelText: 'Title',
                          labelStyle: textStyle,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10.0, bottom: 15.0),
                      child: TextField(
                        controller: descriptionController,
                        style: textStyle,
                        onChanged: (value) {
                          debugPrint(
                              'Something changed in description text Field');
                          updateDescription();
                        },
                        decoration: InputDecoration(
                          labelText: 'Description',
                          labelStyle: textStyle,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: RaisedButton(
                              color: Theme.of(context).primaryColorDark,
                              textColor: Theme.of(context).primaryColorLight,
                              child: Text(
                                'Save',
                                textScaleFactor: 1.5,
                              ),
                              onPressed: () {
                                if (_formKey.currentState.validate()) {
                                  setState(() {
                                    debugPrint('Save Button Was Clicked');
                                    _save();
                                  });
                                }
                              },
                            ),
                          ),
                          Container(
                            width: 5.0,
                          ),
                          Expanded(
                            child: RaisedButton(
                              color: Theme.of(context).primaryColorDark,
                              textColor: Theme.of(context).primaryColorLight,
                              child: Text(
                                'Delete',
                                textScaleFactor: 1.5,
                              ),
                              onPressed: () {
                                setState(() {
                                  debugPrint('Delete Button Was Clicked');
                                  _delete();
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )));
    throw UnimplementedError();
  }

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

  String getPriorityAsString(int value) {
    String priority;
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

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  void updateTitle() {
    note.title = titleController.text;
  }

  void updateDescription() {
    note.description = descriptionController.text;
  }

  void _delete() async {
    moveToLastScreen();
    if (note.id == null) {
      _showAlertDialog('Status', 'No Note Was Deleted');
      return;
    }
    int result = await helper.deleteNote(note.id);
    if (result != 0) {
      _showAlertDialog('Status', 'NoteDeleted Successfully');
    } else {
      _showAlertDialog('Status', 'Error Deleting Note');
    }
  }

  void _save() async {
    moveToLastScreen();
    note.date = DateFormat.yMMMd().format(DateTime.now());
    int result;
    if (note.id != null) {
      result = await helper.updateNote(note);
    } else {
      result = await helper.insertNote(note);
    }
    if (result != 0) {
      _showAlertDialog('Status', 'Note saved Successfully');
    } else {
      _showAlertDialog('Status', 'Problem Saving Note');
    }
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }
}
