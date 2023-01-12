import 'package:escape_wild/core/content.dart';
import 'package:escape_wild/core/item.dart';

class Tools {
  Tools._();

  static late final Item survivalKnife;
  static late final Item oldAxe, stoneAxe;
  static late final Item oldFishRod;
  static late final Item bearTrap;
  static late final Item oldShotgun;
  static late final Item catchingNet;

  // fire starter
  static late final Item handDrillKit;

  static void registerAll() {
    // cutting
    Contents.items.addAll([
      survivalKnife = Item.unmergeable("survival-knife", mass: 100).asTool(
        attr: ToolAttr.high,
        type: ToolType.cutting,
        health: 40.0,
      ),
    ]);
    // axe
    Contents.items.addAll([
      oldAxe = Item.unmergeable("old-axe", mass: 3000).asTool(
        type: ToolType.axe,
        attr: ToolAttr.normal,
        health: 150.0,
      ),
      stoneAxe = Item.unmergeable("stone-axe", mass: 1500).asTool(
        type: ToolType.axe,
        attr: ToolAttr.low,
        health: 80.0,
      )
    ]);
    // fishing
    Contents.items.addAll([
      oldFishRod = Item.unmergeable("old-fish-rod", mass: 500).asTool(
        type: ToolType.fishing,
        attr: ToolAttr.normal,
        health: 50.0,
      )
    ]);
    // gun
    Contents.items.addAll([
      oldShotgun = Item.unmergeable("old-shotgun", mass: 3000).asTool(
        type: ToolType.gun,
        attr: ToolAttr.low,
        health: 50.0,
      )
    ]);
    // trap
    Contents.items.addAll([
      bearTrap = Item.unmergeable("bear-trap", mass: 2000).asTool(
        type: ToolType.trap,
        attr: ToolAttr.high,
        health: 30.0,
      )
    ]);
    // fire starter
    Contents.items.addAll([
      handDrillKit = Item.unmergeable("hand-drill-kit", mass: 500),
    ]);
  }
}
