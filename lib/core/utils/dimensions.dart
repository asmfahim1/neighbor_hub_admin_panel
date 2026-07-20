import 'dart:ui' as ui;
import 'package:flutter/widgets.dart';

/// Coarse device class used to pick which mockup (mobile vs. web) to scale
/// against. Mirrors the two product surfaces described in
/// `docs/admen_web_app_ui_functionality.md` §1 (Admin App vs. Admin Web Portal).
enum DeviceType { mobile, tablet, web }

class Dimensions {
  Dimensions._();

  /// Call once per build (e.g. in the `MaterialApp.builder`) so sizing is
  /// computed from the real layout `BuildContext` (`MediaQuery`) instead of
  /// the raw physical display size. Required for the Web Portal, where the
  /// browser window/tab size is what matters, not the monitor's resolution.
  static void init(BuildContext context) => _context = context;

  static BuildContext? _context;

  /// Width at/above which the layout is treated as the Web Portal (desktop
  /// sidebar layout), per `04_UI_UX_GUIDELINES.md` §11 breakpoints.
  static const double webBreakpoint = 1024.0;

  /// Width at/above which the layout is treated as a tablet (rail nav),
  /// below which it's a phone (bottom nav).
  static const double tabletBreakpoint = 600.0;

  static Size get _windowSize {
    final context = _context;
    if (context != null) return MediaQuery.of(context).size;
    final view = ui.PlatformDispatcher.instance.views.first;
    return view.physicalSize / view.devicePixelRatio;
  }

  static double get _screenHeight => _windowSize.height;
  static double get _screenWidth => _windowSize.width;

  /// Current device class, derived from the live window/screen width.
  static DeviceType get deviceType {
    if (_screenWidth >= webBreakpoint) return DeviceType.web;
    if (_screenWidth >= tabletBreakpoint) return DeviceType.tablet;
    return DeviceType.mobile;
  }

  static bool get isMobile => deviceType == DeviceType.mobile;
  static bool get isTablet => deviceType == DeviceType.tablet;
  static bool get isWeb => deviceType == DeviceType.web;

  // Base design sizes from Figma.
  // Mobile/tablet: phone mockup (Admin App). Web: desktop mockup (Admin Web Portal).
  static const double _mobileMockupHeight = 884.0;
  static const double _mobileMockupWidth = 390.0;
  static const double _webMockupHeight = 1024.0;
  static const double _webMockupWidth = 1440.0;

  static double get _mockupHeight =>
      isWeb ? _webMockupHeight : _mobileMockupHeight;
  static double get _mockupWidth => isWeb ? _webMockupWidth : _mobileMockupWidth;

  // Scale factors for responsive design
  static double get _heightRatio => _screenHeight / _mockupHeight;
  static double get _widthRatio => _screenWidth / _mockupWidth;

  // Font scaling
  static double get _fontRatio => (_widthRatio + _heightRatio) / 2;

  /// Use for vertical values like height, vertical padding/margin
  static double height(double value) => value * _heightRatio;

  /// Use for horizontal values like width, horizontal padding/margin
  static double width(double value) => value * _widthRatio;

  /// Use for font sizes
  static double font(double value) => value * _fontRatio;

  /// Use for border radius
  static double radius(double value) => value * _widthRatio;

  /// Use for icon sizes
  static double icon(double value) => value * _widthRatio;

  /// Use for border width
  static double border(double value) => value * _widthRatio;

  /// EdgeInsets helpers
  static EdgeInsets allPadding(double padding) => EdgeInsets.all(width(padding));
  static EdgeInsets paddingHorizontal(double horizontal) =>
      EdgeInsets.symmetric(horizontal: width(horizontal));
  static EdgeInsets paddingVertical(double vertical) =>
      EdgeInsets.symmetric(vertical: height(vertical));
  static EdgeInsets paddingTop(double top) => EdgeInsets.only(top: height(top));
  static EdgeInsets paddingBottom(double bottom) => EdgeInsets.only(bottom: height(bottom));
  static EdgeInsets paddingLeft(double left) => EdgeInsets.only(left: width(left));
  static EdgeInsets paddingRight(double right) => EdgeInsets.only(right: width(right));
  static EdgeInsets paddingSymmetric({
    double horizontal = 0,
    double vertical = 0,
  }) =>
      EdgeInsets.symmetric(
        horizontal: width(horizontal),
        vertical: height(vertical),
      );
  static EdgeInsets paddingOnly({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) =>
      EdgeInsets.only(
        left: width(left),
        top: height(top),
        right: width(right),
        bottom: height(bottom),
      );

  /// Margin helpers
  static EdgeInsets marginAll(double margin) => EdgeInsets.all(width(margin));
  static EdgeInsets marginHorizontal(double horizontal) =>
      EdgeInsets.symmetric(horizontal: width(horizontal));
  static EdgeInsets marginVertical(double vertical) =>
      EdgeInsets.symmetric(vertical: height(vertical));
  static EdgeInsets marginTop(double top) => EdgeInsets.only(top: height(top));
  static EdgeInsets marginBottom(double bottom) => EdgeInsets.only(bottom: height(bottom));
  static EdgeInsets marginLeft(double left) => EdgeInsets.only(left: width(left));
  static EdgeInsets marginRight(double right) => EdgeInsets.only(right: width(right));
  static EdgeInsets marginSymmetric({
    double horizontal = 0,
    double vertical = 0,
  }) =>
      EdgeInsets.symmetric(
        horizontal: width(horizontal),
        vertical: height(vertical),
      );
  static EdgeInsets marginOnly({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) =>
      EdgeInsets.only(
        left: width(left),
        top: height(top),
        right: width(right),
        bottom: height(bottom),
      );
}
