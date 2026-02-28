import 'dart:async';
import 'package:domain/post.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

part 'global_event.dart';

@singleton
class GlobalEventBus {
  final StreamController<GlobalEvent> _controller =
      StreamController<GlobalEvent>.broadcast();

  Stream<GlobalEvent> get stream => _controller.stream;

  void add(GlobalEvent event) {
    _controller.add(event);
  }

  @disposeMethod
  void dispose() {
    _controller.close();
  }
}
