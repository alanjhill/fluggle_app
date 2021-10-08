import 'package:fluggle_app/widgets/empty_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef ItemWidgetBuilder<T> = Widget Function(BuildContext context, T item);

class ListItemsBuilder<T> extends StatelessWidget {
  const ListItemsBuilder({
    Key? key,
    required this.data,
    required this.itemBuilder,
    this.separator,
    this.physics,
    this.scrollDirection,
    this.padding,
  }) : super(key: key);
  final AsyncValue<List<T>> data;
  final ItemWidgetBuilder<T> itemBuilder;
  final Widget? separator;
  final ScrollPhysics? physics;
  final Axis? scrollDirection;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return data.when(
      data: (items) => items.isNotEmpty ? _buildList(items) : const EmptyContent(),
      loading: (_) => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace, previousValue) => EmptyContent(
        title: 'Something went wrong',
        message: 'Can\'t load items right now: $error, $stackTrace',
      ),
    );
  }

  Widget _buildList(List<T> items) {
    return ListView.separated(
      padding: padding,
      shrinkWrap: true,
      physics: physics,
      scrollDirection: scrollDirection ?? Axis.vertical,
      itemCount: items.length + 2,
      separatorBuilder: (context, index) {
        if (separator != null) {
          return separator!;
        } else {
          return const Divider(height: 8.0, thickness: 0.0, color: Colors.transparent);
        }
      },
      itemBuilder: (context, index) {
        if (index == 0 || index == items.length + 1) {
          return Container(height: 0); // zero height: not visible
        }
        return itemBuilder(context, items[index - 1]);
      },
    );
  }
}
