/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal,deprecated_member_use

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart' as _svg;
import 'package:vector_graphics/vector_graphics.dart' as _vg;

class $AssetsFontsGen {
  const $AssetsFontsGen();

  /// File path: assets/fonts/Britti-Sans-Medium.ttf
  String get brittiSansMedium => 'assets/fonts/Britti-Sans-Medium.ttf';

  /// List of all assets
  List<String> get values => [brittiSansMedium];
}

class $AssetsIconsGen {
  const $AssetsIconsGen();

  /// File path: assets/icons/arrow-up.svg
  SvgGenImage get arrowUp => const SvgGenImage('assets/icons/arrow-up.svg');

  /// File path: assets/icons/back-icon.svg
  SvgGenImage get backIcon => const SvgGenImage('assets/icons/back-icon.svg');

  /// File path: assets/icons/celestia-logo.svg
  SvgGenImage get celestiaLogo =>
      const SvgGenImage('assets/icons/celestia-logo.svg');

  /// File path: assets/icons/search-icon.svg
  SvgGenImage get searchIcon =>
      const SvgGenImage('assets/icons/search-icon.svg');

  /// File path: assets/icons/sun-logo.svg
  SvgGenImage get sunLogo => const SvgGenImage('assets/icons/sun-logo.svg');

  /// List of all assets
  List<SvgGenImage> get values => [
    arrowUp,
    backIcon,
    celestiaLogo,
    searchIcon,
    sunLogo,
  ];
}

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// File path: assets/images/allow-location-image.png
  AssetGenImage get allowLocationImage =>
      const AssetGenImage('assets/images/allow-location-image.png');

  /// File path: assets/images/city1.png
  AssetGenImage get city1 => const AssetGenImage('assets/images/city1.png');

  /// File path: assets/images/city2.png
  AssetGenImage get city2 => const AssetGenImage('assets/images/city2.png');

  /// File path: assets/images/city3.png
  AssetGenImage get city3 => const AssetGenImage('assets/images/city3.png');

  /// File path: assets/images/city4.png
  AssetGenImage get city4 => const AssetGenImage('assets/images/city4.png');

  /// File path: assets/images/city5.png
  AssetGenImage get city5 => const AssetGenImage('assets/images/city5.png');

  /// File path: assets/images/cold.png
  AssetGenImage get cold => const AssetGenImage('assets/images/cold.png');

  /// File path: assets/images/first-screen-image.png
  AssetGenImage get firstScreenImage =>
      const AssetGenImage('assets/images/first-screen-image.png');

  /// Directory path: assets/images/icons-weather
  $AssetsImagesIconsWeatherGen get iconsWeather =>
      const $AssetsImagesIconsWeatherGen();

  /// File path: assets/images/no-city.png
  AssetGenImage get noCity => const AssetGenImage('assets/images/no-city.png');

  /// Directory path: assets/images/savedwether
  $AssetsImagesSavedwetherGen get savedwether =>
      const $AssetsImagesSavedwetherGen();

  /// Directory path: assets/images/splash
  $AssetsImagesSplashGen get splash => const $AssetsImagesSplashGen();

  /// File path: assets/images/sunset.png
  AssetGenImage get sunset => const AssetGenImage('assets/images/sunset.png');

  /// File path: assets/images/warm.png
  AssetGenImage get warm => const AssetGenImage('assets/images/warm.png');

  /// List of all assets
  List<AssetGenImage> get values => [
    allowLocationImage,
    city1,
    city2,
    city3,
    city4,
    city5,
    cold,
    firstScreenImage,
    noCity,
    sunset,
    warm,
  ];
}

class $AssetsImagesIconsWeatherGen {
  const $AssetsImagesIconsWeatherGen();

  /// File path: assets/images/icons-weather/moon-cloud.png
  AssetGenImage get moonCloud =>
      const AssetGenImage('assets/images/icons-weather/moon-cloud.png');

  /// File path: assets/images/icons-weather/rain.png
  AssetGenImage get rain =>
      const AssetGenImage('assets/images/icons-weather/rain.png');

  /// File path: assets/images/icons-weather/sun-cloud.png
  AssetGenImage get sunCloud =>
      const AssetGenImage('assets/images/icons-weather/sun-cloud.png');

