import 'package:flutter/widgets.dart';

import 'package:jelly_tabs/src/models/jelly_tabs_icon_props.dart';

/// Builds a tab's icon from its resolved [JellyTabsIconProps].
///
/// Mirrors the reference `TabsIcon` render-function signature.
typedef JellyTabsIconBuilder = Widget Function(JellyTabsIconProps props);
