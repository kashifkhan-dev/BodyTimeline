Native iOS 26+ Liquid Glass widgets for Flutter with pixel-perfect fidelity. This package renders authentic Apple UI components using native platform views, providing the genuine iOS/macOS look and feel that Flutter's built-in widgets cannot achieve.

Preview
Quick Start

No initialization required! Just import and use:

import 'package:cupertino_native_better/cupertino_native_better.dart';

void main() {
  runApp(MyApp());
}

    Note: PlatformVersion auto-initializes on first access. No need to call initialize() anymore!

Performance Best Practices
⚠️ LiquidGlassContainer & Lists

LiquidGlassContainer uses a Platform View (UiKitView / AppKitView) under the hood. While powerful, platform views are more expensive than standard Flutter widgets.

    DO NOT use LiquidGlassContainer inside long scrolling lists (ListView.builder, GridView) with many items. This will cause significant performance drops (jank).
    DO use LiquidGlassContainer for static elements like Cards, Headers, Navigation Bars, or Floating Action Buttons.

Why cupertino_native_better?
Comparison with Other Packages
Feature 	cupertino_native_better 	cupertino_native_plus 	cupertino_native
iOS 26+ Liquid Glass 	Yes 	Yes 	No
Release Build Version Detection 	Fixed 	Broken 	N/A
SF Symbol Fallback (iOS < 26) 	CNIcon renders natively 	Placeholder icons 	N/A
Button Label + Icon Fallback 	Both render correctly 	Label disappears 	N/A
Tab Bar Icon Fallback 	CNIcon renders natively 	Empty circles 	N/A
Image Asset Support (PNG/SVG) 	Full support 	Partial 	No
Automatic Asset Resolution 	Yes (1x-4x) 	No 	No
Dark Mode Sync 	Automatic 	Manual 	Manual
Glass Effect Unioning 	Yes 	Yes 	No
macOS Support 	Yes 	Yes 	Yes
The Problem with Other Packages

cupertino_native_plus has a critical bug: it uses platform channels to detect iOS versions, which fails with "Null check operator used on a null value" in release builds. This causes:

    shouldUseNativeGlass returns false even on iOS 26+
    Falls back to old Cupertino widgets incorrectly
    Icons show as "..." or empty circles on iOS 18
    Button labels disappear when buttons have both icon and label

Our Solution

cupertino_native_better fixes all these issues:

// We parse Platform.operatingSystemVersion directly
// Example: "Version 26.1 (Build 23B82)" -> 26
static int? _getIOSVersionManually() {
  final versionString = Platform.operatingSystemVersion;
  final match = RegExp(r'Version (\d+)\.').firstMatch(versionString);
  return int.tryParse(match?.group(1) ?? '');
}

This approach works reliably in both debug and release builds.
Features
Widgets
Widget 	Description 	Controller
CNButton 	Native push button with Liquid Glass effects, SF Symbols, and image assets 	-
CNButton.icon 	Circular icon-only button variant 	-
CNIcon 	Platform-rendered SF Symbols, custom IconData, or image assets 	-
CNTabBar 	Native tab bar with split mode for scroll-aware layouts 	-
CNSlider 	Native slider with min/max range and step support 	CNSliderController
CNSwitch 	Native toggle switch with animated state changes 	CNSwitchController
CNPopupMenuButton 	Native popup menu with dividers, icons, and image assets 	-
CNPopupMenuButton.icon 	Circular icon-only popup menu variant 	-
CNSegmentedControl 	Native segmented control with SF Symbols support 	-
CNGlassButtonGroup 	Grouped buttons with unified glass blending (tint color support) 	-
LiquidGlassContainer 	Apply Liquid Glass effects to any Flutter widget 	-
CNGlassCard 	(Experimental) Pre-styled card with optional breathing glow animation 	-
CNTabBarNative 	iOS 26 Native Tab Bar with UITabBarController + search 	-
CNToast 	Toast notifications with Liquid Glass effects 	-
Icon Support

All widgets support three icon types with unified priority:

    Image Assets (highest priority) - PNG, SVG, JPG with automatic resolution selection
    Custom Icons - Any IconData (CupertinoIcons, Icons, custom)
    SF Symbols - Native Apple SF Symbols with rendering modes

