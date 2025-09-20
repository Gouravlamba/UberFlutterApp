import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';

import 'package:uber_admin_panel/dashboard/dashboard.dart';
import 'package:uber_admin_panel/pages/driver_page.dart';
import 'package:uber_admin_panel/pages/trips_page.dart';
import 'package:uber_admin_panel/pages/user_page.dart';
import 'package:uber_admin_panel/pages/earnings_page.dart';

class SideNavigationDrawer extends StatefulWidget {
  const SideNavigationDrawer({super.key});

  @override
  State<SideNavigationDrawer> createState() => _SideNavigationDrawerState();
}

class _SideNavigationDrawerState extends State<SideNavigationDrawer> {
  Widget chosenScreen = Dashboard();

  void sendAdminTo(AdminMenuItem selectedPage) {
    setState(() {
      switch (selectedPage.route) {
        case DriverPage.id:
          chosenScreen = const DriverPage();
          break;
        case UserPage.id:
          chosenScreen = const UserPage();
          break;
        case TripsPage.id:
          chosenScreen = const TripsPage();
          break;
        case EarningsPage.id:
          chosenScreen = const EarningsPage();
          break;
        default:
          chosenScreen = const Dashboard();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: const Color.fromARGB(221, 39, 57, 99),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Admin Web Panel",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      ),
      sideBar: SideBar(
        backgroundColor: const Color.fromARGB(221, 39, 57, 99),
        textStyle: const TextStyle(color: Colors.white),
        activeBackgroundColor: const Color.fromARGB(221, 39, 57, 99),
        activeTextStyle: const TextStyle(color: Colors.white),
        items: const [
          AdminMenuItem(
            title: "Dashboard",
            route: Dashboard.id,
            icon: CupertinoIcons.square_grid_2x2,
          ),
          AdminMenuItem(
            title: "Drivers",
            route: DriverPage.id,
            icon: CupertinoIcons.car_detailed,
          ),
          AdminMenuItem(
            title: "Users",
            route: UserPage.id,
            icon: CupertinoIcons.person_2_fill,
          ),
          AdminMenuItem(
            title: "Trips",
            route: TripsPage.id,
            icon: CupertinoIcons.location_fill,
          ),
          AdminMenuItem(
            title: "Earnings",
            route: EarningsPage.id,
            icon: CupertinoIcons.money_dollar,
          ),
        ],
        selectedRoute: Dashboard.id,
        onSelected: (itemSelected) {
          sendAdminTo(itemSelected);
        },
      ),
      body: chosenScreen,
    );
  }
}
