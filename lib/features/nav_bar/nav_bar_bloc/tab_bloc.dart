import 'package:aqua_properties/features/nav_bar/nav_bar_bloc/tab_event.dart';
import 'package:aqua_properties/features/nav_bar/nav_bar_bloc/tab_state.dart';
import 'package:bloc/bloc.dart';

class TabBloc extends Bloc<TabEvent, TabState> {
  TabBloc() : super(TabInitialState()) {
    on<TabChangedEvent>((event, emit) {
      emit(TabInitialState(tabIndex: event.tabIndex));
    });
  }
}