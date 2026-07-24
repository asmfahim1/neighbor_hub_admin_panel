import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

/// Coarse device class used for responsive layout.
enum DeviceType { mobile, tablet, web }

class Dimensions {
  Dimensions._();

  /// Call once per build from `MaterialApp.builder` so the helpers use the
  /// current logical viewport instead of physical display pixels.
  static void init(BuildContext context) => _context = context;

  static BuildContext? _context;

  /// Width at/above which the layout uses the desktop/web sidebar pattern.
  static const double webBreakpoint = 1024.0;

  /// Width at/above which compact layouts may use tablet density.
  static const double tabletBreakpoint = 600.0;

  static Size get _windowSize {
    final context = _context;
    if (context != null) return MediaQuery.of(context).size;
    final view = ui.PlatformDispatcher.instance.views.first;
    return view.physicalSize / view.devicePixelRatio;
  }

  static double get _screenHeight => _windowSize.height;
  static double get _screenWidth => _windowSize.width;

  /// Current device class by logical width. Responsive layout follows the
  /// viewport size, not the platform, so wide windows get desktop navigation
  /// and narrow windows get compact navigation.
  static DeviceType get deviceType {
    if (_screenWidth >= webBreakpoint) return DeviceType.web;
    if (_screenWidth >= tabletBreakpoint) return DeviceType.tablet;
    return DeviceType.mobile;
  }

  static bool get isMobile => deviceType == DeviceType.mobile;
  static bool get isTablet => deviceType == DeviceType.tablet;
  static bool get isWeb => deviceType == DeviceType.web;

  static const double _mobileMockupHeight = 884.0;
  static const double _mobileMockupWidth = 390.0;
  static const double _webMockupHeight = 1024.0;
  static const double _webMockupWidth = 1440.0;

  static double get _mockupHeight =>
      isWeb ? _webMockupHeight : _mobileMockupHeight;
  static double get _mockupWidth => isWeb ? _webMockupWidth : _mobileMockupWidth;

  /// Keep scaling bounded. Unbounded ratios made tablet/desktop-width windows
  /// inflate controls and text spacing too aggressively.
  static double get _heightRatio =>
      (_screenHeight / _mockupHeight).clamp(0.85, 1.18).toDouble();
  static double get _widthRatio =>
      (_screenWidth / _mockupWidth).clamp(0.85, 1.18).toDouble();

  /// Keep font sizes stable; layout should adapt through constraints.
  static double get _fontRatio => 1.0;

  static double height(double value) => value * _heightRatio;

  static double width(double value) => value * _widthRatio;

  static double font(double value) => value * _fontRatio;

  static double radius(double value) => value * _widthRatio;

  static double icon(double value) => value * _widthRatio;

  static double border(double value) => value * _widthRatio;

  static EdgeInsets allPadding(double padding) => EdgeInsets.all(width(padding));

  static EdgeInsets paddingHorizontal(double horizontal) =>
      EdgeInsets.symmetric(horizontal: width(horizontal));

  static EdgeInsets paddingVertical(double vertical) =>
      EdgeInsets.symmetric(vertical: height(vertical));

  static EdgeInsets paddingTop(double top) => EdgeInsets.only(top: height(top));

  static EdgeInsets paddingBottom(double bottom) =>
      EdgeInsets.only(bottom: height(bottom));

  static EdgeInsets paddingLeft(double left) => EdgeInsets.only(left: width(left));

  static EdgeInsets paddingRight(double right) =>
      EdgeInsets.only(right: width(right));

  static EdgeInsets paddingSymmetric({
    double horizontal = 0,
    double vertical = 0,
  }) {
    return EdgeInsets.symmetric(
      horizontal: width(horizontal),
      vertical: height(vertical),
    );
  }

  static EdgeInsets paddingOnly({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) {
    return EdgeInsets.only(
      left: width(left),
      top: height(top),
      right: width(right),
      bottom: height(bottom),
    );
  }

  static EdgeInsets marginAll(double margin) => EdgeInsets.all(width(margin));

  static EdgeInsets marginHorizontal(double horizontal) =>
      EdgeInsets.symmetric(horizontal: width(horizontal));

  static EdgeInsets marginVertical(double vertical) =>
      EdgeInsets.symmetric(vertical: height(vertical));

  static EdgeInsets marginTop(double top) => EdgeInsets.only(top: height(top));

  static EdgeInsets marginBottom(double bottom) =>
      EdgeInsets.only(bottom: height(bottom));

  static EdgeInsets marginLeft(double left) => EdgeInsets.only(left: width(left));

  static EdgeInsets marginRight(double right) =>
      EdgeInsets.only(right: width(right));

  static EdgeInsets marginSymmetric({
    double horizontal = 0,
    double vertical = 0,
  }) {
    return EdgeInsets.symmetric(
      horizontal: width(horizontal),
      vertical: height(vertical),
    );
  }

  static EdgeInsets marginOnly({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) {
    return EdgeInsets.only(
      left: width(left),
      top: height(top),
      right: width(right),
      bottom: height(bottom),
    );
  }
}
