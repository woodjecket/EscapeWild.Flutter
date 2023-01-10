import 'package:escape_wild/core/attribute.dart';
import 'package:escape_wild/core/content.dart';
import 'package:escape_wild/core/item.dart';

import 'stuff.dart';

class Foods {
  // energy food
  static late final Item energyBar, energyDrink;
  static late final Item longicornLarva, wetLichen;

  // rabbit
  static late final Item rawRabbit, cookedRabbit;

  // fish
  static late final Item rawFish, cookedFish;

  // berry
  static late final Item berry, roastedBerry;

  // nuts
  static late final Item nuts, toastedNuts;

  // water
  static late final Item bottledWater, dirtyWater, cleanWater, boiledWater, filteredWater;

  // tea
  static late final Item dandelionTea;
  static late final Item rockSalt;

  static void registerAll() {
    // food
    Contents.items.addAll([
      energyBar = Item("energy-bar").asEatable([
        Attr.food + 0.32,
        Attr.energy + 0.1,
      ]),
      longicornLarva = Item("longicorn-larva").asEatable([
        Attr.food + 0.1,
        Attr.water + 0.1,
      ]),
      wetLichen = Item("wet-lichen").asEatable([
        Attr.food + 0.05,
        Attr.water + 0.2,
      ])
    ]);
    // water
    Contents.items.addAll([
      bottledWater = Item("bottled-water").asDrinkable([
        Attr.food + 0.28,
      ], afterUsed: () => Stuff.plasticBottle),
      dirtyWater = Item("dirty-water").asDrinkable([
        Attr.health - 0.085,
        Attr.water + 0.15,
      ]).asCookable(CookType.boil, fuelCost: 3.0, output: () => boiledWater),
      cleanWater = Item("clean-water").asDrinkable([
        Attr.health - 0.005,
        Attr.water + 0.235,
      ])  ,
      boiledWater = Item("boiled-water").asDrinkable([
        Attr.water + 0.28,
      ]),
      filteredWater = Item("filtered-water").asDrinkable([
        Attr.health - 0.005,
        Attr.water + 0.2,
      ]),
      energyDrink = Item("energy-drink").asDrinkable([
        Attr.water + 0.28,
        Attr.energy + 0.12,
      ]),
    ]);
    // cookable
    Contents.items.addAll([
      berry = Item("berry").asEatable([
        Attr.food + 0.12,
        Attr.water + 0.06,
      ]).asCookable(CookType.roast, fuelCost: 3.0, output: () => roastedBerry),
      roastedBerry = Item("roasted-berry").asEatable([
        Attr.food + 0.185,
      ]),
      nuts = Item("nuts").asEatable([
        Attr.food + 0.08,
      ]).asCookable(CookType.roast, fuelCost: 2.5, output: () => toastedNuts),
      toastedNuts = Item("toasted-nuts").asEatable([
        Attr.food + 0.12,
      ]),
      rawRabbit = Item("raw-rabbit").asEatable([
        Attr.food + 0.45,
        Attr.water + 0.05,
      ]).asCookable(
        CookType.cook,
        fuelCost: 20,
        output: () => cookedRabbit,
      ),
      cookedRabbit = Item("cooked-rabbit").asEatable([
        Attr.food + 0.68,
      ]),
      rawFish = Item("raw-fish").asEatable([
        Attr.food + 0.35,
        Attr.water + 0.08,
      ]).asCookable(
        CookType.cook,
        fuelCost: 12.5,
        output: () => cookedFish,
      ),
      cookedFish = Item("cooked-fish").asEatable([
        Attr.food + 0.52,
      ]),
      dandelionTea = Item("dandelion-tea").asDrinkable([
        Attr.water + 0.20,
        //After drinking this, the pain caused by constipation will be slightly reduced
      ]),
      rockSalt = Item("rock-salt").asEatable([
        Attr.water - 0.3,
        Attr.energy + 0.3,
        //
      ]),
    ]);
  }
}