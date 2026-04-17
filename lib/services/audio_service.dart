import 'dart:async';
import 'package:record/record.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioService {
  static final _recorder = Record();
  static final _player   = AudioPlayer();
  static String? _currentPath;

  static Future<bool> requestMicPermission() async =>
      (await Permission.microphone.request()).isGranted;

  static Future<bool> hasMicPermission() async =>
      await _recorder.hasPermission();

  static Future<void> startRecording() async {
    if (!await _recorder.hasPermission()) {
      throw Exception('Permission microphone refusée');
    }
    final dir = await getApplicationDocumentsDirectory();
    _currentPath =
        '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(
      path:         _currentPath!,
      encoder:      AudioEncoder.aacLc,
      bitRate:      128000,
      samplingRate: 44100,
    );
  }

  static Future<String?> stopRecording() async {
    await _recorder.stop();
    return _currentPath;
  }

  static Future<bool> isRecording() async => await _recorder.isRecording();

  static Future<String?> pickAudioFile() async {
    final result = await FilePicker.platform
        .pickFiles(type: FileType.audio, allowMultiple: false, withData: false);
    return result?.files.single.path;
  }

  static Future<String> getAudioDuration(String path) async {
    try {
      final completer = Completer<Duration>();

      // Écoute avec StreamSubscription pour éviter "No element"
      StreamSubscription<Duration>? sub;
      sub = _player.onDurationChanged.listen((d) {
        if (!completer.isCompleted) completer.complete(d);
        sub?.cancel();
      });

      await _player.setSourceDeviceFile(path);

      final d = await completer.future
          .timeout(const Duration(seconds: 5), onTimeout: () {
        sub?.cancel();
        return Duration.zero;
      });

      final h = d.inHours.toString().padLeft(2, '0');
      final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
      final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
      return '$h:$m:$s';
    } catch (_) {
      return '00:00:00';
    }
  }

  static Future<void> playAudio(String path) async {
    await _player.play(DeviceFileSource(path));
  }

  static Future<void> stopAudio() async => await _player.stop();

  static void dispose() {
    _recorder.dispose();
    _player.dispose();
  }
}
