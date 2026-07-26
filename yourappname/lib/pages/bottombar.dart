import 'package:yourappname/pages/bottombar_pages/audiobook.dart';
import 'package:yourappname/pages/bottombar_pages/home.dart';
import 'package:yourappname/pages/bottombar_pages/magazinedata.dart';
import 'package:yourappname/pages/bottombar_pages/mylibrary.dart';
import 'package:yourappname/provider/generalprovider.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/widget/mytext.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:yourappname/pages/bottombar_pages/categorydata.dart';
import 'package:yourappname/utils/color.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

ValueNotifier<AudioPlayer?> currentlyPlaying = ValueNotifier(null);
double playerMinHeight = (!kIsWeb) ? 100 : 120;
const miniplayerPercentageDeclaration = 0.7;

// ───────────────────────────────────────────────────────────────────────────
// Nav item descriptor
// ───────────────────────────────────────────────────────────────────────────
class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem(this.icon, this.activeIcon, this.label);
}

const List<_NavItem> _navItems = [
  _NavItem(Icons.home_outlined, Icons.home_rounded, 'Home'),
  _NavItem(Icons.grid_view_outlined, Icons.grid_view_rounded, 'Explore'),
  _NavItem(Icons.menu_book_outlined, Icons.menu_book_rounded, 'Magazines'),
  _NavItem(Icons.headphones_outlined, Icons.headphones_rounded, 'Audio'),
  _NavItem(Icons.local_library_outlined, Icons.local_library_rounded, 'Library'),
];

// ───────────────────────────────────────────────────────────────────────────
// Bottombar widget
// ───────────────────────────────────────────────────────────────────────────
class Bottombar extends StatefulWidget {
  const Bottombar({super.key});

  @override
  State<Bottombar> createState() => _BottombarState();
}

class _BottombarState extends State<Bottombar> with SingleTickerProviderStateMixin {
  late GeneralProvider generalProvider;
  DateTime? currentBackPressTime;

  static List<Widget> widgetOptions = <Widget>[
    Home(),
    CategoryData(),
    MagazineData(),
    AudioBook(),
    MyLibrary(),
  ];

  @override
  void initState() {
    generalProvider = Provider.of<GeneralProvider>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) => onBackPressed(didPop),
      child: Scaffold(
        extendBody: true,
        body: Consumer<GeneralProvider>(
          builder: (context, gp, _) =>
              widgetOptions.elementAt(gp.currentIndex),
        ),
        bottomNavigationBar: Consumer<GeneralProvider>(
          builder: (context, gp, _) => _FloatingNavBar(
            currentIndex: gp.currentIndex,
            onTap: gp.setIndex,
          ),
        ),
      ),
    );
  }

  Future<void> onBackPressed(bool didPop) async {
    if (didPop) return;
    if (generalProvider.currentIndex == 0) {
      final now = DateTime.now();
      if (currentBackPressTime == null ||
          now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
        currentBackPressTime = now;
        showExitDialog();
      }
    } else {
      generalProvider.setIndex(0);
    }
  }

  void showExitDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: MyText(
          text: "are_sure_exit",
          multilanguage: true,
          maxline: 2,
          fontsize: Dimens.medium18TextSize,
          fontwaight: FontWeight.w500,
        ),
        actions: [
          Row(children: [
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  if (Navigator.canPop(ctx)) Navigator.pop(ctx);
                  SystemNavigator.pop();
                },
                child: Container(
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [colorPrimary, colorPrimaryDark],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: MyText(
                    color: white,
                    text: "yes",
                    textalign: TextAlign.center,
                    fontsize: Dimens.medium16TextSize,
                    multilanguage: true,
                    maxline: 1,
                    fontwaight: FontWeight.w600,
                    fontstyle: FontStyle.normal,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  if (Navigator.canPop(ctx)) Navigator.pop(ctx);
                },
                child: Container(
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: gray.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: MyText(
                    text: "no",
                    multilanguage: true,
                    textalign: TextAlign.center,
                    fontsize: Dimens.medium16TextSize,
                    maxline: 1,
                    fontwaight: FontWeight.w600,
                    fontstyle: FontStyle.normal,
                  ),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// Floating pill navigation bar
// ───────────────────────────────────────────────────────────────────────────
class _FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _FloatingNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1E1E2E) : Colors.white;
    final shadow = isDark
        ? Colors.black.withOpacity(0.5)
        : colorPrimary.withOpacity(0.15);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        child: Container(
          height: 68,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(34),
            boxShadow: [
              BoxShadow(color: shadow, blurRadius: 24, spreadRadius: 2),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _navItems.length,
              (i) => _NavTile(
                item: _navItems[i],
                isActive: currentIndex == i,
                onTap: () => onTap(i),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// Single nav tile with animated pill indicator
// ───────────────────────────────────────────────────────────────────────────
class _NavTile extends StatefulWidget {
  final _NavItem item;
  final bool isActive;
  final VoidCallback onTap;

  const _NavTile({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_NavTile> createState() => _NavTileState();
}

class _NavTileState extends State<_NavTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack);
    if (widget.isActive) _ctrl.value = 1.0;
  }

  @override
  void didUpdateWidget(_NavTile old) {
    super.didUpdateWidget(old);
    if (widget.isActive && !old.isActive) {
      _ctrl.forward(from: 0.0);
    } else if (!widget.isActive && old.isActive) {
      _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated pill container
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: widget.isActive
                    ? colorPrimary.withOpacity(0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.8, end: 1.0).animate(_scale),
                child: Icon(
                  widget.isActive ? widget.item.activeIcon : widget.item.icon,
                  size: 24,
                  color: widget.isActive ? colorPrimary : gray,
                ),
              ),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                fontWeight:
                    widget.isActive ? FontWeight.w700 : FontWeight.w400,
                color: widget.isActive ? colorPrimary : gray,
              ),
              child: Text(widget.item.label),
            ),
          ],
        ),
      ),
    );
  }
}