// SF Symbol
CNButton(
  label: 'Settings',
  icon: CNSymbol('gear', size: 20),
  onPressed: () {},
)

// Custom Icon
CNButton(
  label: 'Home',
  customIcon: CupertinoIcons.home,
  onPressed: () {},
)

// Image Asset
CNButton(
  label: 'Custom',
  imageAsset: CNImageAsset('assets/icons/custom.png', size: 20),
  onPressed: () {},
)

Button Styles

CNButtonStyle.plain           // Minimal, text-only
CNButtonStyle.gray            // Subtle gray background
CNButtonStyle.tinted          // Tinted text
CNButtonStyle.bordered        // Bordered outline
CNButtonStyle.borderedProminent // Accent-colored border
CNButtonStyle.filled          // Solid filled background
CNButtonStyle.glass           // Liquid Glass effect (iOS 26+)
CNButtonStyle.prominentGlass  // Prominent glass effect (iOS 26+)

Glass Effect Unioning

Multiple buttons can share a unified glass effect:

Row(
  children: [
    CNButton(
      label: 'Left',
      config: CNButtonConfig(
        style: CNButtonStyle.glass,
        glassEffectUnionId: 'toolbar',
      ),
      onPressed: () {},
    ),
    CNButton(
      label: 'Right',
      config: CNButtonConfig(
        style: CNButtonStyle.glass,
        glassEffectUnionId: 'toolbar',
      ),
      onPressed: () {},
    ),
  ],
)

Tab Bar with Split Mode

Tab Bar Preview

CNTabBar(
  items: [
    CNTabBarItem(
      label: 'Home',
      icon: CNSymbol('house'),
      activeIcon: CNSymbol('house.fill'),
    ),
    CNTabBarItem(
      label: 'Profile',
      icon: CNSymbol('person.crop.circle'),
      activeIcon: CNSymbol('person.crop.circle.fill'),
    ),
  ],
  currentIndex: _selectedIndex,
  onTap: (index) => setState(() => _selectedIndex = index),
  iconSize: 25, // Optional: customize icon size (default ~25pt)
  split: true, // Separates tabs when scrolling
  rightCount: 1, // Number of tabs pinned to the right
)

Native iOS 26 Tab Bar (CNTabBarNative)

For full iOS 26 liquid glass tab bar experience with native UITabBarController:

@override
void initState() {
  super.initState();
  CNTabBarNative.enable(
    tabs: [
      CNTab(title: 'Home', sfSymbol: CNSymbol('house.fill')),
      CNTab(title: 'Search', sfSymbol: CNSymbol('magnifyingglass'), isSearchTab: true),
      CNTab(title: 'Profile', sfSymbol: CNSymbol('person.fill')),
    ],
    onTabSelected: (index) => setState(() => _selectedTab = index),
    onSearchChanged: (query) => filterResults(query),
  );
}

@override
void dispose() {
  CNTabBarNative.disable();
  super.dispose();
}

Tab Bar with iOS 26 Search Tab

The CNTabBar supports iOS 26's native search tab feature with animated expansion:

CNTabBar(
  items: [
    CNTabBarItem(
      label: 'Overview',
      icon: CNSymbol('square.grid.2x2.fill'),
    ),
    CNTabBarItem(
      label: 'Projects',
      icon: CNSymbol('folder'),
      activeIcon: CNSymbol('folder.fill'),
    ),
  ],
  currentIndex: _index,
  onTap: (i) => setState(() => _index = i),
  // iOS 26 Search Tab Feature
  searchItem: CNTabBarSearchItem(
    placeholder: 'Find customer',
    // Control keyboard auto-activation
    automaticallyActivatesSearch: false, // Keyboard only opens on text field tap
    onSearchChanged: (query) {
      // Live filtering as user types
    },
    onSearchSubmit: (query) {
      // Handle search submission
    },
    onSearchActiveChanged: (isActive) {
      // React to search expand/collapse
    },
    style: const CNTabBarSearchStyle(
      iconSize: 20,
      buttonSize: 44,
      searchBarHeight: 44,
      animationDuration: Duration(milliseconds: 400),
      showClearButton: true,
    ),
  ),
  searchController: _searchController, // Optional programmatic control
)

