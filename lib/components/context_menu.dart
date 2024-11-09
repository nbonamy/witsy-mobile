// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// The context menu arranges itself slightly differently based on the location
// on the screen of [CupertinoContextMenu.child] before the
// [CupertinoContextMenu] opens.
enum ContextMenuLocation {
  center,
  left,
  right,
}

// The menu that displays when CupertinoContextMenu is open. It consists of a
// list of actions that are typically CupertinoContextMenuActions.
class CupertinoContextMenuSheet extends StatefulWidget {
  CupertinoContextMenuSheet({
    super.key,
    required this.actions,
    required this.contextMenuLocation,
    required this.orientation,
  }) : assert(actions.isNotEmpty);

  final List<Widget> actions;
  final ContextMenuLocation contextMenuLocation;
  final Orientation orientation;

  @override
  State<CupertinoContextMenuSheet> createState() =>
      _CupertinoContextMenuSheetState();
}

class _CupertinoContextMenuSheetState extends State<CupertinoContextMenuSheet> {
  late final ScrollController _controller;
  static const double _kMenuWidth = 250.0;
  // Eyeballed on a context menu on an iOS 15 simulator running iOS 17.5.
  //static const double _kScrollbarMainAxisMargin = 13.0;

  @override
  void initState() {
    super.initState();
    // Link the scrollbar to the scroll view by providing both the same scroll
    // controller. Using SingleChildScrollview.primary might conflict with users
    // already using the PrimaryScrollController.
    _controller = ScrollController();
  }

  // Get the children, whose order depends on orientation and
  // contextMenuLocation.
  List<Widget> getChildren(BuildContext context) {
    final theme = Theme.of(context);
    final border = BorderSide(
      color: theme.colorScheme.onSurface.withOpacity(0.4),
      width: 0.4,
    );
    const borderRadius = Radius.circular(13.0);
    final Widget menu = SizedBox(
      width: _kMenuWidth,
      child: IntrinsicHeight(
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(borderRadius),
            boxShadow: [
              BoxShadow(
                color: theme.brightness == Brightness.dark
                    ? const Color(0x20FFFFFF)
                    : const Color(0x1C000000),
                blurRadius: 32.0,
                spreadRadius: 24.0,
              ),
            ],
          ),
          position: DecorationPosition.background,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(13.0),
            child: ScrollConfiguration(
              behavior:
                  ScrollConfiguration.of(context).copyWith(scrollbars: false),
              child: CupertinoScrollbar(
                //mainAxisMargin: _kScrollbarMainAxisMargin,
                controller: _controller,
                child: SingleChildScrollView(
                  controller: _controller,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      DecoratedBox(
                        decoration: BoxDecoration(
                          border: Border(
                            top: border,
                            left: border,
                            right: border,
                            bottom: border,
                          ),
                        ),
                        position: DecorationPosition.foreground,
                        child: widget.actions.first,
                      ),
                      for (final Widget action in widget.actions.skip(1))
                        DecoratedBox(
                          decoration: BoxDecoration(
                            border: Border(
                              left: border,
                              right: border,
                              bottom: border,
                            ),
                          ),
                          position: DecorationPosition.foreground,
                          child: action,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return switch (widget.contextMenuLocation) {
      ContextMenuLocation.center
          when widget.orientation == Orientation.portrait =>
        <Widget>[const Spacer(), menu, const Spacer()],
      ContextMenuLocation.center => <Widget>[menu, const Spacer()],
      ContextMenuLocation.right => <Widget>[const Spacer(), menu],
      ContextMenuLocation.left => <Widget>[menu, const Spacer()],
    };
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: getChildren(context),
    );
  }
}

class CupertinoContextMenuAction extends StatefulWidget {
  /// Construct a CupertinoContextMenuAction.
  const CupertinoContextMenuAction({
    super.key,
    required this.child,
    this.isDefaultAction = false,
    this.isDestructiveAction = false,
    this.onPressed,
    this.trailingIcon,
  });

  /// The widget that will be placed inside the action.
  final Widget child;

  /// Indicates whether this action should receive the style of an emphasized,
  /// default action.
  final bool isDefaultAction;

  /// Indicates whether this action should receive the style of a destructive
  /// action.
  final bool isDestructiveAction;

  /// Called when the action is pressed.
  final VoidCallback? onPressed;

  /// An optional icon to display to the right of the child.
  ///
  /// Will be colored in the same way as the [TextStyle] used for [child] (for
  /// example, if using [isDestructiveAction]).
  final IconData? trailingIcon;

  @override
  State<CupertinoContextMenuAction> createState() =>
      _CupertinoContextMenuActionState();
}

class _CupertinoContextMenuActionState
    extends State<CupertinoContextMenuAction> {
  // static const Color _kBackgroundColor = CupertinoDynamicColor.withBrightness(
  //   color: Color(0xFFF1F1F1),
  //   darkColor: Color(0xFF212122),
  // );
  // static const Color _kBackgroundColorPressed =
  //     CupertinoDynamicColor.withBrightness(
  //   color: Color(0xFFDDDDDD),
  //   darkColor: Color(0xFF3F3F40),
  // );
  static const double _kButtonHeight = 43;
  static const TextStyle _kActionSheetActionStyle = TextStyle(
    fontFamily: 'CupertinoSystemText',
    inherit: false,
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    color: CupertinoColors.black,
    textBaseline: TextBaseline.alphabetic,
  );

  final GlobalKey _globalKey = GlobalKey();
  bool _isPressed = false;

  void onTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
  }

  void onTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
  }

  void onTapCancel() {
    setState(() {
      _isPressed = false;
    });
  }

  TextStyle get _textStyle {
    final theme = Theme.of(context);
    if (widget.isDefaultAction) {
      return _kActionSheetActionStyle.copyWith(
        color: theme.colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      );
    }
    if (widget.isDestructiveAction) {
      return _kActionSheetActionStyle.copyWith(
        color: CupertinoColors.destructiveRed,
      );
    }
    return _kActionSheetActionStyle.copyWith(
      color: theme.colorScheme.onSurface,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MouseRegion(
      cursor: widget.onPressed != null && kIsWeb
          ? SystemMouseCursors.click
          : MouseCursor.defer,
      child: GestureDetector(
        key: _globalKey,
        onTapDown: onTapDown,
        onTapUp: onTapUp,
        onTapCancel: onTapCancel,
        onTap: widget.onPressed,
        behavior: HitTestBehavior.opaque,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: _kButtonHeight,
          ),
          child: Semantics(
            button: true,
            child: ColoredBox(
              color: _isPressed
                  ? theme.colorScheme.surfaceContainerHigh
                  : theme.brightness == Brightness.dark
                      ? theme.colorScheme.surfaceContainerHigh
                      : theme.colorScheme.surface,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15.5, 8.0, 17.5, 8.0),
                child: DefaultTextStyle(
                  style: _textStyle,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Flexible(child: widget.child),
                      if (widget.trailingIcon != null)
                        Icon(
                          widget.trailingIcon,
                          color: _textStyle.color,
                          size: 21.0,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
