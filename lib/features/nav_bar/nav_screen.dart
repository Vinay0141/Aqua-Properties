import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../nav_view/booking/booking_screen.dart';
import '../nav_view/customers/customers_screen.dart';
import '../nav_view/home/home_screen.dart';
import '../nav_view/unite/unite_screen.dart';
import 'nav_bar_bloc/tab_bloc.dart';
import 'nav_bar_bloc/tab_event.dart';
import 'nav_bar_bloc/tab_state.dart';

class DashboardScreen extends StatelessWidget {
  final int initialIndex; // ✅ Yeh add kiya

  const DashboardScreen({super.key, this.initialIndex = 0}); // ✅ Default index 0 rakha

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TabBloc()..add(TabChangedEvent(initialIndex)), // ✅ initialIndex pass kiya
      child: Scaffold(
        body: BlocBuilder<TabBloc, TabState>(
          builder: (context, state) {
            int currentIndex = initialIndex; // ✅ currentIndex ko initialIndex se set kiya

            if (state is TabInitialState) {
              currentIndex = state.tabIndex;
            }

            var unitIdName;
            return WillPopScope(
              onWillPop: () async {
                if (currentIndex > 0) {
                  // ✅ Agar kisi tab par ho, toh pichle tab par jao
                  context.read<TabBloc>().add(TabChangedEvent(currentIndex - 1));
                  return Future.value(false);
                } else {
                  // ✅ Agar first tab par ho, toh last index (4) par jao
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
                        const CustomerScreen(),
                        // MenuScreen(),
                      ],
                    ),
                  ),
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    child: BottomNavigationBar(
                      elevation: 10,
                      backgroundColor: Colors.white,
                      type: BottomNavigationBarType.fixed,
                      items: const <BottomNavigationBarItem>[
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
                          icon: Icon(Icons.payment),
                          label: 'Payment',
                        ),
                      ],
                      currentIndex: currentIndex,
                      selectedItemColor: Colors.blue,
                      unselectedItemColor: Colors.black,
                      showUnselectedLabels: true,
                      onTap: (index) {
                        context.read<TabBloc>().add(TabChangedEvent(index));
                      },
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
}
