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
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    _currentIndex = widget.initialIndex;
  }

  void _onTabSelected(BuildContext context, int index) {
    setState(() {
      _currentIndex = index;
    });
    context.read<TabBloc>().add(TabChangedEvent(index));
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  Future<bool> _onWillPop() async {
    if (_currentIndex > 0) {
      _onTabSelected(context, _currentIndex - 1); // ✅ Ek tab pichhe jaayega
      return Future.value(false);
    } else {
      return await _showExitDialog(); // ❌ Home screen pe exit confirm kare
    }
  }

  Future<bool> _showExitDialog() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Exit App"),
        content: const Text("Kya aap sure ho ki app close karna chahte ho?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Exit"),
          ),
        ],
      ),
    ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TabBloc()..add(TabChangedEvent(widget.initialIndex)),
      child: WillPopScope(
        onWillPop: _onWillPop, // 🔙 Handle back navigation
        child: BlocListener<TabBloc, TabState>(
          listener: (context, state) {
            if (state is TabInitialState) {
              _currentIndex = state.tabIndex;
              _pageController.jumpToPage(_currentIndex); // ✅ Tab Sync Fix
            }
          },
          child: Scaffold(
            body: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                const HomeScreen(),
                const UniteScreen(selectPlan: ""),
                BookingScreen(),
                const CustomerDetail(),
                const AgentDetail(),
                const AgenciesDetail(),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => _onTabSelected(context, index),
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Colors.blue,
              unselectedItemColor: Colors.black,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_filled),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.business),
                  label: 'Unite',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.insert_page_break_sharp),
                  label: 'Booking',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people),
                  label: 'Customers',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Agent',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.business),
                  label: 'Agencies',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