automaticallyActivatesSearch

Controls whether the keyboard opens automatically when the search tab expands:

    true (default): Tapping the search button expands the bar AND opens the keyboard
    false: Tapping the search button only expands the bar; keyboard opens when user taps the text field

This mirrors UISearchTab.automaticallyActivatesSearch from UIKit.
Installation

Add to your pubspec.yaml:

dependencies:
  cupertino_native_better: ^1.3.1

Usage
Basic Button

Button Preview

CNButton(
  label: 'Get Started',
  icon: CNSymbol('arrow.right', size: 18),
  config: CNButtonConfig(
    style: CNButtonStyle.filled,
    imagePlacement: CNImagePlacement.trailing,
  ),
  onPressed: () {
    // Handle tap
  },
)

Button Styles Gallery

Glass Button Styles Filled Button Styles

More Button Styles
Icon-Only Button

Icon Button Preview

CNButton.icon(
  icon: CNSymbol('plus', size: 24),
  config: CNButtonConfig(style: CNButtonStyle.glass),
  onPressed: () {},
)

Native Icons

Icon Preview

CNIcon(
  symbol: CNSymbol(
    'star.fill',
    size: 32,
    color: Colors.amber,
    mode: CNSymbolRenderingMode.multicolor,
  ),
)

Slider with Controller

Slider Preview

final controller = CNSliderController();

CNSlider(
  value: 0.5,
  min: 0,
  max: 1,
  controller: controller,
  onChanged: (value) {
    print('Value: $value');
  },
)

// Programmatic update
controller.setValue(0.75);

Switch with Controller

Switch Preview

final controller = CNSwitchController();

CNSwitch(
  value: _isEnabled,
  onChanged: (value) {
    setState(() => _isEnabled = value);
  },
  controller: controller,
  color: Colors.green, // Optional tint color
)

// Programmatic control
controller.setValue(true, animated: true);
controller.setEnabled(false); // Disable interaction

Popup Menu Button

Popup Menu Button Popup Menu Opened

// Text-labeled popup menu
CNPopupMenuButton(
  buttonLabel: 'Options',
  buttonStyle: CNButtonStyle.glass,
  items: [
    CNPopupMenuItem(
      label: 'Edit',
      icon: CNSymbol('pencil'),
    ),
    CNPopupMenuItem(
      label: 'Share',
      icon: CNSymbol('square.and.arrow.up'),
    ),
    const CNPopupMenuDivider(), // Visual separator
    CNPopupMenuItem(
      label: 'Delete',
      icon: CNSymbol('trash', color: Colors.red),
      enabled: true,
    ),
  ],
  onSelected: (index) {
    print('Selected item at index: $index');
  },
)

// Icon-only popup menu (circular glass button)
CNPopupMenuButton.icon(
  buttonIcon: CNSymbol('ellipsis.circle', size: 24),
  buttonStyle: CNButtonStyle.glass,
  items: [
    CNPopupMenuItem(label: 'Option 1', icon: CNSymbol('star')),
    CNPopupMenuItem(label: 'Option 2', icon: CNSymbol('heart')),
  ],
  onSelected: (index) {},
)

Segmented Control

Segmented Control Preview

// Text-only segments
CNSegmentedControl(
  labels: ['Day', 'Week', 'Month', 'Year'],
  selectedIndex: _selectedIndex,
  onValueChanged: (index) {
    setState(() => _selectedIndex = index);
  },
  color: Colors.blue, // Optional tint color
)

// Segments with SF Symbols
CNSegmentedControl(
  labels: ['List', 'Grid', 'Gallery'],
  sfSymbols: [
    CNSymbol('list.bullet'),
    CNSymbol('square.grid.2x2'),
    CNSymbol('photo.on.rectangle'),
  ],
  selectedIndex: _viewMode,
  onValueChanged: (index) {
    setState(() => _viewMode = index);
  },
  shrinkWrap: true, // Size to content
)

Liquid Glass Container

