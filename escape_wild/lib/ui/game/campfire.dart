import 'dart:async';
import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:escape_wild/core.dart';
import 'package:escape_wild/design/theme.dart';
import 'package:escape_wild/foundation.dart';
import 'package:escape_wild/r.dart';
import 'package:escape_wild/ui/game/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rettulf/rettulf.dart';

part 'campfire.i18n.dart';

class CampfirePage extends StatefulWidget {
  const CampfirePage({super.key});

  @override
  State<CampfirePage> createState() => _CampfirePageState();
}

class _CampfirePageState extends State<CampfirePage> {
  @override
  Widget build(BuildContext context) {
    final place = player.location;
    if (place is CampfirePlaceProtocol) {
      return place >>
          (ctx) => AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: buildBody(place),
              );
    } else {
      return LeavingBlank(icon: Icons.close_rounded, desc: "I can't start fire here.");
    }
  }

  Widget buildBody(CampfirePlaceProtocol place) {
    if (place.fireState.active || place.isCampfireHasAnyStack) {
      return CookPage(place: place);
    } else {
      return FireStartingPage(place: place);
    }
  }
}

class FireStartingPage extends StatefulWidget {
  final CampfirePlaceProtocol place;

  const FireStartingPage({
    super.key,
    required this.place,
  });

  @override
  State<FireStartingPage> createState() => _FireStartingPageState();
}

class _FireStartingPageState extends State<FireStartingPage> {
  CampfirePlaceProtocol get place => widget.place;

  FireState get fireState => widget.place.fireState;

  set fireState(FireState v) => widget.place.fireState = v;

  @override
  Widget build(BuildContext context) {
    final body = context.isPortrait ? buildPortrait() : buildLandscape();
    return body.padAll(5);
  }

  Widget buildPortrait() {
    return [
      const StaticCampfireImage(),
      SizedBox(height: 30.h),
      FireStarterArea(place: place),
    ].column(maa: MainAxisAlignment.spaceEvenly).scrolled().center();
  }

  Widget buildLandscape() {
    return [
      const StaticCampfireImage().expanded(),
      FireStarterArea(place: place).expanded(),
    ].row();
  }
}

class FireStarterArea extends StatefulWidget {
  final CampfirePlaceProtocol place;
  final Axis direction;

  const FireStarterArea({
    super.key,
    required this.place,
    this.direction = Axis.vertical,
  });

  @override
  State<FireStarterArea> createState() => _FireStarterAreaState();
}

class _FireStarterAreaState extends State<FireStarterArea> {
  final fireStarterSlot = ItemStackSlot(ItemMatcher.hasComp([FireStarterComp]));
  static int lastSelectedIndex = -1;

  FireState get fireState => widget.place.fireState;

  set fireState(FireState v) => widget.place.fireState = v;

  @override
  void initState() {
    super.initState();
    if (lastSelectedIndex >= 0) {
      final lastSelected = player.backpack[lastSelectedIndex];
      if (fireStarterSlot.matcher.exact(lastSelected).isMatched) {
        setState(() {
          fireStarterSlot.stack = lastSelected;
        });
      }
    }
    fireStarterSlot.addListener(() {
      final newStack = fireStarterSlot.stack;
      lastSelectedIndex = player.backpack.indexOfStack(newStack);
    });
  }

  @override
  Widget build(BuildContext context) {
    final widgets = [
      buildFireStarterCell(),
      buildStartFireButton(),
    ];
    if (widget.direction == Axis.vertical) {
      return widgets.column(
        caa: CrossAxisAlignment.center,
        maa: MainAxisAlignment.spaceEvenly,
      );
    } else {
      return widgets.row(
        caa: CrossAxisAlignment.center,
        maa: MainAxisAlignment.spaceEvenly,
      );
    }
  }

  Widget buildFireStarterCell() {
    Widget cell = ItemStackReqAutoMatchCell(
      slot: fireStarterSlot,
      onTapSatisfied: onSelectFireStarter,
      onTapUnsatisfied: onSelectFireStarter,
      onInBackpack: const ItemStackCellTheme(
        showMass: false,
        showProgressBar: false,
      ),
    ).constrained(maxW: 180, maxH: 80);
    return cell;
  }

