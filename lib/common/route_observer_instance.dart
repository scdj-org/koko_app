import 'package:flutter/material.dart';

/// RouteObserver单例
class RouteObserverInstance {
  static RouteObserverInstance? _instance;

  static RouteObserverInstance get instance =>
      _instance ??= RouteObserverInstance._internal();

  RouteObserverInstance._internal() {
    _routeObserver = RouteObserver();
  }

  late final RouteObserver<Route<dynamic>> _routeObserver;

  RouteObserver<Route<dynamic>> get routeObserver => _routeObserver;
}
