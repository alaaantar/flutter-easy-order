import 'package:firebase_analytics/observer.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easy_order/bloc/auth_bloc.dart';
import 'package:flutter_easy_order/bloc/category_bloc.dart';
import 'package:flutter_easy_order/bloc/order_bloc.dart';
import 'package:flutter_easy_order/bloc/order_pagination_bloc.dart';
import 'package:flutter_easy_order/bloc/product_bloc.dart';
import 'package:flutter_easy_order/bloc/storage_bloc.dart';
import 'package:flutter_easy_order/models/order_filter.dart';
import 'package:flutter_easy_order/models/user.dart';
import 'package:flutter_easy_order/pages/cart_screen.dart';
import 'package:flutter_easy_order/pages/category_list_screen.dart';
import 'package:flutter_easy_order/pages/order_edit_screen.dart';
import 'package:flutter_easy_order/pages/order_list_screen.dart';
import 'package:flutter_easy_order/pages/privacy_policy_screen.dart';
import 'package:flutter_easy_order/pages/product_edit_screen.dart';
import 'package:flutter_easy_order/pages/product_list_screen.dart';
import 'package:flutter_easy_order/pages/splash_screen.dart';
import 'package:flutter_easy_order/pages/terms_conditions_screen.dart';
import 'package:flutter_easy_order/repository/auth_repository.dart';
import 'package:flutter_easy_order/repository/category_repository.dart';
import 'package:flutter_easy_order/repository/order_repository.dart';
import 'package:flutter_easy_order/repository/product_repository.dart';
import 'package:flutter_easy_order/repository/storage_repository.dart';
import 'package:flutter_easy_order/shared/adaptive_theme.dart';
import 'package:flutter_easy_order/widgets/helpers/logger.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
// import 'package:flutter/rendering.dart';
import 'package:device_preview/device_preview.dart';

void main() {
//   debugPaintSizeEnabled = true;
//   debugPaintBaselinesEnabled = true;
//   debugPaintPointersEnabled = true;
//   debugPrintMarkNeedsLayoutStacks = true;
//   debugPrintMarkNeedsPaintStacks = true;



  // Set `enableInDevMode` to true to see reports while in debug mode
  // This is only to be used for confirming that reports are being
  // submitted as expected. It is not intended to be used for everyday
  // development.
  Crashlytics.instance.enableInDevMode = false;

  // Pass all uncaught errors to Crashlytics.
  FlutterError.onError = (FlutterErrorDetails details) {
    Crashlytics.instance.recordFlutterError(details);
  };

  // Log level
  Logger.level = Level.nothing; // nothing / debug

  runApp(MyApp());
//  runApp(
//    DevicePreview(
//      builder: (context) => MyApp(),
//    ),
//  );
}

class MyApp extends StatelessWidget {
  final Logger logger = getLogger();

  // Set routes to use in Navigator
  final routes = <String, WidgetBuilder>{
    SplashScreen.routeName: (BuildContext context) => SplashScreen(),
    PrivacyPolicyScreen.routeName: (BuildContext context) => PrivacyPolicyScreen(),
    TermsConditionsScreen.routeName: (BuildContext context) => TermsConditionsScreen(),
    CategoryListScreen.routeName: (BuildContext context) => CategoryListScreen(),
    ProductListScreen.routeName: (BuildContext context) => ProductListScreen(),
    OrderListScreen.routeName: (BuildContext context) => OrderListScreen(),
    ProductEditScreen.routeName: (BuildContext context) => ProductEditScreen(),
    OrderEditScreen.routeName: (BuildContext context) => OrderEditScreen(),
    CartScreen.routeName: (BuildContext context) => CartScreen(),
  };

  @override
  Widget build(BuildContext context) {
    logger.d('building main page');

    return MultiProvider(
        providers: [
          Provider<AuthRepository>(
            builder: (BuildContext context) => AuthRepositoryFirebaseImpl(),
            dispose: (BuildContext context, AuthRepository authRepository) => authRepository.dispose(),
          ),
          ProxyProvider<AuthRepository, AuthBloc>(
            builder: (BuildContext context, AuthRepository authRepository, AuthBloc authBloc) =>
                AuthBlocImpl(authRepository: authRepository),
            dispose: (BuildContext context, AuthBloc authBloc) => authBloc.dispose(),
          ),
        ],
        child: Consumer<AuthBloc>(
          builder: (BuildContext context, AuthBloc authBloc, _) {
            return StreamProvider<User>.value(
              value: authBloc.user$, // Provider here
              child: _buildAppStream(authBloc.user$),
            );
          },
        ),
      );
  }

