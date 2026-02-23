import 'package:core/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/di.dart';
import '../blocs/post_list/post_list_bloc.dart';

class PostPage extends StatelessWidget {
  const PostPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PostListBloc>(
      create: (context) => getIt<PostListBloc>()..add(PostListFetched()),
      child: const PostView(),
    );
  }
}

class PostView extends StatefulWidget {
  const PostView({super.key});

  @override
  State<PostView> createState() => _PostViewState();
}

class _PostViewState extends State<PostView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<PostListBloc>().add(PostListNextPageFetched());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<PostListBloc, PostListState>(
        listenWhen: (prevState, currentStates) {
          final isTransientFailure =
              prevState.transientFailure == null &&
              currentStates.transientFailure != null;

          return isTransientFailure;
        },
        listener: (context, state) {
          if (state.transientFailure != null) {
            showErrorSnackbar(
              context,
              message: state.transientFailure!.message,
            );
            context.read<PostListBloc>().add(
              PostListTransientFailureConsumed(),
            );
          }
        },
        builder: (context, state) {
          return Center(child: Text('Post Page View'));
        },
      ),
    );
  }
}
