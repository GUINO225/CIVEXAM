import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/design_config.dart';
import '../services/design_bus.dart';
import '../utils/palette_utils.dart';

enum PlayThemedScaffoldBodyMode {
  plain,
  panel,
}

class PlayThemedScaffold extends StatelessWidget {
  const PlayThemedScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.bodyMode = PlayThemedScaffoldBodyMode.plain,
    this.bodyPadding,
    this.safeAreaTop,
    this.safeAreaBottom = true,
    this.panelHeightFactor = 1.0,
    this.panelBorderRadius =
        const BorderRadius.only(topLeft: Radius.circular(22), topRight: Radius.circular(22)),
    this.panelOverlayColor,
    this.extendBodyBehindAppBar = true,
  }) : assert(panelHeightFactor > 0 && panelHeightFactor <= 1.0,
            'panelHeightFactor must be between 0 (exclusive) and 1 (inclusive).');

  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final PlayThemedScaffoldBodyMode bodyMode;
  final EdgeInsetsGeometry? bodyPadding;
  final bool? safeAreaTop;
  final bool safeAreaBottom;
  final double panelHeightFactor;
  final BorderRadius panelBorderRadius;
  final Color? panelOverlayColor;
  final bool extendBodyBehindAppBar;

  static const AssetImage _screenBg = AssetImage('assets/images/background_playscreen.png');
  static const AssetImage _panelBg = AssetImage('assets/images/background_playscreen2.png');

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DesignConfig>(
      valueListenable: DesignBus.notifier,
      builder: (context, cfg, _) {
        final textColor =
            textColorForPalette(cfg.bgPaletteName, darkMode: cfg.darkMode);
        final bgColor =
            pastelColors(cfg.bgPaletteName, darkMode: cfg.darkMode).first;
        final overlayStyle = cfg.darkMode
            ? SystemUiOverlayStyle.light.copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: Colors.transparent,
              )
            : SystemUiOverlayStyle.dark.copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: Colors.transparent,
              );

        final theme = Theme.of(context);
        final themedData = theme.copyWith(
          scaffoldBackgroundColor: Colors.transparent,
          appBarTheme: theme.appBarTheme.copyWith(
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: textColor,
          ),
        );

        final resolvedSafeAreaTop = safeAreaTop ??
            (bodyMode == PlayThemedScaffoldBodyMode.plain);

        Widget bodyContent = body;
        if (bodyPadding != null) {
          bodyContent = Padding(padding: bodyPadding!, child: bodyContent);
        }

        switch (bodyMode) {
          case PlayThemedScaffoldBodyMode.plain:
            if (resolvedSafeAreaTop || safeAreaBottom) {
              bodyContent = SafeArea(
                top: resolvedSafeAreaTop,
                bottom: safeAreaBottom,
                left: true,
                right: true,
                child: bodyContent,
              );
            }
            break;
          case PlayThemedScaffoldBodyMode.panel:
            bodyContent = SafeArea(
              top: resolvedSafeAreaTop,
              bottom: safeAreaBottom,
              left: true,
              right: true,
              child: bodyContent,
            );
            final double heightFactor = panelHeightFactor.clamp(0.0, 1.0) as double;
            bodyContent = Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: heightFactor,
                widthFactor: 1,
                child: ClipRRect(
                  borderRadius: panelBorderRadius,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: _panelBg,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Container(
                        color: panelOverlayColor ?? Colors.white.withOpacity(0.04),
                      ),
                      bodyContent,
                    ],
                  ),
                ),
              ),
            );
            break;
        }

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: overlayStyle,
          child: Theme(
            data: themedData,
            child: Scaffold(
              extendBody: true,
              extendBodyBehindAppBar: extendBodyBehindAppBar,
              backgroundColor: Colors.transparent,
              appBar: appBar,
              body: Stack(
                fit: StackFit.expand,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: bgColor,
                      image: const DecorationImage(
                        image: _screenBg,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  bodyContent,
                ],
              ),
              floatingActionButton: floatingActionButton,
              floatingActionButtonLocation: floatingActionButtonLocation,
              bottomNavigationBar: bottomNavigationBar,
            ),
          ),
        );
      },
    );
  }
}
