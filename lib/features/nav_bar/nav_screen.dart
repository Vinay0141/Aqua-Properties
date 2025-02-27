import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../nav_view/agent/agent_details.dart';
import '../nav_view/booking/booking_screen.dart';
import '../nav_view/customers/customers_screen.dart';
import '../nav_view/home/home_screen.dart';
import '../nav_view/unite/unite_screen.dart';
import '../nav_view/agencies/agencies.dart';
import 'nav_bar_bloc/tab_bloc.dart';
import 'nav_bar_bloc/tab_event.dart';
import 'nav_bar_bloc/tab_state.dart';

class DashboardScreen extends StatefulWidget {
  final int initialIndex;

  const DashboardScreen({super.key, this.initialIndex = 0});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  void _scrollToSelectedIndex(int index) {
    double screenWidth = MediaQuery.of(context).size.width;
    double itemWidth = screenWidth / 4.5; // Har item ka width (4-5 items ek time par dikhne chahiye)
    double targetScrollPosition = itemWidth * index - screenWidth / 3;

    _scrollController.animateTo(
      targetScrollPosition,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TabBloc()..add(TabChangedEvent(widget.initialIndex)),
      child: Scaffold(
        body: BlocBuilder<TabBloc, TabState>(
          builder: (context, state) {
            int currentIndex = widget.initialIndex;

            if (state is TabInitialState) {
              currentIndex = state.tabIndex;
            }

            var unitIdName;
            return WillPopScope(
              onWillPop: () async {
                if (currentIndex > 0) {
                  context.read<TabBloc>().add(TabChangedEvent(currentIndex - 1));
                  return Future.value(false);
                } else {
                  context.read<TabBloc>().add(TabChangedEvent(4));
                  return Future.value(false);
                }
              },
              child: Column(
                children: [
                  Expanded(
                    child: IndexedStack(
                      index: currentIndex,
                      children: [
                        const HomeScreen(),
                        UniteScreen(selectPlan: unitIdName.toString()),
                        BookingScreen(),
                        const CustomerDetail(),
                        const AgentDetail(),
                        const AgenciesDetail(),
                      ],
                    ),
                  ),

                  /// ✅ Scrollable Custom Navigation Bar with Auto Scroll Animation
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildNavItem(
                              context,
                              icon: Icons.home_filled,
                              label: 'Home',
                              index: 0,
                              currentIndex: currentIndex,
                            ),
                            _buildNavItem(
                              context,
                              icon: Icons.business,
                              label: 'Unite',
                              index: 1,
                              currentIndex: currentIndex,
                            ),
                            _buildNavItem(
                              context,
                              icon: Icons.insert_page_break_sharp,
                              label: 'Booking',
                              index: 2,
                              currentIndex: currentIndex,
                            ),
                            _buildNavItem(
                              context,
                              icon: Icons.people,
                              label: 'Customers',
                              index: 3,
                              currentIndex: currentIndex,
                            ),
                            _buildNavItem(
                              context,
                              icon: Icons.person,
                              label: 'Agent',
                              index: 4,
                              currentIndex: currentIndex,
                            ),
                            _buildNavItem(
                              context,
                              icon: Icons.business,
                              label: 'Agencies',
                              index: 5,
                              currentIndex: currentIndex,
                            ),
                            _buildNavItem(
                              context,
                              icon: Icons.payment,
                              label: 'Payment',
                              index: 6,
                              currentIndex: currentIndex,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// ✅ Custom Nav Item Widget with Auto Scroll Trigger
  Widget _buildNavItem(BuildContext context,
      {required IconData icon,
        required String label,
        required int index,
        required int currentIndex}) {
    bool isSelected = index == currentIndex;

    return GestureDetector(
      onTap: () {
        context.read<TabBloc>().add(TabChangedEvent(index));
        _scrollToSelectedIndex(index); // Auto Scroll on Tap
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[100] : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue : Colors.black,
              size: 30,
            ),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.blue : Colors.black,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
