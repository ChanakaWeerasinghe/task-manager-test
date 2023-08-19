part of 'todo_bloc.dart';

@immutable
abstract class TodoEvent {}

class InsertTask extends TodoEvent {
  Task task;

  InsertTask(this.task);
}

class UpdateTask extends TodoEvent {
  Task task;

  UpdateTask(this.task);
}

class DeleteTask extends TodoEvent {
  Task task;

  DeleteTask(this.task);
}
