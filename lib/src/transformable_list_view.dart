import 'package:flutter/material.dart';
import 'package:transformable_list_view/src/transform_wrapper_callback.dart';

import 'package:transformable_list_view/transformable_list_view.dart';

/// {@template transformable_list_view}
/// Extends [ListView] with [getTransformMatrix] callback that allows to add transform animations.
/// {@endtemplate}
class TransformableListView extends ListView {
  /// Receives [TransformableListItem] that contains data about item(offset, size, index, viewport constraints)
  /// and returns [Matrix4] that represents item transformations on the current offset. If it returns [Matrix4.identity()] no transformation will be applied
  final TransformMatrixCallback getTransformMatrix;
  final TransformOpacityCallback getTransformOpacity;

  /// {@macro transformable_list_view}
  TransformableListView({
    required this.getTransformMatrix,
    required this.getTransformOpacity,
    super.key,
    super.scrollDirection,
    super.reverse,
    super.controller,
    super.primary,
    super.physics,
    super.shrinkWrap,
    super.padding,
    super.itemExtent,
    super.addAutomaticKeepAlives,
    super.addRepaintBoundaries,
    super.addSemanticIndexes,
    super.cacheExtent,
    super.children,
    super.semanticChildCount,
    super.dragStartBehavior,
    super.keyboardDismissBehavior,
    super.restorationId,
    super.clipBehavior,
  });

  /// {@macro transformable_list_view}
  TransformableListView.builder({
    required super.itemBuilder,
    required this.getTransformMatrix,
    required this.getTransformOpacity,
    super.key,
    super.scrollDirection,
    super.reverse,
    super.controller,
    super.primary,
    super.physics,
    super.shrinkWrap,
    super.padding,
    super.itemExtent,
    super.findChildIndexCallback,
    super.itemCount,
    super.addAutomaticKeepAlives,
    super.addRepaintBoundaries,
    super.addSemanticIndexes,
    super.cacheExtent,
    super.semanticChildCount,
    super.dragStartBehavior,
    super.keyboardDismissBehavior,
    super.restorationId,
    super.clipBehavior,
  }) : super.builder();

  /// {@macro transformable_list_view}
  TransformableListView.separated({
    required this.getTransformMatrix,
    required this.getTransformOpacity,
    required super.itemBuilder,
    required super.separatorBuilder,
    required super.itemCount,
    super.key,
    super.scrollDirection = Axis.vertical,
    super.reverse,
    super.controller,
    super.primary,
    super.physics,
    super.shrinkWrap,
    super.padding,
    super.findChildIndexCallback,
    super.addAutomaticKeepAlives,
    super.addRepaintBoundaries,
    super.addSemanticIndexes,
    super.cacheExtent,
    super.dragStartBehavior,
    super.keyboardDismissBehavior,
    super.restorationId,
    super.clipBehavior,
  }) : super.separated();

  /// {@macro transformable_list_view}
  const TransformableListView.custom({
    required this.getTransformMatrix,
    required this.getTransformOpacity,
    required super.childrenDelegate,
    super.key,
    super.scrollDirection,
    super.reverse,
    super.controller,
    super.primary,
    super.physics,
    super.shrinkWrap,
    super.padding,
    super.itemExtent,
    super.cacheExtent,
    super.semanticChildCount,
    super.dragStartBehavior,
    super.keyboardDismissBehavior,
    super.restorationId,
    super.clipBehavior,
  }) : super.custom();

  @override
  Widget buildChildLayout(BuildContext context) {
    /// TODO [SliverPrototypeExtentList] && [prototypeItem]
    /// TODO Matrix + Alignment

    final itemExtent = this.itemExtent;

    if (itemExtent != null) {
      return TransformableSliverFixedExtentList(
        itemExtent: itemExtent,
        delegate: childrenDelegate,
        getTransformMatrix: getTransformMatrix,
        getTransformOpacity: getTransformOpacity,
      );
    }

    return TransformableSliverList(
      delegate: childrenDelegate,
      getTransformOpacity: getTransformOpacity,
      getTransformMatrix: getTransformMatrix,
    );
  }
}
