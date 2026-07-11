import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:macos_ui/macos_ui.dart';

import 'theme/app_theme.dart';
import 'ui/chords/chords_module.dart';
import 'ui/comparison/comparison_module.dart';
import 'ui/degrees/degrees_module.dart';
import 'ui/intervals/intervals_module.dart';
import 'ui/pitch/pitch_module.dart';
import 'ui/progressions/progressions_module.dart';
import 'ui/scales/scales_module.dart';
import 'ui/widgets/app_background.dart';

class EarTrainingApp extends StatelessWidget {
  const EarTrainingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MacosApp(
      title: "Wil's Ear Training",
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const _AppShell(),
    );
  }
}

/// Top-level window: a module sidebar plus the active module's content.
/// Only the Chords module is active today; others are shown as "coming soon".
class _AppShell extends StatefulWidget {
  const _AppShell();

  @override
  State<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<_AppShell> {
  int _moduleIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Avoid a first-frame flash before the photo decodes.
    precacheImage(const AssetImage('assets/images/background.png'), context);
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: MacosWindow(
        // Both the window and every scaffold must stay transparent so the
        // backdrop in AppBackground shows through. disableWallpaperTinting is
        // required: with tinting active, WallpaperTintedArea repaints the
        // scaffold background at forced full opacity once any blurred toolbar
        // exists.
        backgroundColor: MacosColors.transparent,
        disableWallpaperTinting: true,
        sidebar: Sidebar(
          minWidth: 220,
          isResizable: false,
          builder: (context, scrollController) {
            return SidebarItems(
              currentIndex: _moduleIndex,
              scrollController: scrollController,
              onChanged: (index) => setState(() => _moduleIndex = index),
              items: const [
                SidebarItem(
                  leading: MacosIcon(CupertinoIcons.music_note_list),
                  label: Text('Chords'),
                ),
                SidebarItem(
                  leading: MacosIcon(CupertinoIcons.metronome),
                  label: Text('Intervals'),
                ),
                SidebarItem(
                  leading: MacosIcon(CupertinoIcons.waveform),
                  label: Text('Scales'),
                ),
                SidebarItem(
                  leading: MacosIcon(CupertinoIcons.list_number),
                  label: Text('Scale Degrees'),
                ),
                SidebarItem(
                  leading: MacosIcon(CupertinoIcons.arrow_left_right),
                  label: Text('Comparison'),
                ),
                SidebarItem(
                  leading: MacosIcon(CupertinoIcons.music_note_2),
                  label: Text('Progressions'),
                ),
                SidebarItem(
                  leading: MacosIcon(CupertinoIcons.tuningfork),
                  label: Text('Pitch'),
                ),
              ],
            );
          },
        ),
        child: switch (_moduleIndex) {
          1 => const IntervalsModule(),
          2 => const ScalesModule(),
          3 => const DegreesModule(),
          4 => const ComparisonModule(),
          5 => const ProgressionsModule(),
          6 => const PitchModule(),
          _ => const ChordsModule(),
        },
      ),
    );
  }
}
