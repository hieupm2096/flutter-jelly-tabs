import 'package:jelly_tabs/jelly_tabs.dart';

Widget _homeIcon(JellyTabsIconProps props) =>
    Icon(Icons.home, color: props.color, size: props.size);

Widget _starIcon(JellyTabsIconProps props) =>
    Icon(Icons.star, color: props.color, size: props.size);

Widget _mailIcon(JellyTabsIconProps props) =>
    Icon(Icons.mail, color: props.color, size: props.size);

const _items = [
  JellyTabsItem(
    key: 'home',
    label: 'Home',
    activeIcon: _homeIcon,
    inactiveIcon: _homeIcon,
  ),
  JellyTabsItem(
    key: 'star',
    label: 'Star',
    activeIcon: _starIcon,
    inactiveIcon: _starIcon,
  ),
  JellyTabsItem(
    key: 'mail',
    label: 'Mail',
    activeIcon: _mailIcon,
    inactiveIcon: _mailIcon,
  ),
];

class CustomizationPage extends StatelessWidget {
  const CustomizationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customization')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            _Showcase(
              title: 'Default',
              bar: JellyTabBarHeadless(items: _items),
            ),
            _Showcase(
              title: 'Compact scale',
              bar: JellyTabBarHeadless(items: _items, displayScale: 0.75),
            ),
            _Showcase(
              title: 'Large scale',
              bar: JellyTabBarHeadless(items: _items, displayScale: 1.25),
            ),
            _Showcase(
              title: 'Narrow bar',
              bar: JellyTabBarHeadless(items: _items, maxWidth: 240),
            ),
            _Showcase(
              title: 'Wide bar',
              bar: JellyTabBarHeadless(items: _items, maxWidth: 560),
            ),
            _Showcase(
              title: 'Backdrops',
              bar: JellyTabBarHeadless(
                items: _items,
                backdrop: DecoratedBox(
                  key: Key('backdrop-gradient'),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF4C1D95), Color(0xFF1C1917)],
                    ),
                  ),
                ),
                selectedBackdrop: DecoratedBox(
                  key: Key('selected-backdrop-gradient'),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFF59E0B), Color(0xFFFFF7ED)],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Showcase extends StatelessWidget {
  const _Showcase({required this.title, required this.bar});

  final String title;
  final Widget bar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: bar,
          ),
        ],
      ),
    );
  }
}
