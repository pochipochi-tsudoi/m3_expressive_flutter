# m3_expressive_flutter

Material 3 Expressive components for Flutter — expressive shapes, FABs, button groups, and more.

This package brings [Material 3 Expressive](https://m3.material.io/blog/building-with-m3-expressive) (May 2025) to Flutter, including the **35 iconic shapes** library with built-in shape morphing.

## Features

- **35 M3 Expressive iconic shapes** via `MaterialShapes` / `M3eShapeId` (`circle`, `square`, `heart`, `flower`, `cookie9Sided`, …)
- **`M3eShape`** — versatile shape widget (solid color, image, border, RTL-aware)
- **`M3eShapeBorder` / `M3eMorphBorder`** — `ShapeBorder` for `ShapeDecoration`, `Material`, `Card`
- **`M3eShapeClipper` / `M3eMorphClipper`** — `CustomClipper<Path>` for `ClipPath`
- **`MorphShape` / `AnimatedM3eShape` / `ShapeSequenceMorph`** — morph animations with `Morph`
- **`M3eLoadingIndicator` / `M3eContainedLoadingIndicator`** — M3 Expressive loading indicators (also via `M3eShapes.LoadingIndicator()` / `M3eShapes.ContainedLoadingIndicator()`) — indeterminate (morph + rotation) and determinate (progress 0..1)
- **Backward compatible** `Circle` widget (now delegates to `M3eShape`)
- FABs (`M3eFab`), Button Groups, App Bars, etc.

## Getting started

```yaml
dependencies:
  m3_expressive_flutter: ^0.0.1
```

```dart
import 'package:m3_expressive_flutter/m3_expressive_flutter.dart';
```

Requires Flutter `>=3.7` / Dart `>=3.7`. Depends on
[`material_3p`](https://pub.dev/packages/material_3p) and
[`androidx_graphics_shapes`](https://pub.dev/packages/androidx_graphics_shapes).

## Usage

### 35 iconic shapes — all shapes

| Category | Shapes |
|----------|--------|
| Basic | `circle`, `square`, `pill`, `oval` |
| Geometric | `triangle`, `diamond`, `pentagon` |
| Directional | `arch`, `arrow`, `fan`, `semiCircle`, `slanted` |
| Organic | `clamShell`, `flower`, `puffy`, `puffyDiamond`, `gem`, `clover4Leaf`, `clover8Leaf`, `ghostish`, `bun`, `heart` |
| Cookies | `cookie4Sided`, `cookie6Sided`, `cookie7Sided`, `cookie9Sided`, `cookie12Sided` |
| Starburst | `sunny`, `verySunny`, `burst`, `softBurst`, `boom`, `softBoom` |
| Pixel | `pixelCircle`, `pixelTriangle` |

All shapes are normalized `RoundedPolygon`s (`0..1`).

```dart
import 'package:material_3p/material_shapes.dart'; // MaterialShapes

// Access a shape
final polygon = MaterialShapes.flower;
final polygon2 = M3eShapeId.heart.polygon;
final polygon3 = M3eShapes.byName('sunny');

// All 35
for (final id in M3eShapes.all) {
  print('${id.name}: ${id.polygon}');
}
```

### Static shape widget

```dart
// Solid color
M3eShape(shape: MaterialShapes.flower, size: 80, color: Colors.purple)

// Enum shorthand
M3eShape.fromId(id: M3eShapeId.flower, size: 80, color: Colors.purple)

// With image (avatar)
M3eShape(
  shape: MaterialShapes.heart,
  size: 80,
  image: AssetImage('assets/avatar.jpg'),
)

// With border
M3eShape(
  shape: MaterialShapes.circle,
  size: 80,
  color: Colors.white,
  border: BorderSide(color: Colors.black, width: 2),
)

// RTL-aware directional shape
M3eShape(shape: MaterialShapes.arrow, rtlAware: true, size: 80)
```

### ShapeBorder (for Container / Material / Card)

```dart
Container(
  width: 100, height: 100,
  decoration: ShapeDecoration(
    color: Colors.purple,
    shape: M3eShapeBorder(polygon: MaterialShapes.flower),
  ),
)

// Extension
Container(
  decoration: ShapeDecoration(
    shape: MaterialShapes.heart.toShapeBorder(),
    color: Colors.pink,
  ),
)

// Morph border via lerp (for animations)
ShapeBorder.lerp(
  M3eShapeBorder(polygon: MaterialShapes.circle),
  M3eShapeBorder(polygon: MaterialShapes.square),
  t, // 0..1
)
```

### ClipPath

```dart
ClipPath(
  clipper: M3eShapeClipper(polygon: MaterialShapes.sunny),
  child: Image.asset('assets/photo.jpg', fit: BoxFit.cover),
)

// Manual Path
final path = MaterialShapes.flower.toPathForSize(Size(100, 100));
```

### Morph animations

```dart
// Manual progress (e.g. animation controller)
MorphShape(
  start: MaterialShapes.circle,
  end: MaterialShapes.flower,
  progress: _controller.value, // 0..1
  size: 80,
  color: Colors.purple,
)

// Implicitly animated — animates when shape changes
AnimatedM3eShape(
  shape: _isFlower ? MaterialShapes.flower : MaterialShapes.circle,
  size: 80,
  color: Colors.purple,
  duration: Duration(milliseconds: 500),
)

// Sequence
ShapeSequenceMorph(
  shapes: [MaterialShapes.circle, MaterialShapes.square, MaterialShapes.flower],
  progress: _pageController.page ?? 0, // 0..1 across sequence
  size: 80,
)

// Border morph
M3eMorphBorder(
  morph: Morph(MaterialShapes.circle, MaterialShapes.heart),
  progress: _anim.value,
)

// Respects MediaQuery.disableAnimations automatically
```

### Loading indicators

```dart
// Indeterminate (uncontained) — via canonical widget
M3eLoadingIndicator()
M3eLoadingIndicator(color: Colors.purple, size: 38)

// Via M3eShapes shorthand (as requested)
M3eShapes.LoadingIndicator()
M3eShapes.LoadingIndicator(progress: 0.6) // determinate

// Determinate — progress 0..1 morphs Circle@18° → SoftBurst
M3eLoadingIndicator(progress: 0.42)

// Custom polygons (at least 2)
M3eLoadingIndicator(
  polygons: [MaterialShapes.circle, MaterialShapes.square, MaterialShapes.flower],
  progress: 0.5, // determinate
)
// indeterminate with custom polygons
M3eLoadingIndicator(
  polygons: [MaterialShapes.softBurst, MaterialShapes.cookie9Sided, MaterialShapes.pill],
)

// Contained (48dp container + 38dp indicator)
// Canonical
M3eContainedLoadingIndicator()
M3eContainedLoadingIndicator(progress: 0.75)

// Via M3eShapes shorthand
M3eShapes.ContainedLoadingIndicator()
M3eShapes.ContainedLoadingIndicator(progress: 0.3)

// Custom container
M3eContainedLoadingIndicator(
  containerColor: Colors.grey.shade200,
  indicatorColor: Colors.purple,
  containerShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  containerSize: 56,
  indicatorSize: 42,
)
```

Defaults: `M3eLoadingIndicatorDefaults.indeterminatePolygons` (7 shapes) /
`M3eLoadingIndicatorDefaults.determinatePolygons` (2 shapes) /
`M3eLoadingIndicatorDefaults.containerShape` (`StadiumBorder`) /
sizes 38/48dp — all customizable. Respects `MediaQuery.disableAnimations`.

### Legacy Circle (backward compatible)

```dart
// Old — still works
Circle(size: 48, color: Colors.purple, image: myImage)

// New — equivalent
M3eShape(shape: MaterialShapes.circle, size: 48)
```

## Additional information

- **Shape spec**: https://m3.material.io/styles/shape/overview-principles
- **Blog**: https://m3.material.io/blog/building-with-m3-expressive
- **AOSP shapes**: https://developer.android.com/reference/kotlin/androidx/graphics/shapes/package-summary
- **Flutter port**: https://pub.dev/packages/androidx_graphics_shapes

Contributions welcome. Please run `dart format .` and `flutter analyze` before submitting PRs.
