import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:task_manager/helpers/database_helper.dart';
import 'package:task_manager/helpers/route_animation.dart';
import 'package:task_manager/models/task_model.dart';
import 'history_screen.dart';
import 'package:task_manager/screens/add_task_screen.dart';
import 'package:intl/intl.dart';
import 'settings_screen.dart';
import 'package:toast/toast.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<List<Task>> _taskList;
  final DateFormat _dateFormatter = DateFormat('MMM dd, yyyy');
  bool standardSelected = false;

  @override
  void initState() {
    super.initState();
    _updateTaskList();
  }

  _updateTaskList() {
    setState(() {
      _taskList = DatabaseHelper.instance.getTaskList();
    });
  }

  Future<bool> onBackPressed() {
    return SystemNavigator.pop();
  }

  Widget _buildTask(Task task) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        children: <Widget>[
          if (task.status == 0)
            Card(
              child: ListTile(
                title: Container(
                  child: Column(
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 16.0,
                          decoration: task.status == 0
                              ? TextDecoration.none
                              : TextDecoration.lineThrough,
                        ),
                      ),
                      Divider(
                        // Add a Divider widget here
                        color: Colors.black,
                        height: 10,
                      ),
                    ],
                  ),
                ),
                subtitle: new RichText(
                  textAlign: TextAlign.left,
                  text: new TextSpan(
                    style: new TextStyle(
                      fontSize: 14.0,
                      color: Colors.black,
                    ),
                    children: <TextSpan>[
                      new TextSpan(
                          text: 'Description: ${task.description}\n',
                          style: new TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 10.0,
                          )),
                      new TextSpan(
                          text:
                              '\nDue Date: ${_dateFormatter.format(task.date)}\n',
                          style: new TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 10.0,
                          )),new TextSpan(
                          text:
                              'Created Date: ${_dateFormatter.format(task.date_created)}\n',
                          style: new TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 10.0,
                          )),
                      new TextSpan(
                          text: task.priority + '\n',
                          style: new TextStyle(
                              fontWeight: FontWeight.bold,
                              color: task.priority == "High"
                                  ? Colors.pinkAccent
                                  : task.priority == "Medium"
                                      ? Colors.green[400]
                                      : Colors.black54)),
                    ],
                  ),
                ),
                trailing: Wrap(
                  direction: Axis.horizontal,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text("Incomplete"),
                    IconButton(
                      icon: Icon(
                        Icons.check,
                      ),
                      color: Colors.green,
                      splashColor: Colors.white,
                      onPressed: () {
                        setState(() {
                          task.status = 1;
                          DatabaseHelper.instance.updateTask(task);
                          Toast.show("Task Completed", context,
                              duration: Toast.LENGTH_LONG,
                              gravity: Toast.BOTTOM);
                          _updateTaskList();
                          standardSelected = !standardSelected;
                        });
                      },
                    )
                  ],
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddTaskScreen(
                      updateTaskList: _updateTaskList,
                      task: task,
                    ),
                  ),
                ),
              ),
            )
          //Divider(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onBackPressed,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          foregroundColor: Colors.white,
          child: Icon(Icons.add_outlined),
          onPressed: () => Navigator.of(context).push(CustomRoute(AddTaskScreen(
            updateTaskList: _updateTaskList,
          ))),
        ),
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(250, 250, 250, 1),
          leading: IconButton(
              icon: Icon(
                Icons.calendar_today_outlined,
                color: Colors.black,
              ),
              onPressed: null),
          title: Row(
            children: [
              Text(
                "Task Manager",
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 20.0,
                  fontWeight: FontWeight.normal,
                  letterSpacing: -1.2,
                ),
              ),
              Text(
                " App",
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontSize: 20.0,
                  fontWeight: FontWeight.normal,
                  letterSpacing: 0,
                ),
              )
            ],
          ),
          centerTitle: false,
          elevation: 0,
          actions: [
            Container(
              margin: const EdgeInsets.all(0),
              child: IconButton(
                  icon: Icon(Icons.history_outlined),
                  iconSize: 25.0,
                  color: Colors.black,
                  onPressed: () =>
                      Navigator.of(context).push(CustomRoute(HistoryScreen()))
),
            ),
            Container(
              margin: const EdgeInsets.all(6.0),
              child: IconButton(
                  icon: Icon(Icons.settings_outlined),
                  iconSize: 25.0,
                  color: Colors.black,
                  onPressed: () =>
                      Navigator.of(context).push(CustomRoute(Settings()))
                ),
            )
          ],
        ),
        body: FutureBuilder(
          future: _taskList,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            final int completedTaskCount = snapshot.data
                .where((Task task) => task.status == 0)
                .toList()
                .length;

            return ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 0.0),
              itemCount: 1 + snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  return Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 0.0, vertical: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          margin:
                              const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
                          padding: const EdgeInsets.all(10.0),
                          decoration: new BoxDecoration(
                            shape: BoxShape.rectangle,
                            color: Color.fromRGBO(240, 240, 240, 1.0),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                          ),
                          child: Center(
                            child: Text(
                              'You have [ $completedTaskCount ] pending task out of [ ${snapshot.data.length} ]',
                              style: TextStyle(
                                color: Colors.blueGrey,
                                fontSize: 15.0,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                }
                return _buildTask(snapshot.data[index - 1]);
              },
            );
          },
        ),
      ),
    );
  }
}
