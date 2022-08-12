import 'package:diamon_rose_app/constants/styles/colors.dart';
import 'package:flutter/material.dart';

class SingleSelectionList extends StatefulWidget {
  SingleSelectionList({
    Key? key,
    required this.title,
    required this.options,
    required this.selectedIndex,
    required this.onSelect,
  }) : super(key: key);

  final String title;
  final List<String> options;
  final int selectedIndex;
  final Function(int index) onSelect;

  @override
  _SingleSelectionListState createState() => _SingleSelectionListState();
}

class _SingleSelectionListState extends State<SingleSelectionList> {
  late int selectedIndex = widget.selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        children: [buildTitle(context), buildOptionList(context)]);
  }

  Widget buildTitle(BuildContext context) {
    final title = widget.title;
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsetsDirectional.only(bottom: 16),
      decoration: BoxDecoration(
          border:
              Border(bottom: BorderSide(color: AppColors.black, width: 0.5))),
      child: Text(
        title,
      ),
    );
  }

  Widget buildOptionList(BuildContext context) {
    final options = widget.options;
    return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: options.length,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: AppColors.black, width: 0.5))),
            child: ListTile(
              selected: selectedIndex == index,
              trailing: selectedIndex == index
                  ? Icon(Icons.check, color: AppColors.tick)
                  : null,
              title: Text(options[index]),
              onTap: () {
                setState(() {
                  selectedIndex = index;
                });

                widget.onSelect(index);
              },
            ),
          );
        });
  }
}
