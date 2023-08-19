part of 'todo_bloc.dart';

@immutable
abstract class TodoState {}

class TodoInitial extends TodoState {}

class InsertFail extends TodoState {}

class InsertSuccess extends TodoState {}

class UpdateSuccess extends TodoState {}

class UpdateFail extends TodoState {}

class DeleteFail extends TodoState {}

class DeleteSuccess extends TodoState {}
