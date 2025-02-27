
abstract class TabEvent {}

class TabChangedEvent extends TabEvent {
  final int tabIndex;

  TabChangedEvent(this.tabIndex);
}