  /// File path: assets/images/icons-weather/sun-rain.png
  AssetGenImage get sunRain =>
      const AssetGenImage('assets/images/icons-weather/sun-rain.png');

  /// File path: assets/images/icons-weather/suny.png
  AssetGenImage get suny =>
      const AssetGenImage('assets/images/icons-weather/suny.png');

  /// File path: assets/images/icons-weather/thunder.png
  AssetGenImage get thunder =>
      const AssetGenImage('assets/images/icons-weather/thunder.png');

  /// List of all assets
  List<AssetGenImage> get values => [
    moonCloud,
    rain,
    sunCloud,
    sunRain,
    suny,
    thunder,
  ];
}

class $AssetsImagesSavedwetherGen {
  const $AssetsImagesSavedwetherGen();

  /// File path: assets/images/savedwether/morning.png
  AssetGenImage get morning =>
      const AssetGenImage('assets/images/savedwether/morning.png');

  /// File path: assets/images/savedwether/night.png
  AssetGenImage get night =>
      const AssetGenImage('assets/images/savedwether/night.png');

  /// File path: assets/images/savedwether/noon.png
  AssetGenImage get noon =>
      const AssetGenImage('assets/images/savedwether/noon.png');

  /// List of all assets
  List<AssetGenImage> get values => [morning, night, noon];
}

class $AssetsImagesSplashGen {
  const $AssetsImagesSplashGen();

  /// File path: assets/images/splash/applogo.png
  AssetGenImage get applogo =>
      const AssetGenImage('assets/images/splash/applogo.png');

  /// File path: assets/images/splash/splash.png
  AssetGenImage get splash =>
      const AssetGenImage('assets/images/splash/splash.png');

  /// List of all assets
  List<AssetGenImage> get values => [applogo, splash];
}

class Assets {
  const Assets._();

  static const $AssetsFontsGen fonts = $AssetsFontsGen();
  static const $AssetsIconsGen icons = $AssetsIconsGen();
  static const $AssetsImagesGen images = $AssetsImagesGen();
}

class AssetGenImage {
  const AssetGenImage(this._assetName, {this.size, this.flavors = const {}});

  final String _assetName;

  final Size? size;
  final Set<String> flavors;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({AssetBundle? bundle, String? package}) {
    return AssetImage(_assetName, bundle: bundle, package: package);
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

class SvgGenImage {
  const SvgGenImage(this._assetName, {this.size, this.flavors = const {}})
    : _isVecFormat = false;

  const SvgGenImage.vec(this._assetName, {this.size, this.flavors = const {}})
    : _isVecFormat = true;

  final String _assetName;
  final Size? size;
  final Set<String> flavors;
  final bool _isVecFormat;

  _svg.SvgPicture svg({
    Key? key,
    bool matchTextDirection = false,
    AssetBundle? bundle,
    String? package,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    AlignmentGeometry alignment = Alignment.center,
    bool allowDrawingOutsideViewBox = false,
    WidgetBuilder? placeholderBuilder,
    String? semanticsLabel,
    bool excludeFromSemantics = false,
    _svg.SvgTheme? theme,
    ColorFilter? colorFilter,
    Clip clipBehavior = Clip.hardEdge,
    @deprecated Color? color,
    @deprecated BlendMode colorBlendMode = BlendMode.srcIn,
    @deprecated bool cacheColorFilter = false,
  }) {
    final _svg.BytesLoader loader;
    if (_isVecFormat) {
      loader = _vg.AssetBytesLoader(
        _assetName,
        assetBundle: bundle,
        packageName: package,
      );
    } else {
      loader = _svg.SvgAssetLoader(
        _assetName,
        assetBundle: bundle,
        packageName: package,
        theme: theme,
      );
    }
    return _svg.SvgPicture(
      loader,
      key: key,
      matchTextDirection: matchTextDirection,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      allowDrawingOutsideViewBox: allowDrawingOutsideViewBox,
      placeholderBuilder: placeholderBuilder,
      semanticsLabel: semanticsLabel,
      excludeFromSemantics: excludeFromSemantics,
      colorFilter:
          colorFilter ??
          (color == null ? null : ColorFilter.mode(color, colorBlendMode)),
      clipBehavior: clipBehavior,
      cacheColorFilter: cacheColorFilter,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
