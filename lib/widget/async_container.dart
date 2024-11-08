import 'package:flutter/material.dart';

class AsyncPageContainer extends StatelessWidget {
  const AsyncPageContainer({
    super.key,
    required this.libFuture,
    required this.builder,
    this.onInitState,
    this.onDispose,
  });

  final Future libFuture;
  final WidgetBuilder builder;
  final VoidCallback? onInitState;
  final VoidCallback? onDispose;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: libFuture,
      builder: (context, snapshot) => switch (snapshot.connectionState) {
        ConnectionState.none => const SizedBox.shrink(),
        ConnectionState.waiting || ConnectionState.active => const Center(
            child: CircularProgressIndicator(),
          ),
        ConnectionState.done => builder(context),
      },
    );
  }
}
