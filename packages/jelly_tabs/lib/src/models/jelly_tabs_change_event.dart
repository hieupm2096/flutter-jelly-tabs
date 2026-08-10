import 'package:flutter/foundation.dart';

import 'jelly_tabs_item.dart';

@immutable
class JellyTabsChangeEvent {
  const JellyTabsChangeEvent({required this.index, required this.item});

  final int index;
  final JellyTabsItem item;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JellyTabsChangeEvent &&
          index == other.index &&
          item == other.item;

  @override
  int get hashCode => Object.hash(index, item);
}
