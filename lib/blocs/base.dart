import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class BaseBloc extends DisposableBloc {
  final _errors = PublishSubject<dynamic>();
  final _loading = BehaviorSubject<bool>.seeded(false);

  Stream<dynamic> get errors => _errors.stream;
  ValueStream<bool> get loading => _loading.stream;

  void setError(dynamic value) => _errors.add(value);
  void setLoading(bool value) => _loading.add(value);

  @override
  void dispose() {
    super.dispose();
    _errors.close();
    _loading.close();
  }
}

abstract class DisposableBloc {
  final DisposeBag disposeBag = DisposeBag();

  void dispose() {
    disposeBag.dispose();
  }
}

class DisposeBag {
  final List<StreamSubscription> _subscriptions = [];

  void add(StreamSubscription subscription) {
    _subscriptions.add(subscription);
  }

  void dispose() {
    for (var element in _subscriptions) {
      element.cancel();
    }
  }
}

abstract class DisposableState<T extends StatefulWidget> extends State<T> {
  final disposeBag = DisposeBag();

  @override
  void dispose() {
    disposeBag.dispose();
    super.dispose();
  }
}

extension DisposableStreamSubscription on StreamSubscription {
  StreamSubscription cancelBy(DisposeBag disposeBag) {
    disposeBag.add(this);
    return this;
  }
}
