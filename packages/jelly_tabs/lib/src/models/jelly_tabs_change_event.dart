import 'package:flutter/foundation.dart';

import 'package:jelly_tabs/src/models/jelly_tabs_item.dart';

/// Passed to `onTabPress`/`onTabChange`/`onTabLongPress` callbacks, carrying
/// the selected tab's index and item.
@immutable
class JellyTabsChangeEvent {
  /// Creates a [JellyTabsChangeEvent].
  const JellyTabsChangeEvent({required this.index, required this.item});

  /// The tab's index in the items list.
  final int index;

  /// The affected [JellyTabsItem].
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
