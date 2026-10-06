## 0.2.0

* Add `M3eLoadingIndicator` / `M3eContainedLoadingIndicator` (Material 3 Expressive loading indicators)
  — indeterminate (morph + rotation, 7 shapes) and determinate (progress 0..1, 2 shapes).
  Also available via `M3eShapes.LoadingIndicator()` / `M3eShapes.ContainedLoadingIndicator()` as requested.
* Add `M3eLoadingIndicatorDefaults` (indicatorSize 38 / containerSize 48 / StadiumBorder /
  indeterminate & determinate polygons) and `MorphPainter`.
* Add comprehensive tests for loading indicators.

## 0.1.0

* Add 35 M3 Expressive iconic shapes via `material_3p` / `M3eShapeId` / `M3eShapes`
  (`circle`, `square`, `pill`, `oval`, `triangle`, `diamond`, `pentagon`, `arch`,
  `arrow`, `fan`, `semiCircle`, `slanted`, `heart`, `bun`, `ghostish`, `clamShell`,
  `flower`, `puffy`, `puffyDiamond`, `gem`, `clover4Leaf`, `clover8Leaf`,
  `cookie4Sided`, `cookie6Sided`, `cookie7Sided`, `cookie9Sided`, `cookie12Sided`,
  `sunny`, `verySunny`, `burst`, `softBurst`, `boom`, `softBoom`, `pixelCircle`,
  `pixelTriangle`).
* Add `M3eShape` widget (solid color, image, border, RTL-aware).
* Add `M3eShapeBorder` / `M3eMorphBorder` (`ShapeBorder`) + `RoundedPolygon` extension.
* Add `M3eShapeClipper` / `M3eMorphClipper` (`CustomClipper<Path>`) + `toPathForSize` extensions.
* Add `MorphShape` / `AnimatedM3eShape` / `ShapeSequenceMorph` morph animations (respects `MediaQuery.disableAnimations`).
* `Circle` now delegates to `M3eShape` with `MaterialShapes.circle` (backward compatible).
* Add `androidx_graphics_shapes` / `material_3p` dependencies.
* Add comprehensive tests for all 35 shapes and morphing.

## 0.0.1

* Initial release.