  Future<void> onSelectFireStarter() async {
    await context.showBackpackSheet(
      matcher: fireStarterSlot.matcher,
      delegate: BackpackSheetItemStack(onSelect: (selected) {
        if (!mounted) return;
        setState(() {
          fireStarterSlot.toggle(selected);
        });
        context.navigator.pop();
      }),
    );
  }

  Widget buildStartFireButton() {
    final maybeFireStarter = fireStarterSlot.stack;
    final active = player.canPlayerAct() && maybeFireStarter.isNotEmpty;
    return CardButton(
      elevation: active ? 12 : 0.5,
      onTap: !active
          ? null
          : () async {
              await onStartFire(maybeFireStarter);
            },
      child: _I.startFire.text(style: context.textTheme.headlineSmall).center(),
    ).sized(w: 180, h: 80);
  }

  Future<void> onStartFire(ItemStack fireStarter) async {
    final comp = FireStarterComp.of(fireStarter);
    assert(comp != null, "$fireStarter doesn't have $FireStarterComp.");
    if (comp != null) {
      final started = comp.tryStartFire(fireStarter);
      if (started) {
        fireState = FireState(fuel: FuelComp.tryGetHeatValue(fireStarter));
      }
      if (DurabilityComp.tryGetIsBroken(fireStarter)) {
        player.backpack.removeStackInBackpack(fireStarter);
        fireStarterSlot.reset();
      }
      setState(() {});
    }
  }

  @override
  void dispose() {
    fireStarterSlot.dispose();
    super.dispose();
  }
}

class CookPage extends StatefulWidget {
  final CampfirePlaceProtocol place;

  const CookPage({
    super.key,
    required this.place,
  });

  @override
  State<CookPage> createState() => _CookPageState();
}

class _CookPageState extends State<CookPage> {
  final cookMatcher = ItemMatcher.hasAnyTag(["cookable", "cooker"]);
  late final ingredientsSlots = List.generate(CookRecipeProtocol.maxIngredient, (i) => ItemStackSlot(cookMatcher));
  late final dishesSlots = List.generate(CookRecipeProtocol.maxIngredient, (i) => ItemStackSlot(ItemMatcher.any));

  CampfirePlaceProtocol get place => widget.place;

  FireState get $fireState => place.fireState;

  FireState get fireState => place.fireState;

  set fireState(FireState v) => place.fireState = v;

  double get fireFuel => fireState.fuel;

  set fireFuel(double v) => fireState = fireState.copyWith(fuel: v);

  @override
  void initState() {
    super.initState();
    place.addListener(onOnCampfireChange);
    place.addListener(onOffCampfireChange);
    onOnCampfireChange();
    onOffCampfireChange();
  }

  @override
  void dispose() {
    for (final cookSlot in ingredientsSlots) {
      cookSlot.dispose();
    }
    place.removeListener(onOnCampfireChange);
    place.removeListener(onOffCampfireChange);
    super.dispose();
  }

  void onOnCampfireChange() {
    final items = place.onCampfire;
    for (var i = 0; i < ingredientsSlots.length; i++) {
      if (0 <= i && i < items.length) {
        ingredientsSlots[i].stack = items[i];
      } else {
        ingredientsSlots[i].reset();
      }
    }
    setState(() {});
  }

