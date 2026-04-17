import 'dart:async';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioService {
  static final _recorder = FlutterSoundRecorder();
  static final _player   = AudioPlayer();
  static String? _currentPath;
  static bool    _recorderInitialized = false;

  static Future<void> _initRecorder() async {
    if (_recorderInitialized) return;
    await _recorder.openRecorder();
    _recorderInitialized = true;
  }

  static Future<bool> requestMicPermission() async =>
      (await Permission.microphone.request()).isGranted;

  static Future<bool> hasMicPermission() async =>
      await Permission.microphone.isGranted;

  static Future<void> startRecording() async {
    if (!await hasMicPermission()) {
      throw Exception('Permission microphone refusée');
    }
    await _initRecorder();
    final dir = await getApplicationDocumentsDirectory();
    _currentPath =
        '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.aac';
    await _recorder.startRecorder(
      toFile: _currentPath,
      codec:  Codec.aacADTS,
    );
  }

  static Future<String?> stopRecording() async {
    await _recorder.stopRecorder();
    return _currentPath;
  }

  static Future<bool> isRecording() async => _recorder.isRecording;

  static Future<String?> pickAudioFile() async {
    final result = await FilePicker.platform
        .pickFiles(type: FileType.audio, allowMultiple: false, withData: false);
    return result?.files.single.path;
  }

  static Future<String> getAudioDuration(String path) async {
    try {
      final completer = Completer<Duration>();
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
    try { _recorder.closeRecorder(); _recorderInitialized = false; } catch (_) {}
    try { _player.dispose(); } catch (_) {}
  }
}
