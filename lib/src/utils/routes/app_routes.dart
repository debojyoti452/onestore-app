import 'package:flutter/material.dart';
import 'package:onestore_wallet_app/src/screens/add_card/add_card_screen.dart';
import 'package:onestore_wallet_app/src/screens/card_screen/card_list_screen.dart';

class AppRoutes {
  static Route<T> onGenerateRoute<T>(
      RouteSettings settings) {
    switch (settings.name) {
      case CardListScreen.id:
        return _SlideAnimator(
          builder: (_) => const CardListScreen(),
          settings: settings,
        );

      case AddCardScreen.id:
        return _SlideAnimator(
          builder: (_) => const AddCardScreen(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text(
                  'No route defined for ${settings.name}'),
            ),
          ),
          settings: settings,
        );
    }
  }
}

class _SlideAnimator<T> extends MaterialPageRoute<T> {
  _SlideAnimator({
    required WidgetBuilder builder,
    RouteSettings? settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) : super(
          builder: builder,
          settings: settings,
          maintainState: maintainState,
          fullscreenDialog: fullscreenDialog,
        );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(animation),
      child: child,
    );
  }
}
