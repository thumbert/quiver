import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Screen that displays one of many demos.
///
/// Multiple demos are available in a drawer.
class QuiverScreen extends StatefulWidget {
  const QuiverScreen({
    Key? key,
    required this.menu,
    required this.initialActiveMenuItem,
  }) : super(key: key);

  final List<DemoMenuGroup> menu;
  final DemoMenuItem initialActiveMenuItem;

  @override
  _QuiverScreenState createState() => _QuiverScreenState();
}

class _QuiverScreenState extends State<QuiverScreen>
    with SingleTickerProviderStateMixin {
  final _drawerOverhangColor = const Color(0xFF607D8B); // blueGrey
  final _drawerOverhangWidth = 48.0;
  final _drawerWidth = 250.0;

  final Color _backgroundColor = Colors.blueGrey.shade50; //Color(0xFF111111);

  late AnimationController _animationController;
  late CurvedAnimation _drawerAnimation;

  late DemoMenuItem _activeMenuItem;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _drawerAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _activeMenuItem = widget.initialActiveMenuItem;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleDrawer() {
    if (!_animationController.isAnimating) {
      if (_animationController.value > 0) {
        _closeDrawer();
      } else {
        _openDrawer();
      }
    }
  }

  void _openDrawer() {
    _animationController.forward();
  }

  void _closeDrawer() {
    _animationController.reverse();
  }

  void _showDemo(DemoMenuItem menuItem) {
    if (menuItem != _activeMenuItem) {
      setState(() {
        _activeMenuItem = menuItem;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _backgroundColor,
      ),
      child: Stack(
        children: [
          _activeMenuItem.pageBuilder(context),
          _buildDrawerTapToClose(),
          _buildDrawer(),
        ],
      ),
    );
  }

  Widget _buildDrawerTapToClose() {
    return AnimatedBuilder(
      animation: _drawerAnimation,
      builder: (context, child) {
        return _drawerAnimation.value > 0
            ? GestureDetector(
                onTap: _closeDrawer,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.transparent,
                ),
              )
            : const SizedBox();
      },
    );
  }

  Widget _buildDrawer() {
    return AnimatedBuilder(
      animation: _drawerAnimation,
      builder: (context, child) {
        return Positioned(
          top: 0,
          bottom: 0,
          left: (_drawerAnimation.value - 1) * _drawerWidth,
          child: Theme(
            data: Theme.of(context)
                .copyWith(backgroundColor: Colors.blueGrey.shade300),
            child: Material(
              color: _drawerOverhangColor,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildDrawerContent(),
                  _buildDrawerOverhang(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDrawerOverhang() {
    return InkWell(
      onTap: () {
        _toggleDrawer();
      },
      child: Container(
        padding: const EdgeInsets.only(top: 8),
        width: _drawerOverhangWidth,
        child: Column(
          children: [
            SvgPicture.asset(
              'assets/images/quiver.svg',
              semanticsLabel: 'Quiver',
              color: Colors.white,
              height: 48,
              width: 48,
            ),
            Expanded(
              child: Center(
                child: IconButton(
                  icon: Icon(_drawerAnimation.value > 0
                      ? Icons.chevron_left
                      : Icons.chevron_right),
                  onPressed: _toggleDrawer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerContent() {
    return Container(
      padding: const EdgeInsets.only(top: 8),
      decoration: const BoxDecoration(color: Colors.blueGrey),
      child: SizedBox(
        width: _drawerWidth,
        child: Column(
          children: [
            const Text(
              'Quiver',
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Tangerine',
                  fontSize: 48,
                  fontWeight: FontWeight.w600),
            ),
            SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final group in widget.menu) ...[
                    Container(
                      height: 24,
                      color: Colors.blueGrey,
                    ),
                    _buildMenuGroupHeader(title: group.title),
                    for (final item in group.items) ...[
                      _buildMenuItem(item),
                    ],
                  ],
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMenuGroupHeader({
    required String title,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      // color: const Color(0xFF303030), //Color(0xFF202020),
      child: Text(
        title,
        textAlign: TextAlign.left,
        style: const TextStyle(
          // color: Color(0xFFAAAAAA),
          color: Colors.white,
          fontSize: 20,
        ),
      ),
    );
  }

  Widget _buildMenuItem(DemoMenuItem item) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.blueGrey, //Color(0xFF303030),
      ),
      child: MouseRegion(
        onEnter: (_) {
          setState(() {
            item.isHighlighted = true;
          });
        },
        onExit: (_) {
          setState(() {
            item.isHighlighted = false;
          });
        },
        child: ListTile(
          visualDensity: const VisualDensity(vertical: -4),
          dense: true,
          leading: Icon(
            Icons.label_important_outline,
            color: item.isHighlighted ? Colors.white : Colors.blueGrey.shade400,
          ),
          title: Transform.translate(
            offset: const Offset(-20, 0),
            child: Text(
              item.title,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ),
          onTap: () {
            _showDemo(item);
            _closeDrawer();
          },
        ),
      ),
    );
  }
}

/// Group of demo menu items, with a title.
class DemoMenuGroup {
  const DemoMenuGroup({
    required this.title,
    required this.items,
  });

  /// Title of the group of demos.
  final String title;

  /// The menu items for each demo in the group.
  final List<DemoMenuItem> items;
}

/// Menu item for a single Processing demo.
class DemoMenuItem {
  DemoMenuItem({
    this.icon,
    required this.title,
    this.subtitle,
    required this.pageBuilder,
    this.isHighlighted = false,
  });

  /// Icon that represents the demo.
  final IconData? icon;

  /// Title of the demo.
  final String title;

  /// Secondary information about the demo.
  final String? subtitle;

  /// `WidgetBuilder` that creates the demo.
  final WidgetBuilder pageBuilder;

  /// if the label icon next to the title is highlighted or not
  bool isHighlighted;
}
