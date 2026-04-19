// audio_record.dart
// Linux       → ffmpeg via dart:io  (sudo apt install ffmpeg)
// Android/iOS → flutter_sound

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import '../widgets/global/app_styles.dart';

class AudioRecordSheet extends StatefulWidget {
  final void Function(String audioPath) onSave;
  const AudioRecordSheet({super.key, required this.onSave});

  @override
  State<AudioRecordSheet> createState() => _AudioRecordSheetState();
}

class _AudioRecordSheetState extends State<AudioRecordSheet> {
  _Status  _status  = _Status.idle;
  Duration _elapsed = Duration.zero;
  Timer?   _timer;

  // ── Linux : ffmpeg ─────────────────────────────────────────────────────────
  Process?           _ffmpegProcess;
  final List<String> _segments = [];
  String?            _finalPath;

  // ── Android/iOS : flutter_sound ────────────────────────────────────────────
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _recorderOpened = false;

  bool get _isDesktop =>
      Platform.isLinux || Platform.isWindows || Platform.isMacOS;

  // ─── Chemins ───────────────────────────────────────────────────────────────

  Future<String> _newPath(String prefix) async {
    final dir = await getApplicationDocumentsDirectory();
    return p.join(
        dir.path, '${prefix}_${DateTime.now().millisecondsSinceEpoch}.aac');
  }

  // ─── Linux : ffmpeg ────────────────────────────────────────────────────────

  Future<void> _ffmpegStartSegment() async {
    final path = await _newPath('segment');
    _ffmpegProcess = await Process.start(
        'ffmpeg', ['-f', 'alsa', '-i', 'default', '-y', path]);
    _segments.add(path);
  }

  Future<void> _ffmpegStopSegment() async {
    try {
      _ffmpegProcess?.stdin.write('q');
      await _ffmpegProcess?.stdin.flush();
      await _ffmpegProcess?.exitCode.timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          _ffmpegProcess?.kill();
          return -1;
        },
      );
    } catch (_) {
      _ffmpegProcess?.kill();
    }
    _ffmpegProcess = null;
  }

  Future<void> _ffmpegMerge(String output) async {
    if (_segments.length == 1) {
      _finalPath = _segments.first;
      return;
    }
    final dir      = await getApplicationDocumentsDirectory();
    final listFile = p.join(dir.path, 'segments_list.txt');
    await File(listFile)
        .writeAsString(_segments.map((s) => "file '$s'").join('\n'));
    await Process.run('ffmpeg', [
      '-f', 'concat', '-safe', '0',
      '-i', listFile, '-c', 'copy', '-y', output
    ]);
    for (final s in _segments) {
      try { File(s).deleteSync(); } catch (_) {}
    }
    try { File(listFile).deleteSync(); } catch (_) {}
    _finalPath = output;
  }

  // ─── Android/iOS : flutter_sound ──────────────────────────────────────────

  Future<void> _openRecorder() async {
    if (!_recorderOpened) {
      await Permission.microphone.request();
      await _recorder.openRecorder();
      _recorderOpened = true;
    }
  }

  Future<void> _soundStart() async {
    await _openRecorder();
    final path = await _newPath('temoignage');
    _finalPath = path;
    await _recorder.startRecorder(
      toFile: path,
      codec:  Codec.aacADTS,
    );
  }

  Future<void> _soundPause()  async => await _recorder.pauseRecorder();
  Future<void> _soundResume() async => await _recorder.resumeRecorder();
  Future<void> _soundStop()   async => await _recorder.stopRecorder();

  // ─── Actions unifiées ──────────────────────────────────────────────────────

  Future<void> _startRecording() async {
    _segments.clear();
    _elapsed   = Duration.zero;
    _finalPath = null;

    if (_isDesktop) {
      await _ffmpegStartSegment();
    } else {
      await _soundStart();
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsed += const Duration(seconds: 1));
    });
    setState(() => _status = _Status.recording);
  }

  Future<void> _pauseRecording() async {
    _timer?.cancel();
    if (_isDesktop) {
      await _ffmpegStopSegment();
    } else {
      await _soundPause();
    }
    setState(() => _status = _Status.paused);
  }

  Future<void> _resumeRecording() async {
    if (_isDesktop) {
      await _ffmpegStartSegment();
    } else {
      await _soundResume();
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsed += const Duration(seconds: 1));
    });
    setState(() => _status = _Status.recording);
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    if (_isDesktop) {
      await _ffmpegStopSegment();
      final out = await _newPath('temoignage');
      await _ffmpegMerge(out);
    } else {
      await _soundStop();
    }
    setState(() => _status = _Status.done);
  }

  void _saveTestimony() {
    if (_finalPath != null) {
      widget.onSave(_finalPath!);
      Navigator.of(context).pop();
    }
  }

  void _reset() {
    _timer?.cancel();
    _ffmpegProcess?.kill();
    for (final s in _segments) {
      try { File(s).deleteSync(); } catch (_) {}
    }
    setState(() {
      _status    = _Status.idle;
      _elapsed   = Duration.zero;
      _finalPath = null;
      _segments.clear();
    });
  }

  String get _elapsedLabel {
    final m = _elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = _elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ffmpegProcess?.kill();
    if (_recorderOpened) _recorder.closeRecorder();
    super.dispose();
  }

  // ─── UI ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color:        AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const Text('Témoignage oral',
              style: TextStyle(
                  fontSize:   18,
                  fontWeight: FontWeight.w700,
                  color:      AppColors.textPrimary)),
          const SizedBox(height: 32),
          _Magnetophone(status: _status, elapsedLabel: _elapsedLabel),
          const SizedBox(height: 32),

          if (_status == _Status.idle)
            _CtrlButton(
              icon:  Icons.fiber_manual_record,
              label: "Démarrer l'enregistrement",
              color: const Color(0xFFE53935),
              onTap: _startRecording,
            ),

          if (_status == _Status.recording) ...[
            _CtrlButton(
              icon: Icons.pause, label: 'Pause',
              color: AppColors.textMuted, onTap: _pauseRecording),
            const SizedBox(height: 12),
            _CtrlButton(
              icon: Icons.stop, label: 'Arrêter',
              color: const Color(0xFFE53935), onTap: _stopRecording),
          ],

          if (_status == _Status.paused) ...[
            _CtrlButton(
              icon: Icons.play_arrow, label: 'Reprendre',
              color: AppColors.textPrimary, onTap: _resumeRecording),
            const SizedBox(height: 12),
            _CtrlButton(
              icon: Icons.stop, label: 'Arrêter',
              color: const Color(0xFFE53935), onTap: _stopRecording),
          ],

          if (_status == _Status.done) ...[
            _CtrlButton(
              icon: Icons.save_alt, label: 'Enregistrer le témoignage',
              color: AppColors.textPrimary, onTap: _saveTestimony,
              filled: true),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: _reset,
              icon:  const Icon(Icons.refresh,
                  size: 16, color: AppColors.textMuted),
              label: const Text('Recommencer',
                  style: TextStyle(
                      color: AppColors.textMuted, fontSize: 13)),
            ),
          ],
        ],
      ),
    );
  }
}