  void onOffCampfireChange() {
    final items = place.offCampfire;
    for (var i = 0; i < min(dishesSlots.length, items.length); i++) {
      if (0 <= i && i < items.length) {
        dishesSlots[i].stack = items[i];
      } else {
        dishesSlots[i].reset();
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return context.isPortrait ? buildBodyPortrait() : buildBodyLandscape();
  }

  Widget buildBodyPortrait() {
    return Scaffold(
      appBar: AppBar(
        title: "Campfire".text(),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: [
        buildFoodGrid().flexible(flex: 2),
        buildCampfire().flexible(flex: 4),
        buildButtons().flexible(flex: 1),
      ].column(maa: MainAxisAlignment.spaceBetween).padAll(5),
    );
  }

  Widget buildBodyLandscape() {
    return [
      buildFoodGrid().expanded(),
      [
        LayoutBuilder(builder: (_, box) => buildCampfire().constrained(maxH: box.maxWidth * 0.5)),
        buildButtons(),
      ].column(maa: MainAxisAlignment.center).scrolled().expanded(),
    ].row(mas: MainAxisSize.min);
  }

  Widget buildCampfire() {
    return [
      buildBackground(),
      buildFuelState(place.fireState),
    ].stack();
  }

  Widget buildBackground() {
    return DynamicCampfireImage(
      color: Color.lerp(context.themeColor, R.flameColor, fireState.fuel / FireState.maxVisualFuel)!,
    ).center().opacity(0.45);
  }

  Widget buildFoodGrid() {
    final cells = <Widget>[];
    // ingredients
    for (final slot in ingredientsSlots) {
      cells.add(buildIngredientSlot(slot));
    }
    // outputs
    for (final slot in dishesSlots) {
      cells.add(buildDishesSlot(slot));
    }
    return LayoutGrid(
      gridFit: GridFit.expand,
      columnSizes: List.generate(CookRecipeProtocol.maxIngredient, (index) => 1.fr),
      rowSizes: [1.fr, 1.fr],
      children: cells,
    );
  }

  Widget buildIngredientSlot(ItemStackSlot slot) {
    final cell = ItemStackReqCell(
      slot: slot,
      onTapUnsatisfied: () async {
        await onSetIngredient(slot);
      },
      onTapSatisfied: () async {
        await onTakeOutIngredient(slot);
      },
      unsatisfiedTheme: NullItemCellTheme(
        placeholder: "Ingredient",
        nameOpacity: 0.4,
      ),
    ).sized(w: 150, h: 80).center();
    return cell;
  }

  Future<void> onSetIngredient(ItemStackSlot slot) async {
    if (slot.isNotEmpty) return;
    final anyIngredientExisted = ingredientsSlots.any((slot) => slot.isNotEmpty);
    if (anyIngredientExisted) {
      final confirmed = await context.showRequest(
        title: "Add Ingredient?",
        desc: "Confirm to add ingredient and reset cooking?",
        yes: I.yes,
        no: I.no,
        highlight: true,
      );
      if (confirmed != true) return;
    }
    if (!mounted) return;
    await context.showBackpackSheet<ItemStack>(
      matcher: cookMatcher,
      delegate: BackpackSheetItemStackWithMass(onSelect: (selected, mass) {
        final ItemStack ingredient;
        if (selected.meta.mergeable) {
          assert(mass != null, "$selected is mergeable, but selected mass is null");
          ingredient = player.backpack.splitItemInBackpack(selected, mass ?? selected.stackMass);
        } else {
          player.backpack.removeStackInBackpack(selected);
          ingredient = selected;
        }
        // the slot should be empty, but there is no guarantee in async context.
        if (slot.isEmpty) {
          slot.stack = ingredient;
        } else {
          ingredient.mergeTo(slot.stack);
        }
        // sync with [campfireHolder].
        place.onCampfire = ingredientsSlots.where((slot) => slot.isNotEmpty).map((slot) => slot.stack).toList();
      }),
    );
  }

  Future<void> onTakeOutIngredient(ItemStackSlot slot) async {
    final stack = slot.stack;
    if (slot.isEmpty) return;
    final confirmed = await context.showRequest(
      title: "Stop Cooking?",
      desc: "Confirm to take out ${stack.displayName()} and reset cooking?",
      yes: I.yes,
      no: I.no,
      serious: true,
      highlight: true,
    );
    if (confirmed != true) return;
    player.backpack.addItemOrMerge(stack);
    slot.reset();
    place.onCampfire = ingredientsSlots.where((slot) => slot.isNotEmpty).map((slot) => slot.stack).toList();
  }

  Widget buildDishesSlot(ItemStackSlot slot) {
    final cell = ItemStackReqCell(
      slot: slot,
      unsatisfiedTheme: NullItemCellTheme(
        placeholder: "Output",
        nameOpacity: 0.4,
      ),
      onTapSatisfied: () {
        if (slot.isNotEmpty) {
          final stack = slot.stack;
          player.backpack.addItemOrMerge(stack);
          place.offCampfire = List.of(place.offCampfire)..remove(stack);
          slot.reset();
        }
      },
    ).sized(w: 150, h: 80).center();
    return cell;
  }

  Widget buildButtons() {
    if (fireState.isOff) {
      return FireStarterArea(place: place, direction: Axis.horizontal);
    }
    Widget btn(String text, {required double elevation, VoidCallback? onTap}) {
      return CardButton(
        elevation: elevation,
        onTap: onTap,
        child: text
            .autoSizeText(
              maxLines: 1,
              style: context.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            )
            .padAll(10),
      ).expanded();
    }

    final waitBtn = btn("Wait", elevation: 5, onTap: () {
      player.onPassTime(const Ts(minutes: 5));
    });
    final fuelBtn = btn(_I.fuel, elevation: 5, onTap: onFuel);
    return [
      waitBtn,
      fuelBtn,
    ].row(maa: MainAxisAlignment.spaceEvenly).align(at: Alignment.bottomCenter);
  }

  Future<void> onFuel() async {
    await context.showBackpackSheet<ItemStack>(
      matcher: ItemMatcher.hasComp(const [FuelComp]),
      delegate: BackpackSheetItemStackWithMass(onSelect: (selected, mass) async {
        final ItemStack fuel;
        if (selected.meta.mergeable) {
          assert(mass != null, "$selected is mergeable, but selected mass is null");
          fuel = player.backpack.splitItemInBackpack(selected, mass ?? selected.stackMass);
        } else {
          player.backpack.removeStackInBackpack(selected);
          fuel = selected;
        }
        final heatValue = FuelComp.tryGetHeatValue(fuel);
        fireFuel += heatValue;
      }),
    );
  }

  Widget buildFuelState(FireState state) {
    return LayoutBuilder(
      builder: (_, box) {
        final length = box.maxHeight * 0.6;
        final halfP = state.fuel / FireState.maxVisualFuel / 2;
        final left = buildFuelProgress(halfP, length);
        final right = buildFuelProgress(halfP, length);
        return [
          left,
          right,
        ].row(maa: MainAxisAlignment.spaceBetween);
      },
    ).center();
  }

  Widget buildFuelProgress(Ratio progress, double length) {
    return RotatedBox(
      quarterTurns: -1,
      child: AttrProgress(
        value: progress.clamp(0, 1),
        minHeight: 16,
        color: context.fixColorBrightness(R.fuelYellowColor),
      ).constrained(maxW: length),
    ).padH(12);
  }
}

class StaticCampfireImage extends StatelessWidget {
  final Color? color;

  const StaticCampfireImage({
    super.key,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      "assets/img/campfire.svg",
      //color: context.themeColor,
      color: color ?? context.themeColor,
      placeholderBuilder: (_) => const Placeholder(),
    ).constrained(maxW: 200, maxH: 200);
  }
}

class DynamicCampfireImage extends ImplicitlyAnimatedWidget {
  final Color color;

  const DynamicCampfireImage({
    super.key,
    super.duration = const Duration(milliseconds: 1200),
    required this.color,
    super.curve = Curves.fastLinearToSlowEaseIn,
  });

  @override
  ImplicitlyAnimatedWidgetState<DynamicCampfireImage> createState() => _DynamicCampfireImageState();
}

class _DynamicCampfireImageState extends AnimatedWidgetBaseState<DynamicCampfireImage> {
  late ColorTween $color;

  @override
  void initState() {
    $color = ColorTween(
      begin: widget.color,
      end: widget.color,
    );
    super.initState();
    if ($color.begin != $color.end) {
      controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      child: buildBar(),
    );
  }

  Widget buildBar() {
    return StaticCampfireImage(
      color: $color.animate(animation).value,
    );
  }

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    $color = visitor($color, widget.color, (dynamic value) {
      assert(false);
      throw StateError('Constructor will never be called because null is never provided as current tween.');
    }) as ColorTween;
  }
}
