abstract class TabState {}

class TabInitialState extends TabState {
  final int tabIndex;

  TabInitialState({this.tabIndex = 0});
}