LiquidGlassContainer(
  config: LiquidGlassConfig(
    effect: CNGlassEffect.regular,
    shape: CNGlassEffectShape.rect,
    cornerRadius: 16,
    interactive: true,
  ),
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Text('Glass Effect'),
  ),
)

// Or use the extension
Text('Glass Effect')
  .liquidGlass(cornerRadius: 16)

Experimental: Glass Card

CNGlassCard(
  child: Text("Hello"),
  breathing: true, // Optional subtle glow animation
)

Platform Fallbacks
Platform 	Liquid Glass 	SF Symbols 	Other Widgets
iOS 26+ 	Native 	Native 	Native
iOS 13-25 	CupertinoButton 	Native via CNIcon 	CupertinoWidgets
macOS 26+ 	Native 	Native 	Native
macOS 11-25 	CupertinoButton 	Native via CNIcon 	CupertinoWidgets
Android/Web/etc 	Material fallback 	Flutter Icon 	Material fallback
Version Detection

Check platform capabilities:

// Check if Liquid Glass is available
if (PlatformVersion.shouldUseNativeGlass) {
  // iOS 26+ or macOS 26+
}

// Check if SF Symbols are available (iOS 13+, macOS 11+)
if (PlatformVersion.supportsSFSymbols) {
  // Use CNIcon for native rendering
}

// Get specific version
print('iOS version: ${PlatformVersion.iosVersion}');
print('macOS version: ${PlatformVersion.macOSVersion}');

Requirements

    Flutter: >= 3.3.0
    Dart SDK: >= 3.9.0
    iOS: >= 15.0 (Liquid Glass requires iOS 26+)
    macOS: >= 11.0 (Liquid Glass requires macOS 26+)

Migration from cupertino_native_plus

    Update your pubspec.yaml:

    # Before
    cupertino_native_plus: ^x.x.x

    # After
    cupertino_native_better: ^1.3.1

    Update imports:

    // Before
    import 'package:cupertino_native_plus/cupertino_native_plus.dart';

    // After
    import 'package:cupertino_native_better/cupertino_native_better.dart';

    No other code changes needed - API is fully compatible!



import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cupertino_native_better/cupertino_native_better.dart';
import 'dart:ui';

void main() {
  runApp(const CupertinoNativeBetterShowcase());
}

class CupertinoNativeBetterShowcase extends StatelessWidget {
  const CupertinoNativeBetterShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cupertino Native Better Showcase',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xFF000000),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark),
      ),
      home: const ShowcaseHome(),
    );
  }
}

class ShowcaseHome extends StatefulWidget {
  const ShowcaseHome({super.key});

  @override
  State<ShowcaseHome> createState() => _ShowcaseHomeState();
}

class _ShowcaseHomeState extends State<ShowcaseHome> {
  int _tabIndex = 0;

