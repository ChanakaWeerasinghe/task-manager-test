import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/bloc/todo_bloc/todo_bloc.dart';
import 'package:task_manager/helpers/database_helper.dart';
import 'package:task_manager/helpers/route_animation.dart';
import 'package:task_manager/models/task_model.dart';
import 'home_screen.dart';
import 'package:intl/intl.dart';
import 'package:toast/toast.dart';

class AddTaskScreen extends StatefulWidget {
  final Function updateTaskList;
  final Task task;

  AddTaskScreen({this.updateTaskList, this.task});

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _priority;
  String _description = '';
  DateTime _date = DateTime.now();
  DateTime _date_created = DateTime.now();
  TextEditingController _dateController = TextEditingController();
  TextEditingController _dateCreatedController = TextEditingController();
  final DateFormat _dateFormatter = DateFormat('MMM dd, yyyy');
  final String imagePath =
      "https://cdni.iconscout.com/illustration/premium/thumb/young-business-woman-working-on-todo-list-2644452-2206521.png";
  final List<String> _priorities = ['Low', 'Medium', 'High'];

  @override
  void initState() {
    super.initState();

    if (widget.task != null) {
      _title = widget.task.title;
      _date = widget.task.date;
      _date_created = widget.task.date_created;
      _priority = widget.task.priority;
      _description = widget.task.description;
    }

    _dateController.text = _dateFormatter.format(_date);
    _dateCreatedController.text = _dateFormatter.format(_date_created);
  }

  @override
  void dispose() {
    _dateController.dispose();
    _dateCreatedController.dispose();
    super.dispose();
  }

  _handleDatePicker() async {
    final DateTime date = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null && date != _date) {
      setState(() {
        _date = date;
      });
      _dateController.text = _dateFormatter.format(date);
    }
  }

  _handleCreateDatePicker() async {
    final DateTime date = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null && date != _date_created) {
      setState(() {
        _date_created = date;
      });
      _dateCreatedController.text = _dateFormatter.format(date);
    }
  }

  _delete() {
    BlocProvider.of<TodoBloc>(context).add(DeleteTask(widget.task));
  }

  _submit() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      print('$_title, $_date, $_priority, $_description, $_date_created,');

      Task task = Task(
          title: _title,
          date: _date,
          date_created: _date_created,
          priority: _priority,
          description: _description);
      if (widget.task == null) {
        // Insert the task to our user's database
        task.status = 0;
        BlocProvider.of<TodoBloc>(context).add(InsertTask(task));
      } else {
        // Update the task
        task.id = widget.task.id;
        task.status = widget.task.status;
        BlocProvider.of<TodoBloc>(context).add(UpdateTask(task));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TodoBloc, TodoState>(
      listener: (context, state) {
        if (state is InsertSuccess) {
          Toast.show("New Task Added", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
          Navigator.of(context).push(CustomRoute(HomeScreen()));

          widget.updateTaskList();
        } else if (state is InsertFail) {
          Toast.show("Task Not Added !", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        } else if (state is UpdateSuccess) {
          Toast.show("Task Updated", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
          Navigator.of(context).push(CustomRoute(HomeScreen()));
          widget.updateTaskList();
        } else if (state is UpdateFail) {
          Toast.show("Task Not Updated !", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        } else if (state is DeleteSuccess) {
          Navigator.of(context).push(CustomRoute(HomeScreen()));
          widget.updateTaskList();
          Toast.show("Task Deleted", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        } else if (state is DeleteFail) {
          Navigator.pop(context);
          widget.updateTaskList();
          Toast.show("Task Not Deleted", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        }

        // TODO: implement listener
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(250, 250, 250, 1),
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
              ),
              onPressed: () => Navigator.pop(context)),
          title: Row(children: [
            Text(
              widget.task == null ? 'Add Task' : 'Update Task',
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 20.0,
                fontWeight: FontWeight.normal,
              ),
            ),
          ]),
          centerTitle: false,
          elevation: 0,
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Image.network(imagePath, height: 120),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 5.0),
                          child: TextFormField(
                            style: TextStyle(fontSize: 18.0),
                            decoration: InputDecoration(
                              labelText: 'Title',
                              labelStyle: TextStyle(fontSize: 18.0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            validator: (input) => input.trim().isEmpty
                                ? 'Please enter a task title'
                                : null,
                            onSaved: (input) => _title = input,
                            initialValue: _title,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 15.0),
                          child: TextFormField(
                            style: TextStyle(fontSize: 18.0),
                            decoration: InputDecoration(
                              labelText: 'Description',
                              labelStyle: TextStyle(fontSize: 18.0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            validator: (input) => input.trim().isEmpty
                                ? 'Please enter a task description'
                                : null,
                            onSaved: (input) => _description = input,
                            initialValue: _description,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          child: TextFormField(
                            readOnly: true,
                            controller: _dateController,
                            style: TextStyle(fontSize: 18.0),
                            onTap: _handleDatePicker,
                            decoration: InputDecoration(
                              labelText: 'Due Date',
                              labelStyle: TextStyle(fontSize: 18.0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          child: TextFormField(
                            readOnly: true,
                            controller: _dateCreatedController,
                            style: TextStyle(fontSize: 18.0),
                            onTap: _handleCreateDatePicker,
                            decoration: InputDecoration(
                              labelText: 'Created Date',
                              labelStyle: TextStyle(fontSize: 18.0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          child: DropdownButtonFormField(
                            isDense: true,
                            icon: Icon(Icons.arrow_drop_down_circle),
                            iconSize: 22.0,
                            iconEnabledColor: Theme.of(context).primaryColor,
                            items: _priorities.map((String priority) {
                              return DropdownMenuItem(
                                value: priority,
                                child: Text(
                                  priority,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18.0,
                                  ),
                                ),
                              );
                            }).toList(),
                            style: TextStyle(fontSize: 18.0),
                            decoration: InputDecoration(
                              labelText: 'Priority',
                              labelStyle: TextStyle(fontSize: 18.0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            validator: (input) => _priority == null
                                ? 'Please select a priority level'
                                : null,
                            onChanged: (value) {
                              setState(() {
                                _priority = value;
                              });
                            },
                            value: _priority,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 20.0),
                          height: 50.0,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.cyan,
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          // ignore: deprecated_member_use
                          child: TextButton(
                            child: Text(
                              widget.task == null ? 'Add' : 'Update',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.0,
                              ),
                            ),
                            onPressed: _submit,
                          ),
                        ),
                        widget.task != null
                            ? Container(
                                margin: EdgeInsets.symmetric(vertical: 0.0),
                                height: 50.0,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.redAccent,
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                // ignore: deprecated_member_use
                                child: TextButton(
                                  child: Text(
                                    'Delete',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20.0,
                                    ),
                                  ),
                                  onPressed: _delete,
                                ),
                              )
                            : SizedBox.shrink(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
