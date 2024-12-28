import 'package:flutter_bloc/flutter_bloc.dart';

abstract class TabEvent {}

class TabChangedEvent extends TabEvent {
  final int tabIndex;

  TabChangedEvent(this.tabIndex);
}