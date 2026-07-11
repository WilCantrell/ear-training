# Wil's Ear Training

A macOS ear-training app built with Flutter, styled after macOS Tahoe's
Liquid Glass design language — frosted translucent surfaces over a photo
backdrop, with a native frosted sidebar.

## Features

Seven training modules, each with graded difficulty levels, ten-question
sessions, and per-level progress tracking (best score, sessions completed,
accuracy):

- **Chords** — identify a chord's quality, from major-vs-minor up to seventh
  chords in any inversion.
- **Intervals** — name the interval between two notes, ascending, descending
  or harmonic.
- **Scales** — identify a scale or mode played melodically.
- **Scale Degrees** — a I–IV–V–I cadence establishes the key, then one note
  plays; name its degree (functional ear training).
- **Interval Comparison** — two intervals play; say which is wider. The size
  difference shrinks to one semitone as you level up.
- **Progressions** — identify a diatonic chord progression (I–IV–V, ii–V–I,
  I–V–vi–IV, …) by its roman numerals.
- **Pitch** — two pure tones; was the second higher, lower or the same? Down
  to 5-cent differences at the top level.

Additional touches:

- **Selectable timbre** — piano, voice, sine, strings or organ, rendered
  offline from a bundled General MIDI soundfont (TimGM6mb) or a pure-Dart
  sine synthesizer. The choice persists across launches. The Pitch module
  always uses sine tones so cent-level detunes are exact.
- **On-screen keyboard** that lights up the answer's notes after you respond.
- **Per-module progress footer** with an aggregate summary and reset.

## Platforms

macOS only (currently). The app targets macOS via `macos_ui` for native
look-and-feel and `flutter_soloud` for audio playback; the macOS runner is
configured with `macos_window_utils` so the sidebar shows the system's
frosted-glass material. No iOS, Windows, Linux or web targets are set up.

## Running

Prerequisites: [Flutter](https://docs.flutter.dev/get-started/install/macos)
(3.35+) with the macOS desktop toolchain (Xcode + CocoaPods).

```sh
flutter pub get
flutter run -d macos          # debug
flutter run -d macos --release
```

Build a standalone app bundle:

```sh
flutter build macos --release
# → build/macos/Build/Products/Release/eartraining.app
```

Run the tests (models, question generators, audio rendering — no native
audio layer required):

```sh
flutter test
```

Static analysis:

```sh
flutter analyze
```

## Project layout

```
lib/
  app.dart                  # window shell: sidebar + active module
  models/                   # music theory + quiz abstractions and levels
  services/                 # audio engine, sine renderer, question generators
  state/                    # session controller, progress persistence
  theme/                    # macOS themes, glass palette, title font
  ui/
    quiz/                   # shared level-select and session screens
    widgets/                # glass card, background, keyboard, buttons
    <module>/               # one thin wrapper per training module
assets/
  fonts/                    # FrancoisOne (page titles)
  images/                   # window background
  soundfonts/               # TimGM6mb.sf2 (General MIDI)
```

## Notes

- Progress is stored locally via `shared_preferences`; the Reset Progress
  button in each module's footer clears that module only.
- The TimGM6mb soundfont is the trimmed General MIDI set distributed with
  MuseScore 1.x / Debian's `timgm6mb-soundfont` package.
