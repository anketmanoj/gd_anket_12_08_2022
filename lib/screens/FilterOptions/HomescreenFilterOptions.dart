import 'package:diamon_rose_app/screens/VideoHomeScreen/bloc/preload_bloc.dart';
import 'package:diamon_rose_app/services/homeScreenUserEnum.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';

class HomescreenFilterOptions extends StatelessWidget {
  HomescreenFilterOptions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(text: "Posts Filter Option", context: context),
      backgroundColor: constantColors.bioBg,
      body: BlocBuilder<PreloadBloc, PreloadState>(
        builder: (context, state) {
          return state.isLoadingFilter
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: 100.w,
                      child: Text(
                        "Saving your preference!\nPlease Wait!",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.money_off_outlined),
                      title: Text("Only show Free content"),
                      trailing: Switch(
                          activeColor: constantColors.navButton,
                          value: state.filterOption == HomeScreenOptions.Free,
                          onChanged: (value) {
                            BlocProvider.of<PreloadBloc>(context, listen: false)
                                .add(PreloadEvent.setLoadingForFilter(true));
                            if (value) {
                              BlocProvider.of<PreloadBloc>(context,
                                      listen: false)
                                  .add(PreloadEvent.filterBetweenFreePaid(
                                      HomeScreenOptions.Free));
                            } else {
                              BlocProvider.of<PreloadBloc>(context,
                                      listen: false)
                                  .add(PreloadEvent.filterBetweenFreePaid(
                                      HomeScreenOptions.Paid));
                            }

                            BlocProvider.of<PreloadBloc>(context, listen: false)
                                .add(PreloadEvent.setLoadingForFilter(false));
                          }),
                    ),
                    ListTile(
                      leading: Icon(Icons.attach_money),
                      title: Text("Only show Paid content"),
                      trailing: Switch(
                          activeColor: constantColors.navButton,
                          value: state.filterOption == HomeScreenOptions.Paid,
                          onChanged: (value) {
                            BlocProvider.of<PreloadBloc>(context, listen: false)
                                .add(PreloadEvent.setLoadingForFilter(true));
                            if (value) {
                              BlocProvider.of<PreloadBloc>(context,
                                      listen: false)
                                  .add(PreloadEvent.filterBetweenFreePaid(
                                      HomeScreenOptions.Paid));
                            } else {
                              BlocProvider.of<PreloadBloc>(context,
                                      listen: false)
                                  .add(PreloadEvent.filterBetweenFreePaid(
                                      HomeScreenOptions.Free));
                            }

                            BlocProvider.of<PreloadBloc>(context, listen: false)
                                .add(PreloadEvent.setLoadingForFilter(false));
                          }),
                    ),
                    ListTile(
                      leading: Icon(Icons.people_alt),
                      title: Text("Show both (Paid & Free) content"),
                      trailing: Switch(
                          activeColor: constantColors.navButton,
                          value: state.filterOption == HomeScreenOptions.Both,
                          onChanged: (value) {
                            BlocProvider.of<PreloadBloc>(context, listen: false)
                                .add(PreloadEvent.setLoadingForFilter(true));
                            if (value) {
                              BlocProvider.of<PreloadBloc>(context,
                                      listen: false)
                                  .add(PreloadEvent.filterBetweenFreePaid(
                                      HomeScreenOptions.Both));
                            } else {
                              BlocProvider.of<PreloadBloc>(context,
                                      listen: false)
                                  .add(PreloadEvent.filterBetweenFreePaid(
                                      HomeScreenOptions.Free));
                            }
                            BlocProvider.of<PreloadBloc>(context, listen: false)
                                .add(PreloadEvent.setLoadingForFilter(false));
                          }),
                    ),
                  ],
                );
        },
      ),
    );
  }
}
