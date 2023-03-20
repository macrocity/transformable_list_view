import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:transformable_list_view/src/transform_matrix_callback.dart';
import 'package:transformable_list_view/src/transform_wrapper_callback.dart';
import 'package:transformable_list_view/src/transformable_list_item.dart';

mixin TransformableRenderSliverMultiBoxAdaptor on RenderSliverMultiBoxAdaptor {
  abstract final TransformMatrixCallback getTransformMatrix;
  abstract final TransformOpacityCallback getTransformOpacity;

  /// transform of each child
  final cachedTransforms = <RenderBox, Matrix4>{};
  final cachedOpacities = <RenderBox, double>{};

  @override
  void paint(PaintingContext context, Offset offset) {
    //// Copied from [RenderSliverMultiBoxAdaptor] except the OVERRIDE

    if (firstChild == null) return;
    // offset is to the top-left corner, regardless of our axis direction.
    // originOffset gives us the delta from the real origin to the origin in the axis direction.
    final Offset mainAxisUnit, crossAxisUnit, originOffset;
    final bool addExtent;
    switch (applyGrowthDirectionToAxisDirection(constraints.axisDirection, constraints.growthDirection)) {
      case AxisDirection.up:
        mainAxisUnit = const Offset(0.0, -1.0);
        crossAxisUnit = const Offset(1.0, 0.0);
        originOffset = offset + Offset(0.0, geometry!.paintExtent);
        addExtent = true;
        break;
      case AxisDirection.right:
        mainAxisUnit = const Offset(1.0, 0.0);
        crossAxisUnit = const Offset(0.0, 1.0);
        originOffset = offset;
        addExtent = false;
        break;
      case AxisDirection.down:
        mainAxisUnit = const Offset(0.0, 1.0);
        crossAxisUnit = const Offset(1.0, 0.0);
        originOffset = offset;
        addExtent = false;
        break;
      case AxisDirection.left:
        mainAxisUnit = const Offset(-1.0, 0.0);
        crossAxisUnit = const Offset(0.0, 1.0);
        originOffset = offset + Offset(geometry!.paintExtent, 0.0);
        addExtent = true;
        break;
    }
    RenderBox? child = lastChild;
    while (child != null) {
      final double mainAxisDelta = childMainAxisPosition(child);
      final double crossAxisDelta = childCrossAxisPosition(child);
      Offset childOffset = Offset(
        originOffset.dx + mainAxisUnit.dx * mainAxisDelta + crossAxisUnit.dx * crossAxisDelta,
        originOffset.dy + mainAxisUnit.dy * mainAxisDelta + crossAxisUnit.dy * crossAxisDelta,
      );
      if (addExtent) childOffset += mainAxisUnit * paintExtentOf(child);

      // If the child's visible interval (mainAxisDelta, mainAxisDelta + paintExtentOf(child))
      // does not intersect the paint extent interval (0, constraints.remainingPaintExtent), it's hidden.
      if (mainAxisDelta < constraints.remainingPaintExtent && mainAxisDelta + paintExtentOf(child) > 0) {
        //// ---------------↓↓↓OVERRIDE↓↓↓---------------
        final paintTransform = getTransformMatrix(
          TransformableListItem(
            offset: childOffset,
            size: child.size,
            constraints: constraints,
            index: child is RenderIndexedSemantics ? child.index : null,
          ),
        );
        cachedTransforms[child] = paintTransform;

        final paintOpacity = getTransformOpacity(
          TransformableListItem(
            offset: childOffset,
            size: child.size,
            constraints: constraints,
            index: child is RenderIndexedSemantics ? child.index : null,
          ),
        );
        cachedOpacities[child] = paintOpacity;

        /*_transformHandler.layer = context.pushTransform(needsCompositing, childOffset, paintTransform,
            // Pre-transform painting function.
            (context, offset) {
          _opacityHandle.layer = context.pushOpacity(childOffset, 100, (context, offset) {}, oldLayer: _opacityHandle.layer);
        }, oldLayer: _transformHandler.layer);

        context.paintChild(child, childOffset);*/

        /*_transformHandler.layer = context.pushTransform(true, offset, paintTransform, (PaintingContext context, Offset offset) {
          _opacityHandle.layer = context.pushOpacity(offset, 100, painter, oldLayer: _opacityHandle.layer);
        }, oldLayer: _transformHandler.layer);*/

        context.pushOpacity(
          childOffset,
          (paintOpacity * 255).round(),
          (context, offset) =>
              context.pushTransform(needsCompositing, offset, paintTransform, (context, offset) => context.paintChild(child!, offset)),
        );

        /*context.pushTransform(
          needsCompositing,
          childOffset,
          paintTransform,
          (context, offset) => context.paintChild(child!, offset),

          ///TODO add [oldLayer] for perfomance optimization
        );*/

        //// ---------------↑↑↑OVERRIDE↑↑↑---------------
      }

      child = childBefore(child);
    }
  }
}
