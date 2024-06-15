import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../Menu/Widgets/MenuButtonWidget.dart';
import 'CarsFavoriteScreens.dart';
import 'FavoritesScreen.dart';

class FavoritesScreen_main extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Builder(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Favorites"),
              centerTitle: true,
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF00aa9b),
                      Color(0xFF00aa9b),
                    ],
                    begin: FractionalOffset(0.0, 0.0),
                    end: FractionalOffset(1.0, 0.0),
                    stops: [0.0, 1.0],
                    tileMode: TileMode.clamp,
                  ),
                ),
              ),
              automaticallyImplyLeading: false,
              bottom: const TabBar(
                tabs: [
                  Tab(
                    icon: Icon(Icons.directions_car, color: Colors.white),
                    text: "Car Lists",
                  ),
                  Tab(
                    icon: Icon(Icons.people, color: Colors.white),
                    text: "Travelers",
                  ),
                ],
                indicatorColor: Colors.white38,
                indicatorWeight: 6,
              ),
            ),
            drawer: const MenuDrawer(),
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Color(0xFF005573),
                    Color(0xFF005573),
                  ],
                ),
              ),
              child: TabBarView(
                children: [
                  CarsFavoritesScreen(), // Your Car List screen widget
                  FavoritesScreen(), // Your Traveler List screen widget
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
