import 'package:escape_wild_flutter/core/content.dart';
import 'package:escape_wild_flutter/core/item.dart';

class Stuff {
  static late FuelItemMeta plasticBottle, sticks, cutGrass, log, dryLichen;

  static void registerAll() {
    Contents.items.addAll([
      plasticBottle = FuelItemMeta("plastic-bottle", 5.0),
      sticks = FuelItemMeta("sticks", 2.0),
      cutGrass = FuelItemMeta("cut-grass", 5.0),
      log = FuelItemMeta("log", 20.0),
      dryLichen = FuelItemMeta("dry-Lichen", 10.0),
    ]);
  }
}
