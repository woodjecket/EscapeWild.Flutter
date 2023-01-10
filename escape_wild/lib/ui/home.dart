import 'package:easy_localization/easy_localization.dart';
import 'package:escape_wild/ui/backpack.dart';
import 'package:escape_wild/ui/campfire.dart';
import 'package:flutter/material.dart';

import 'action.dart';

part 'home.i18n.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomePageState();
}

class _P {
  _P._();

  static const action = 0;
  static const backpack = 1;
  static const campfire = 2;
}

class _HomePageState extends State<Homepage> {
  var curIndex = _P.action;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: curIndex,
        onTap: (newIndex) {
          if (newIndex != curIndex) {
            setState(() {
              curIndex = newIndex;
            });
          }
        },
        items: [
          BottomNavigationBarItem(
            label: _I.action,
            icon: Icon(Icons.menu),
          ),
          BottomNavigationBarItem(
            label: _I.backpack,
            icon: Icon(Icons.backpack_outlined),
            activeIcon: Icon(Icons.backpack),
          ),
          BottomNavigationBarItem(
            label: _I.campfire,
            icon: Icon(Icons.local_fire_department_outlined),
            activeIcon: Icon(Icons.local_fire_department_rounded),
          ),
        ],
      ),
    );
  }

  Widget buildBody() {
    if (curIndex == _P.action) {
      return ActionPage();
    } else if (curIndex == _P.backpack) {
      return BackpackPage();
    } else {
      return CampfirePage();
    }
  }
}
