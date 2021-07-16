import 'package:fluggle_app/common_widgets/empty_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef ItemWidgetBuilder<T> = Widget Function(BuildContext context, T item);

class ListItemsBuilder<T> extends StatelessWidget {
  ListItemsBuilder({
    Key? key,
    required this.data,
    required this.itemBuilder,
    this.physics,
    this.scrollDirection,
  }) : super(key: key);
  final AsyncValue<List<T>> data;
  final ItemWidgetBuilder<T> itemBuilder;
  ScrollPhysics? physics;
  Axis? scrollDirection;

  @override
  Widget build(BuildContext context) {
    return data.when(
      data: (items) => items.isNotEmpty ? _buildList(items) : const EmptyContent(),
      //data: (items) => const Center(child: CircularProgressIndicator()),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => EmptyContent(
        title: 'Something went wrong',
        message: 'Can\'t load items right now: $error, $stackTrace',
      ),
    );
  }

  Widget _buildList(List<T> items) {
    return ListView.separated(
      shrinkWrap: true,
      physics: physics,
      scrollDirection: scrollDirection ?? Axis.vertical,
      itemCount: items.length + 2,
      separatorBuilder: (context, index) => const Divider(height: 0.5),
      itemBuilder: (context, index) {
        if (index == 0 || index == items.length + 1) {
          return Container(); // zero height: not visible
        }
        return itemBuilder(context, items[index - 1]);
      },
    );
  }
}
