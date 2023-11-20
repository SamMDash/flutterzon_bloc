import 'package:flutter/material.dart';
import 'package:flutter_amazon_clone_bloc/src/config/router/app_route_constants.dart';
import 'package:flutter_amazon_clone_bloc/src/data/models/order.dart';
import 'package:flutter_amazon_clone_bloc/src/data/models/product.dart';
import 'package:flutter_amazon_clone_bloc/src/data/repositories/account_repository.dart';
import 'package:flutter_amazon_clone_bloc/src/data/repositories/category_products_repository.dart';
import 'package:flutter_amazon_clone_bloc/src/data/repositories/search_products_repository.dart';
import 'package:flutter_amazon_clone_bloc/src/logic/blocs/account/fetch_orders/fethc_orders_cubit.dart';
import 'package:flutter_amazon_clone_bloc/src/logic/blocs/account/keep_shopping_for/cubit/keep_shopping_for_cubit.dart';
import 'package:flutter_amazon_clone_bloc/src/logic/blocs/account/product_rating/product_rating_bloc.dart';
import 'package:flutter_amazon_clone_bloc/src/logic/blocs/account/wish_list/wish_list_cubit.dart';
import 'package:flutter_amazon_clone_bloc/src/logic/blocs/category_products/fetch_category_products_bloc/fetch_category_products_bloc.dart';
import 'package:flutter_amazon_clone_bloc/src/logic/blocs/product_details/user_rating/user_rating_cubit.dart';
import 'package:flutter_amazon_clone_bloc/src/logic/blocs/search/bloc/search_bloc.dart';
import 'package:flutter_amazon_clone_bloc/src/presentation/views/account/browsing_history.dart';
import 'package:flutter_amazon_clone_bloc/src/presentation/views/account/orders/order_details.dart';
import 'package:flutter_amazon_clone_bloc/src/presentation/views/account/orders/search_orders_screen.dart';
import 'package:flutter_amazon_clone_bloc/src/presentation/views/account/orders/your_orders.dart';
import 'package:flutter_amazon_clone_bloc/src/presentation/views/account/wish_list_screen.dart';
import 'package:flutter_amazon_clone_bloc/src/presentation/views/another_screen.dart';
import 'package:flutter_amazon_clone_bloc/src/presentation/views/auth/auth_screen.dart';
import 'package:flutter_amazon_clone_bloc/src/presentation/views/bottom_navigation_bar/bottom_bar.dart';
import 'package:flutter_amazon_clone_bloc/src/presentation/views/category_products/category_products_screen.dart';
import 'package:flutter_amazon_clone_bloc/src/presentation/views/home/home_screen.dart';
import 'package:flutter_amazon_clone_bloc/src/presentation/views/menu/menu_screen.dart';
import 'package:flutter_amazon_clone_bloc/src/presentation/views/product_details/product_details_screen.dart';
import 'package:flutter_amazon_clone_bloc/src/presentation/views/search/search_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

final _fetchCategoryProductsBloc =
    FetchCategoryProductsBloc(CategoryProductsRepository());

final _searchProductBloc = SearchBloc(SearchProductsRepository());