class _Magnetophone extends StatelessWidget {
  final _Status status;
  final String  elapsedLabel;
  const _Magnetophone(
      {required this.status, required this.elapsedLabel});

  @override
  Widget build(BuildContext context) {
    final isRecording = status == _Status.recording;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
      decoration: BoxDecoration(
        color:        AppColors.inputFill,
        borderRadius: BorderRadius.circular(16),
        border:       Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              if (isRecording)
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFE53935)
                        .withValues(alpha: 0.15),
                  ),
                ),
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isRecording
                      ? const Color(0xFFE53935).withValues(alpha: 0.2)
                      : AppColors.surface,
                  border: Border.all(
                    color: isRecording
                        ? const Color(0xFFE53935)
                        : const Color(0xFF444444),
                  ),
                ),
                child: Icon(Icons.mic,
                    size:  30,
                    color: isRecording
                        ? const Color(0xFFE53935)
                        : AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(elapsedLabel,
              style: const TextStyle(
                fontSize:     36,
                fontWeight:   FontWeight.w300,
                color:        AppColors.textPrimary,
                fontFeatures: [FontFeature.tabularFigures()],
              )),
          const SizedBox(height: 8),
          Text(_statusLabel(status),
              style: TextStyle(
                fontSize: 12,
                color: isRecording
                    ? const Color(0xFFE53935)
                    : AppColors.textMuted,
              )),
        ],
      ),
    );
  }

  String _statusLabel(_Status s) {
    switch (s) {
      case _Status.idle:      return 'Prêt à enregistrer';
      case _Status.recording: return '● Enregistrement en cours';
      case _Status.paused:    return 'En pause';
      case _Status.done:      return 'Enregistrement terminé';
    }
  }
}

class _CtrlButton extends StatelessWidget {
  final IconData icon; final String label;
  final Color color; final VoidCallback onTap; final bool filled;
  const _CtrlButton({
    required this.icon, required this.label,
    required this.color, required this.onTap, this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: filled ? color : Colors.transparent,
          foregroundColor: filled ? AppColors.background : color,
          side: BorderSide(
              color: filled ? color : const Color(0xFF444444)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
        icon:  Icon(icon, size: 18),
        label: Text(label,
            style: const TextStyle(fontSize: 14)),
      ),
    );
  }
}

enum _Status { idle, recording, paused, done }
