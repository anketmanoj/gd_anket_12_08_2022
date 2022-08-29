import 'package:diamon_rose_app/screens/VideoHomeScreen/following_bloc/following_preload_bloc.dart';
import 'package:diamon_rose_app/widgets/VideoWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FollowingVideoPage extends StatefulWidget {
  const FollowingVideoPage();

  @override
  State<FollowingVideoPage> createState() => _FollowingVideoPageState();
}

class _FollowingVideoPageState extends State<FollowingVideoPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FollowingPreloadBloc, FollowingPreloadState>(
      builder: (context, state) {
        return PageView.builder(
          itemCount: state.urls.length,
          scrollDirection: Axis.vertical,
          onPageChanged: (index) =>
              BlocProvider.of<FollowingPreloadBloc>(context, listen: false)
                  .add(FollowingPreloadEvent.onVideoIndexChanged(index)),
          itemBuilder: (context, index) {
            // Is at end and isLoading
            final bool _isLoading =
                state.isLoading && index == state.urls.length - 1;

            return state.focusedIndex == index
                ? VideoWidget(
                    video: state.urls[index],
                    isLoading: _isLoading,
                    controller: state.controllers[index]!,
                  )
                : Container(
                    height: 200,
                    width: 200,
                  );
          },
        );
      },
    );
  }
}