final router = GoRouter(initialLocation: '/', routes: [
  GoRoute(
    name: AppRouteConstants.authRoute.name,
    path: AppRouteConstants.authRoute.path,
    pageBuilder: (context, state) {
      return const MaterialPage(child: AuthScreen());
    },
  ),
  GoRoute(
    name: AppRouteConstants.bottomBarRoute.name,
    path: AppRouteConstants.bottomBarRoute.path,
    pageBuilder: (context, state) {
      return MaterialPage(child: BottomBar());
    },
  ),
  GoRoute(
    name: AppRouteConstants.homeScreenRoute.name,
    path: AppRouteConstants.homeScreenRoute.path,
    pageBuilder: (context, state) {
      return const MaterialPage(child: HomeScreen());
    },
  ),
  GoRoute(
    name: AppRouteConstants.orderDetailsScreenRoute.name,
    path: AppRouteConstants.orderDetailsScreenRoute.path,
    pageBuilder: (context, state) {
      final order = state.extra as Order;

      return MaterialPage(
          child: BlocProvider.value(
        value: ProductRatingBloc(AccountRepository())
          ..add(GetProductRatingEvent(order: order)),
        child: OrderDetailsScreen(order: order),
      ));
    },
  ),
  GoRoute(
    name: AppRouteConstants.productDetailsScreenRoute.name,
    path: AppRouteConstants.productDetailsScreenRoute.path,
    pageBuilder: (context, state) {
      Map<String, dynamic> extraData = state.extra as Map<String, dynamic>;

      final product = extraData["product"] as Product;
      final deliveryDate = extraData["deliveryDate"] as String;
      final averageRating = extraData["averageRating"] as double;

      return MaterialPage(
          child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                UserRatingCubit(AccountRepository())..userRating(product),
          ),
          BlocProvider(
            create: (context) =>
                FetchCategoryProductsBloc(CategoryProductsRepository())
                  ..add(CategoryPressedEvent(category: product.category)),
          ),
        ],
        child: ProductDetailsScreen(
          product: product,
          deliveryDate: deliveryDate,
          averageRating: averageRating,
        ),
      ));
    },
  ),
  GoRoute(
    name: AppRouteConstants.browsingHistoryScreenRoute.name,
    path: AppRouteConstants.browsingHistoryScreenRoute.path,
    pageBuilder: (context, state) {
      return MaterialPage(
          child: BlocProvider.value(
              value: KeepShoppingForCubit(AccountRepository())
                ..keepShoppingFor(),
              child: const BrowsingHistory()));
    },
  ),
  GoRoute(
      path: AppRouteConstants.yourOrdersScreenRoute.path,
      name: AppRouteConstants.yourOrdersScreenRoute.name,
      pageBuilder: (context, state) {
        return MaterialPage(
          child: BlocProvider.value(
            value: FetchOrdersCubit(AccountRepository())..fetchOrders(),
            child: const YourOrders(),
          ),
        );
      }),
  GoRoute(
      path: AppRouteConstants.yourWishListScreenRoute.path,
      name: AppRouteConstants.yourWishListScreenRoute.name,
      pageBuilder: (context, state) {
        return MaterialPage(
          child: BlocProvider.value(
            value: WishListCubit(AccountRepository())..getWishList(),
            child: const WishListScreen(),
          ),
        );
      }),
  GoRoute(
    name: AppRouteConstants.anotherScreenRoute.name,
    path: AppRouteConstants.anotherScreenRoute.path,
    pageBuilder: (context, state) {
      final String appBarTitle = state.pathParameters['appBarTitle']!;
      return MaterialPage(
          child: AnotherScreen(
        appBarTitle: appBarTitle,
      ));
    },
  ),
  GoRoute(
    name: AppRouteConstants.categoryproductsScreenRoute.name,
    path: '${AppRouteConstants.categoryproductsScreenRoute.path}/:category',
    pageBuilder: (context, state) {
      final category = state.pathParameters['category'];

      return MaterialPage(
          child: BlocProvider.value(
        value: _fetchCategoryProductsBloc
          ..add(CategoryPressedEvent(category: category!)),
        child: CategoryProductsScreen(category: category),
      ));
    },
  ),
  GoRoute(
    name: AppRouteConstants.searchScreenRoute.name,
    path: '${AppRouteConstants.searchScreenRoute.path}/:searchQuery',
    pageBuilder: (context, state) {
      final searchQuery = state.pathParameters['searchQuery'];
      return MaterialPage(
          child: BlocProvider.value(
        value: _searchProductBloc..add(SearchEvent(searchQuery: searchQuery!)),
        child: SearchScreen(searchQuery: searchQuery),
      ));
    },
  ),
  GoRoute(
    name: AppRouteConstants.searchOrdersScreenRoute.name,
    path: '${AppRouteConstants.searchOrdersScreenRoute.path}/:orderQuery',
    pageBuilder: (context, state) {
      final orderQuery = state.pathParameters['orderQuery'];
      return MaterialPage(
          child: BlocProvider.value(
        value: FetchOrdersCubit(AccountRepository())
          ..fetchSearchedOrders(orderQuery!),
        child: SearchOrderScreeen(orderQuery: orderQuery),
      ));
    },
  ),
  GoRoute(
      name: AppRouteConstants.menuScreenRoute.name,
      path: AppRouteConstants.menuScreenRoute.path,
      pageBuilder: (context, state) {
        return const MaterialPage(child: MenuScreen());
      })
]);
