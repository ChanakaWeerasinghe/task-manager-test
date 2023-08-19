import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:task_manager/helpers/database_helper.dart';
import 'package:task_manager/models/task_model.dart';

part 'todo_event.dart';

part 'todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  TodoBloc() : super(TodoInitial()) {
    on<TodoEvent>((event, emit) async {
      if (event is InsertTask) {
        await _insert(event);
      } else if (event is UpdateTask) {
        await _update(event);
      } else if (event is DeleteTask) {
        await _delete(event);
      }
      // TODO: implement event handler
    });
  }

  _insert(InsertTask event) {
    try {
      DatabaseHelper.instance.insertTask(event.task);
      emit(InsertSuccess());
    } catch (e) {
      emit(InsertFail());
      print(e);
    }
  }

  _update(UpdateTask event) {
    try {
      DatabaseHelper.instance.updateTask(event.task);
      emit(UpdateSuccess());
    } catch (e) {
      emit(UpdateFail());
      print(e);
    }
  }

  _delete(DeleteTask event) {
    try {
      DatabaseHelper.instance.deleteTask(event.task.id);
      emit(DeleteSuccess());
    } catch (e) {
      emit(DeleteFail());
      print(e);
    }
  }
}
