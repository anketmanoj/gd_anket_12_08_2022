import 'package:diamon_rose_app/screens/youtubeSearchApi/ApiYoutube.dart';
import 'package:diamon_rose_app/screens/youtubeSearchApi/hot_keys.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class SearchFunction extends StatefulWidget {
  final bool liveSearch;
  final Widget body;

  //final String ancestor;
  final FloatingSearchBarController controller;
  final Function(String) onSubmitted;

  const SearchFunction({
    Key? key,
    required this.liveSearch,
    required this.body,
    required this.controller,
    required this.onSubmitted,
    //required this.ancestor,
  }) : super(key: key);

  @override
  _SearchFunctionState createState() => _SearchFunctionState();
}

class _SearchFunctionState extends State<SearchFunction>
    with AutomaticKeepAliveClientMixin<SearchFunction> {
  static const _historyLength = 5;

  final List<String> _searchHistory = [];
  late List<String> filteredSearchHistory;
  String selectedTerm = '';

  List<String> filterSearchTerms({
    required String filter,
  }) {
    if (filter.isNotEmpty) {
      return _searchHistory.reversed
          .where((term) => term.startsWith(filter))
          .toList();
    } else {
      return _searchHistory.reversed.toList();
    }
  }

  void addSearchTerm(String term) {
    if (_searchHistory.contains(term)) {
      putSearchTermFirst(term);
      return;
    }
    _searchHistory.add(term);
    if (_searchHistory.length > _historyLength) {
      _searchHistory.removeRange(0, _searchHistory.length - _historyLength);
    }

    filteredSearchHistory = filterSearchTerms(filter: '');
  }

  void deleteSearchTerm(String term) {
    _searchHistory.removeWhere((t) => t == term);
    filteredSearchHistory = filterSearchTerms(filter: '');
  }

  void putSearchTermFirst(String term) {
    deleteSearchTerm(term);
    addSearchTerm(term);
  }

  late FloatingSearchBarController floatController;

  final ValueNotifier<List> searchSuggestions = ValueNotifier<List>([]);

  @override
  void initState() {
    // selectedTerm = '';
    super.initState();
    filteredSearchHistory = filterSearchTerms(filter: '');
    floatController = FloatingSearchBarController();
  }

  @override
  void dispose() {
    floatController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Material(
      color: Colors.red,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Focus(
          onFocusChange: (hasFocus) {
            hasFocus
                ? HotKeys.instance.disableSpaceHotKey()
                : HotKeys.instance.enableSpaceHotKey();
          },
          child: FloatingSearchBar(
            scrollController: ScrollController(),
            elevation: 3,

            closeOnBackdropTap: true,

            automaticallyImplyBackButton: false,
            shadowColor: Colors.red,

            height: 45,
            axisAlignment: -0.9,

            debounceDelay: const Duration(milliseconds: 500),
            clearQueryOnClose: false,
            // onFocusChanged: ,
            // progress: true,

            // leadingActions: [
            //   Navigator.of(context)
            //   .context
            //   .findAncestorStateOfType<NavigatorState>()
            //   !.canPop()
            //       ?
            //       IconButton(
            //           icon: const Icon(FluentIcons.back),
            //           onPressed: () => Navigator.of(context)
            //               .context
            //               .findAncestorStateOfType<NavigatorState>()
            //               ?.pop()) :const SizedBox()
            // ],

            width: 100.w,
            border: BorderSide(
                color: constantColors.navButton,
                width: 2,
                style: BorderStyle.none),
            borderRadius: BorderRadius.circular(8),
            margins: const EdgeInsets.only(top: 10),

            transitionCurve: Curves.easeInOutCubic,
            transitionDuration: const Duration(milliseconds: 200),
            controller: widget.controller,
            body: widget.body,

            transition: CircularFloatingSearchBarTransition(),
            physics: const BouncingScrollPhysics(),
            title: Text(selectedTerm),
            hint: "Search ...",
            actions: [
              // FloatingSearchBarAction.()

              FloatingSearchBarAction.searchToClear()
            ],
            // onQueryChanged: (query) async {
            //   setState(() {
            //     //for liveSearch//
            //     selectedTerm = query;
            //     widget.onSubmitted(query);

            //     filteredSearchHistory = filterSearchTerms(filter: query);
            //   });
            //   await ApiYouTube()
            //       .searchSuggestions(searchQuery: query)
            //       .then((value) {
            //     searchSuggestions.value = value;
            //   });
            // },
            onSubmitted: (query) async {
              // selectedTerm = query;
              // widget.onSubmitted(query);

              setState(() {
                selectedTerm = query;
                widget.onSubmitted(query);
                addSearchTerm(query);
              });
              //await getPrimarySearchResults(selectedTerm);

              //addSearchTerm(query);

              floatController.close();
            },
            builder: (BuildContext context, Animation<double> transition) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Material(
                  color: Colors.white,
                  elevation: 4,
                  child: Builder(builder: (context) {
                    // if (searchSuggestions.value.isNotEmpty) {
                    //   return

                    //       //   FutureBuilder(
                    //       //   future: ApiYouTube()
                    //       //       .searchSuggestions(searchQuery: selectedTerm)
                    //       //       ,
                    //       //   builder: (context, AsyncSnapshot<List> snapshot) {
                    //       //     if (snapshot.connectionState == ConnectionState.done) {
                    //       //       print('lol');
                    //       //       // If we got an error
                    //       //       if (snapshot.hasError) {
                    //       //         return Center(
                    //       //           child: Text(
                    //       //             '${snapshot.error} occured',
                    //       //             style: TextStyle(fontSize: 18),
                    //       //           ),
                    //       //         );
                    //       //
                    //       //         // if we got our data
                    //       //       } else if (snapshot.hasData) {
                    //       //         // Extracting data from snapshot object
                    //       //        // final data = snapshot.data as String;
                    //       //         return Column(
                    //       //           children:  snapshot.data!.map((e) => InkWell(
                    //       //             onTap: () async {
                    //       //               setState(() {
                    //       //                 widget.controller.query = e;
                    //       //
                    //       //                 putSearchTermFirst(e);
                    //       //                 // selectedTerm = term;
                    //       //               });
                    //       //               floatController.close();
                    //       //             },
                    //       //             child: ListTile(
                    //       //               title: Text(
                    //       //                   e.toString()
                    //       //               ),
                    //       //
                    //       //
                    //       //             ),
                    //       //           )
                    //       //
                    //       //           ).toList(),
                    //       //         );
                    //       //       }
                    //       //     }
                    //       //
                    //       //     // Displaying LoadingSpinner to indicate waiting state
                    //       //     return Center(
                    //       //       child: CircularProgressIndicator(),
                    //       //     );
                    //       //   },
                    //       // );

                    //       Container(
                    //           //height: 50,
                    //           width: double.infinity,
                    //           decoration: BoxDecoration(
                    //               borderRadius: BorderRadius.circular(8)),
                    //           alignment: Alignment.center,
                    //           child: Column(
                    //             mainAxisSize: MainAxisSize.min,
                    //             children: searchSuggestions.value
                    //                 .map((e) => InkWell(
                    //                       onTap: () async {
                    //                         setState(() {
                    //                           widget.controller.query = e;
                    //                           addSearchTerm(
                    //                               floatController.query);

                    //                           putSearchTermFirst(e);
                    //                           // selectedTerm = term;
                    //                         });
                    //                         floatController.hide();
                    //                       },
                    //                       child: ListTile(
                    //                         title: Text(
                    //                           e.toString(),
                    //                         ),
                    //                       ),
                    //                     ))
                    //                 .toList(),
                    //           ));
                    // } else if (filteredSearchHistory.isNotEmpty &&
                    //     floatController.query.isEmpty) {
                    return Container(
                        //height: 50,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8)),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: filteredSearchHistory
                              .map(
                                (term) => ListTile(
                                  title: Text(
                                    term,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  leading: const Icon(Icons.history),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      setState(() {
                                        deleteSearchTerm(term);
                                      });
                                    },
                                  ),
                                  onTap: () async {
                                    setState(() {
                                      widget.controller.query = term;

                                      putSearchTermFirst(term);
                                      // selectedTerm = term;
                                    });
                                    floatController.close();
                                  },
                                ),
                              )
                              .toList(),
                        ));
                    // } else if (filteredSearchHistory.isEmpty) {
                    //   return ListTile(
                    //     title: Text(floatController.query),
                    //     leading: const Icon(Icons.search),
                    //     onTap: () {
                    //       setState(() {
                    //         addSearchTerm(floatController.query);
                    //         selectedTerm = floatController.query;
                    //       });
                    //       floatController.close();
                    //     },
                    //   );
                    // } else {
                    //   return const SizedBox.shrink();
                    // }
                  }),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class SearchResultsListView extends StatelessWidget {
  final String searchTerm;

  const SearchResultsListView({
    Key? key,
    required this.searchTerm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (searchTerm == null) {
      return Material(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.search,
                size: 64,
              ),
              Text(
                'Start searching',
                // style: Theme.of(context).textTheme.headline5,
              )
            ],
          ),
        ),
      );
    }

    return ListView(
      children: List.generate(
        50,
        (index) => ListTile(
          title: Text('$searchTerm search result'),
          subtitle: Text(index.toString()),
        ),
      ),
    );
  }
}