  Widget _buildAppStream(Stream<User> user$) {
    final firebaseAnalytics = FirebaseAnalytics();
    return StreamBuilder<User>(
        stream: user$,
        builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
          logger.d('main user: ${snapshot.data}');

          Widget app = MaterialApp(
//            locale: DevicePreview.of(context).locale,
//            builder: DevicePreview.appBuilder,
//              CupertinoApp(
//              localizationsDelegates: [
//                DefaultMaterialLocalizations.delegate,
//                DefaultCupertinoLocalizations.delegate,
//                DefaultWidgetsLocalizations.delegate,
//              ],
            title: 'Simple Order Manager',
            // debugShowMaterialGrid: true,
            theme: getAdaptiveThemeData(context),
            // home: SplashScreen(),
            routes: routes,
            navigatorObservers: [
              FirebaseAnalyticsObserver(analytics: firebaseAnalytics),
            ],
          );

          // Only if user is not logged in
          if (!snapshot.hasData) {
            return app;
          }

          final User currentUser = snapshot.data;

          // Set Crashlytics user info
          Crashlytics.instance.setUserEmail(currentUser.email);
          Crashlytics.instance.setUserName(currentUser.email);
          Crashlytics.instance.setUserIdentifier(currentUser.id);

          return MultiProvider(
            providers: [
              Provider<StorageRepository>(
                builder: (BuildContext context) => StorageRepositoryImpl(),
              ),
              Provider<CategoryRepository>(
                builder: (BuildContext context) => CategoryRepositoryFirebaseImpl(),
              ),
              Provider<ProductRepository>(
                builder: (BuildContext context) => ProductRepositoryFirebaseImpl(),
              ),
              Provider<OrderRepository>(
                builder: (BuildContext context) => OrderRepositoryFirebaseImpl(),
              ),
              ProxyProvider<StorageRepository, StorageBloc>(
                  builder: (BuildContext context, StorageRepository storageRepository, StorageBloc storageBloc) =>
                      StorageBlocImpl(user: currentUser, storageRepository: storageRepository),
                  dispose: (BuildContext context, StorageBloc storageBloc) => storageBloc.dispose(),
              ),
              ProxyProvider2<ProductRepository, StorageBloc, ProductBloc>(
                  builder: (BuildContext context, ProductRepository productRepository, StorageBloc storageBloc,
                          ProductBloc productBloc) =>
                      ProductBlocImpl(
                          user: currentUser, productRepository: productRepository, storageBloc: storageBloc),
                  dispose: (BuildContext context, ProductBloc productBloc) => productBloc.dispose(),
              ),
              ProxyProvider2<CategoryRepository, StorageBloc, CategoryBloc>(
                  builder: (BuildContext context, CategoryRepository categoryRepository, StorageBloc storageBloc,
                          CategoryBloc categoryBloc) =>
                      CategoryBlocImpl(
                          user: currentUser, categoryRepository: categoryRepository, storageBloc: storageBloc),
                  dispose: (BuildContext context, CategoryBloc categoryBloc) => categoryBloc.dispose(),
              ),
              ProxyProvider<OrderRepository, OrderBloc>(
                builder: (BuildContext context, OrderRepository orderRepository, OrderBloc orderBloc) =>
                    OrderBlocImpl(user: currentUser, orderRepository: orderRepository),
                dispose: (BuildContext context, OrderBloc orderBloc) => orderBloc.dispose(),
              ),
              ChangeNotifierProxyProvider<OrderRepository, OrderPaginationBloc>(
                builder: (BuildContext context, OrderRepository orderRepository, OrderPaginationBloc orderPaginationBloc) =>
                    OrderPaginationBlocImpl(user: currentUser, orderRepository: orderRepository),
//                  dispose: (BuildContext context, OrderPaginationBloc orderPaginationBloc) => orderPaginationBloc.dispose()
              ),
            ],
//            child: app,
            child: Consumer<OrderPaginationBloc>(
              builder: (BuildContext context, OrderPaginationBloc orderPaginationBloc, _) {
                return StreamProvider<OrderFilter>.value(
                  value: orderPaginationBloc.orderFilter$,
                  child: app,
                );
              },
            ),
          );
        });
  }
}
