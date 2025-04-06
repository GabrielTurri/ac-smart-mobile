// import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:ac_smart/models/activity.dart';

class ACSmartNavigationBar extends StatefulWidget {
  const ACSmartNavigationBar({
    super.key,
    currentSelectedNavigation,
  });

  @override
  State<ACSmartNavigationBar> createState() => _ACSmartNavigationBarState();
}

class _ACSmartNavigationBarState extends State<ACSmartNavigationBar> {
  int currentSelectedNavigation = 0;
  int myIndex = Activity().pageIndex;

  @override
  Widget build(BuildContext context) {
    return NavigationBarTheme(
      data: NavigationBarThemeData(
          labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
        (Set<WidgetState> states) => states.contains(WidgetState.selected)
            ? const TextStyle(color: Color(0xffFF9432))
            : const TextStyle(color: Colors.white),
      )),
      child: NavigationBar(
        backgroundColor: const Color(0xff043565),
        indicatorColor: const Color(0xffFF9432),
        onDestinationSelected: (int index) {
          myIndex = index;

          // switch (index) {
          //   case 0:
          //     context.go('/');
          //     break;
          //   case 1:
          //     context.go('/activities');
          //     break;
          //   case 2:
          //     context.go('/activities');
          //     break;
          //   case 3:
          //     context.go('/activities');
          //     break;
          // }
          setState(() {
            // currentSelectedNavigation = index;
            myIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined, color: Colors.white),
            selectedIcon: Icon(Icons.dashboard, color: Colors.white),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.view_list_outlined, color: Colors.white),
            selectedIcon: Icon(Icons.view_list, color: Colors.white),
            label: 'Minhas ACs',
          ),
          // NavigationDestination(
          //   icon: Icon(Icons.note_add_outlined, color: Colors.white),
          //   selectedIcon: Icon(Icons.note_add, color: Colors.white),
          //   label: 'Nova AC',
          // ),
          NavigationDestination(
            icon:
                Icon(Icons.cancel_schedule_send_outlined, color: Colors.white),
            selectedIcon: Icon(Icons.cancel_schedule_send, color: Colors.white),
            label: 'Reprovadas',
          ),
        ],
        selectedIndex: myIndex,
      ),
    );
  }
}
