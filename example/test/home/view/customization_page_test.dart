import 'package:example/home/home.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:jelly_tabs/jelly_tabs.dart';

import '../../helpers/helpers.dart';

void main() {
  group(CustomizationPage, () {
    testWidgets('renders a showcase section per customization', (
      tester,
    ) async {
      await tester.pumpApp(const CustomizationPage());

      expect(find.byType(JellyTabBarHeadless), findsNWidgets(6));
    });

    testWidgets('labels each showcase section', (tester) async {
      await tester.pumpApp(const CustomizationPage());

      const titles = [
        'Default',
        'Compact scale',
        'Large scale',
        'Narrow bar',
        'Wide bar',
        'Backdrops',
      ];
      for (final title in titles) {
        expect(find.text(title), findsOneWidget, reason: 'missing $title');
      }
    });

    testWidgets('renders the backdrop showcase with gradient backdrops', (
      tester,
    ) async {
      await tester.pumpApp(const CustomizationPage());

      final backdrop = find.byKey(const Key('backdrop-gradient'));
      final selectedBackdrop = find.byKey(
        const Key('selected-backdrop-gradient'),
      );
      expect(backdrop, findsOneWidget);
      expect(selectedBackdrop, findsOneWidget);
    });
  });
}