  final List<Widget> _pages = const [ButtonsPage(), ControlsPage(), ContainersPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(-0.7, -0.8),
                  radius: 1.8,
                  colors: [Color(0xFF1E3A8A), Color(0xFF0F172A), Color(0xFF000000)],
                ),
              ),
            ),
          ),

          // Ambient Glow
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [Colors.blue.withOpacity(0.2), Colors.transparent]),
              ),
            ),
          ),

          // Content
          SafeArea(child: _pages[_tabIndex]),

          // Native Tab Bar
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
              child: CNTabBar(
                items: const [
                  CNTabBarItem(
                    label: 'Buttons',
                    icon: CNSymbol('square.grid.2x2'),
                    activeIcon: CNSymbol('square.grid.2x2.fill'),
                  ),
                  CNTabBarItem(
                    label: 'Controls',
                    icon: CNSymbol('slider.horizontal.3'),
                    activeIcon: CNSymbol('slider.horizontal.3'),
                  ),
                  CNTabBarItem(
                    label: 'Containers',
                    icon: CNSymbol('square.stack.3d.up'),
                    activeIcon: CNSymbol('square.stack.3d.up.fill'),
                  ),
                ],
                currentIndex: _tabIndex,
                onTap: (index) => setState(() => _tabIndex = index),
                iconSize: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// BUTTONS PAGE - All Button Styles & Variations
// ============================================================================

class ButtonsPage extends StatefulWidget {
  const ButtonsPage({super.key});

  @override
  State<ButtonsPage> createState() => _ButtonsPageState();
}

class _ButtonsPageState extends State<ButtonsPage> {
  String _lastAction = 'Tap any button';

  void _handlePress(String action) {
    setState(() => _lastAction = action);
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Buttons',
                  style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: -2, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 4,
                  width: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Colors.blue, Colors.purple]),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                Text('Last action: $_lastAction', style: const TextStyle(fontSize: 14, color: Colors.white60)),
              ],
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 24),

              // Button Styles Gallery
              _buildSection('All Button Styles', 'CNButtonStyle variations'),
              _buildGlassContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CNButton(
                      label: 'Plain Style',
                      config: CNButtonConfig(style: CNButtonStyle.plain),
                      onPressed: () => _handlePress('Plain button'),
                    ),
                    const SizedBox(height: 12),
                    CNButton(
                      label: 'Gray Style',
                      config: CNButtonConfig(style: CNButtonStyle.gray),
                      onPressed: () => _handlePress('Gray button'),
                    ),
                    const SizedBox(height: 12),
                    CNButton(
                      label: 'Tinted Style',
                      config: CNButtonConfig(style: CNButtonStyle.tinted),
                      onPressed: () => _handlePress('Tinted button'),
                    ),
                    const SizedBox(height: 12),
                    CNButton(
                      label: 'Bordered Style',
                      config: CNButtonConfig(style: CNButtonStyle.bordered),
                      onPressed: () => _handlePress('Bordered button'),
                    ),
                    const SizedBox(height: 12),
                    CNButton(
                      label: 'Bordered Prominent',
                      config: CNButtonConfig(style: CNButtonStyle.borderedProminent),
                      onPressed: () => _handlePress('Bordered Prominent'),
                    ),
                    const SizedBox(height: 12),
                    CNButton(
                      label: 'Filled Style',
                      config: CNButtonConfig(style: CNButtonStyle.filled),
                      onPressed: () => _handlePress('Filled button'),
                    ),
                    const SizedBox(height: 12),
                    CNButton(
                      label: 'Glass Style (iOS 26+)',
                      config: CNButtonConfig(style: CNButtonStyle.glass),
                      onPressed: () => _handlePress('Glass button'),
                    ),
                    const SizedBox(height: 12),
                    CNButton(
                      label: 'Prominent Glass (iOS 26+)',
                      config: CNButtonConfig(style: CNButtonStyle.prominentGlass),
                      onPressed: () => _handlePress('Prominent Glass'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Buttons with Icons
              _buildSection('Buttons with Icons', 'SF Symbols & Custom Icons'),
              _buildGlassContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CNButton(
                      label: 'Get Started',
                      icon: CNSymbol('arrow.right', size: 18),
                      config: CNButtonConfig(style: CNButtonStyle.filled, imagePlacement: CNImagePlacement.trailing),
                      onPressed: () => _handlePress('Get Started'),
                    ),
                    const SizedBox(height: 12),
                    CNButton(
                      label: 'Download',
                      icon: CNSymbol('arrow.down.circle.fill', size: 20),
                      config: CNButtonConfig(
                        style: CNButtonStyle.borderedProminent,
                        imagePlacement: CNImagePlacement.leading,
                      ),
                      onPressed: () => _handlePress('Download'),
                    ),
                    const SizedBox(height: 12),
                    CNButton(
                      label: 'Share',
                      customIcon: CupertinoIcons.share,
                      config: CNButtonConfig(style: CNButtonStyle.tinted, imagePlacement: CNImagePlacement.leading),
                      onPressed: () => _handlePress('Share'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Icon-Only Buttons
              _buildSection('Icon-Only Buttons', 'CNButton.icon variations'),
              _buildGlassContainer(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    CNButton.icon(
                      icon: CNSymbol('plus', size: 24),
                      config: CNButtonConfig(style: CNButtonStyle.glass),
                      onPressed: () => _handlePress('Add'),
                    ),
                    CNButton.icon(
                      icon: CNSymbol('heart.fill', size: 24),
                      config: CNButtonConfig(style: CNButtonStyle.filled),
                      onPressed: () => _handlePress('Like'),
                    ),
                    CNButton.icon(
                      icon: CNSymbol('star.fill', size: 24),
                      config: CNButtonConfig(style: CNButtonStyle.borderedProminent),
                      onPressed: () => _handlePress('Favorite'),
                    ),
                    CNButton.icon(
                      icon: CNSymbol('trash', size: 24),
                      config: CNButtonConfig(style: CNButtonStyle.bordered),
                      onPressed: () => _handlePress('Delete'),
                    ),
                    CNButton.icon(
                      icon: CNSymbol('gear', size: 24),
                      config: CNButtonConfig(style: CNButtonStyle.gray),
                      onPressed: () => _handlePress('Settings'),
                    ),
                    CNButton.icon(
                      icon: CNSymbol('ellipsis.circle', size: 24),
                      config: CNButtonConfig(style: CNButtonStyle.tinted),
                      onPressed: () => _handlePress('More'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Glass Effect Unioning
              _buildSection('Glass Effect Unioning', 'Unified glass effect across buttons'),
              _buildGlassContainer(
                child: Row(
                  children: [
                    Expanded(
                      child: CNButton(
                        label: 'Left',
                        config: CNButtonConfig(style: CNButtonStyle.glass, glassEffectUnionId: 'toolbar'),
                        onPressed: () => _handlePress('Left'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CNButton(
                        label: 'Center',
                        config: CNButtonConfig(style: CNButtonStyle.glass, glassEffectUnionId: 'toolbar'),
                        onPressed: () => _handlePress('Center'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CNButton(
                        label: 'Right',
                        config: CNButtonConfig(style: CNButtonStyle.glass, glassEffectUnionId: 'toolbar'),
                        onPressed: () => _handlePress('Right'),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Popup Menu Buttons
              _buildSection('Popup Menu Buttons', 'CNPopupMenuButton variations'),
              _buildGlassContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CNPopupMenuButton(
                      buttonLabel: 'Options Menu',
                      buttonStyle: CNButtonStyle.glass,
                      items: [
                        CNPopupMenuItem(label: 'Edit', icon: CNSymbol('pencil')),
                        CNPopupMenuItem(label: 'Share', icon: CNSymbol('square.and.arrow.up')),
                        const CNPopupMenuDivider(),
                        CNPopupMenuItem(
                          label: 'Delete',
                          icon: CNSymbol('trash', color: Colors.red),
                        ),
                      ],
                      onSelected: (index) => _handlePress('Menu item $index'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CNPopupMenuButton.icon(
                          buttonIcon: CNSymbol('ellipsis.circle', size: 24),
                          buttonStyle: CNButtonStyle.glass,
                          items: [
                            CNPopupMenuItem(label: 'Copy', icon: CNSymbol('doc.on.doc')),
                            CNPopupMenuItem(label: 'Paste', icon: CNSymbol('doc.on.clipboard')),
                          ],
                          onSelected: (index) => _handlePress('Icon menu $index'),
                        ),
                        CNPopupMenuButton.icon(
                          buttonIcon: CNSymbol('star.circle', size: 24),
                          buttonStyle: CNButtonStyle.filled,
                          items: [
                            CNPopupMenuItem(label: 'Rate 5 Stars', icon: CNSymbol('star.fill')),
                            CNPopupMenuItem(label: 'Rate 4 Stars', icon: CNSymbol('star')),
                          ],
                          onSelected: (index) => _handlePress('Rating $index'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Native Icons
              _buildSection('Native Icons', 'CNIcon with SF Symbols'),
              _buildGlassContainer(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    CNIcon(symbol: CNSymbol('star.fill', size: 32, color: Colors.amber)),
                    CNIcon(symbol: CNSymbol('paintpalette.fill', size: 32, mode: CNSymbolRenderingMode.multicolor)),
                    CNIcon(symbol: CNSymbol('bolt.shield.fill', size: 32, mode: CNSymbolRenderingMode.hierarchical)),
                    CNIcon(symbol: CNSymbol('waveform.path.ecg', size: 32)),
                  ],
                ),
              ),

              const SizedBox(height: 140),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.blue, letterSpacing: 1.5),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.white30)),
        ],
      ),
    );
  }

  Widget _buildGlassContainer({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ============================================================================
// CONTROLS PAGE - Sliders, Switches, Segmented Controls
// ============================================================================

class ControlsPage extends StatefulWidget {
  const ControlsPage({super.key});

  @override
  State<ControlsPage> createState() => _ControlsPageState();
}

class _ControlsPageState extends State<ControlsPage> {
  double _sliderValue = 50;
  double _volumeValue = 75;
  double _brightnessValue = 30;

  bool _switchValue = true;
  bool _notificationsEnabled = false;
  bool _darkModeEnabled = true;

  int _segmentedIndex = 0;
  int _viewModeIndex = 1;

  final _sliderController = CNSliderController();
  final _switchController = CNSwitchController();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Controls',
                  style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: -2, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 4,
                  width: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Colors.purple, Colors.pink]),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Interactive native controls', style: TextStyle(fontSize: 14, color: Colors.white60)),
              ],
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 24),

              // Sliders
              _buildSection('Sliders', 'CNSlider with native iOS appearance'),
              _buildGlassContainer(
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(CupertinoIcons.volume_down, size: 20, color: Colors.white70),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CNSlider(
                            value: _sliderValue,
                            min: 0,
                            max: 100,
                            onChanged: (v) => setState(() => _sliderValue = v),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(CupertinoIcons.volume_up, size: 20, color: Colors.white70),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'VALUE: ${_sliderValue.toInt()}%',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const Divider(height: 32, color: Colors.white10),

                    // Volume Slider
                    Row(
                      children: [
                        const Icon(CupertinoIcons.speaker_1, size: 20, color: Colors.white70),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CNSlider(
                            value: _volumeValue,
                            min: 0,
                            max: 100,
                            controller: _sliderController,
                            onChanged: (v) => setState(() => _volumeValue = v),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(CupertinoIcons.speaker_3, size: 20, color: Colors.white70),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'VOLUME: ${_volumeValue.toInt()}%',
                      style: const TextStyle(
                        color: Colors.purple,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const Divider(height: 32, color: Colors.white10),

                    // Brightness Slider
                    Row(
                      children: [
                        const Icon(CupertinoIcons.brightness_solid, size: 20, color: Colors.white70),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CNSlider(
                            value: _brightnessValue,
                            min: 0,
                            max: 100,
                            onChanged: (v) => setState(() => _brightnessValue = v),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(CupertinoIcons.sun_max, size: 20, color: Colors.white70),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'BRIGHTNESS: ${_brightnessValue.toInt()}%',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Switches
              _buildSection('Switches', 'CNSwitch with native iOS appearance'),
              _buildGlassContainer(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Haptic Feedback',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                        CNSwitch(value: _switchValue, onChanged: (v) => setState(() => _switchValue = v)),
                      ],
                    ),
                    const Divider(height: 32, color: Colors.white10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Notifications',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                        CNSwitch(
                          value: _notificationsEnabled,
                          onChanged: (v) => setState(() => _notificationsEnabled = v),
                          color: Colors.purple,
                        ),
                      ],
                    ),
                    const Divider(height: 32, color: Colors.white10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Dark Mode',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                        CNSwitch(
                          value: _darkModeEnabled,
                          onChanged: (v) => setState(() => _darkModeEnabled = v),
                          controller: _switchController,
                          color: Colors.orange,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Segmented Controls
              _buildSection('Segmented Controls', 'CNSegmentedControl variations'),
              _buildGlassContainer(
                child: Column(
                  children: [
                    CNSegmentedControl(
                      labels: const ['Day', 'Week', 'Month', 'Year'],
                      selectedIndex: _segmentedIndex,
                      onValueChanged: (i) => setState(() => _segmentedIndex = i),
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 24),
                    CNSegmentedControl(
                      labels: const ['List', 'Grid', 'Gallery'],
                      sfSymbols: const [
                        CNSymbol('list.bullet'),
                        CNSymbol('square.grid.2x2'),
                        CNSymbol('photo.on.rectangle'),
                      ],
                      selectedIndex: _viewModeIndex,
                      onValueChanged: (i) => setState(() => _viewModeIndex = i),
                      shrinkWrap: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 140),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.purple, letterSpacing: 1.5),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.white30)),
        ],
      ),
    );
  }

  Widget _buildGlassContainer({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ============================================================================
// CONTAINERS PAGE - Glass Containers & Cards
// ============================================================================

class ContainersPage extends StatefulWidget {
  const ContainersPage({super.key});

  @override
  State<ContainersPage> createState() => _ContainersPageState();
}

class _ContainersPageState extends State<ContainersPage> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Containers',
                  style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: -2, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 4,
                  width: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Colors.cyan, Colors.green]),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Liquid glass effects & containers', style: TextStyle(fontSize: 14, color: Colors.white60)),
              ],
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 24),

              // Liquid Glass Container
              _buildSection('Liquid Glass Container', 'LiquidGlassContainer with native iOS 26+ effect'),
              LiquidGlassContainer(
                config: LiquidGlassConfig(
                  effect: CNGlassEffect.regular,
                  shape: CNGlassEffectShape.rect,
                  cornerRadius: 20,
                  interactive: true,
                ),
                child: const Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(CupertinoIcons.sparkles, color: Colors.blue, size: 28),
                          SizedBox(width: 12),
                          Text(
                            'Regular Glass Effect',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                        'This container uses the native iOS 26+ liquid glass effect with interactive blur. On older iOS versions, it gracefully falls back to a compatible appearance.',
                        style: TextStyle(fontSize: 14, color: Colors.white70, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Prominent Glass Container
              _buildSection('Prominent Glass Effect', 'More pronounced glass effect'),
              LiquidGlassContainer(
                config: LiquidGlassConfig(
                  effect: CNGlassEffect.prominent,
                  shape: CNGlassEffectShape.rect,
                  cornerRadius: 20,
                  interactive: true,
                ),
                child: const Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(CupertinoIcons.star_fill, color: Colors.amber, size: 28),
                          SizedBox(width: 12),
                          Text(
                            'Prominent Glass Effect',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                        'A more pronounced glass effect that stands out more prominently against the background. Perfect for hero sections and important content.',
                        style: TextStyle(fontSize: 14, color: Colors.white70, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Extension Method
              _buildSection('Extension Method', 'Using .liquidGlass() extension'),
              const Text(
                'Premium Features',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ).liquidGlass(cornerRadius: 20),

              const SizedBox(height: 32),

              // Glass Cards
              _buildSection('Glass Cards (Experimental)', 'CNGlassCard with breathing animation'),
              CNGlassCard(
                breathing: true,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [Colors.purple, Colors.pink]),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(CupertinoIcons.heart_fill, color: Colors.white),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Breathing Card',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'With subtle glow animation',
                                  style: TextStyle(fontSize: 13, color: Colors.white60),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'This card features a subtle breathing animation that creates an organic, living feel. Perfect for highlighting premium content or special offers.',
                        style: TextStyle(fontSize: 14, color: Colors.white70, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Multiple Glass Cards
              _buildSection('Card Grid', 'Multiple glass cards'),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  CNGlassCard(
                    breathing: false,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(CupertinoIcons.photo, color: Colors.blue),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Photos',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          const Text('1,234', style: TextStyle(fontSize: 13, color: Colors.white60)),
                        ],
                      ),
                    ),
                  ),
                  CNGlassCard(
                    breathing: false,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.purple.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(CupertinoIcons.music_note, color: Colors.purple),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Music',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          const Text('567', style: TextStyle(fontSize: 13, color: Colors.white60)),
                        ],
                      ),
                    ),
                  ),
                  CNGlassCard(
                    breathing: false,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(CupertinoIcons.doc_text, color: Colors.green),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Documents',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          const Text('89', style: TextStyle(fontSize: 13, color: Colors.white60)),
                        ],
                      ),
                    ),
                  ),
                  CNGlassCard(
                    breathing: false,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(CupertinoIcons.folder, color: Colors.orange),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Folders',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          const Text('42', style: TextStyle(fontSize: 13, color: Colors.white60)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 140),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.cyan, letterSpacing: 1.5),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.white30)),
        ],
      ),
    );
  }
}
