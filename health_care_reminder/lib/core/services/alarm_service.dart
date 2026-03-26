import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';

/// [AlarmService] is responsible for managing alarms and notifications related to health care reminders.
class AlarmService {
  static final AlarmService _instance = AlarmService._internal();

  factory AlarmService() {
    return _instance;
  }

  AlarmService._internal();

  AudioPlayer? _audioPlayers;
  bool _isPlaying = false;

  Future<void> playAlarm() async {
    try {
      if (_isPlaying) return;

      _audioPlayers = AudioPlayer();

      await _audioPlayers!.setAudioContext(
        AudioContext(
          android: const AudioContextAndroid(
            // Huawei/HarmonyOS sering me-mute kalau kita set ke 'alarm' murni, ganti ke notification.
            usageType: AndroidUsageType.notification,
            // Sonification lebih tepat untuk alert/notifikasi dibandingkan music
            contentType: AndroidContentType.sonification,
            audioFocus: AndroidAudioFocus.gainTransient,
          ),
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: {AVAudioSessionOptions.mixWithOthers},
          ),
        ),
      );

      _isPlaying = true;

      await _audioPlayers!.setReleaseMode(ReleaseMode.loop);
      await _audioPlayers!.play(
        AssetSource('audio/alarm_sound.mp3'),
        volume: 1.0, // Volume native mentok di 1.0 (100%)
      );
      debugPrint("Alarm started playing");
    } catch (e) {
      debugPrint("Error playing alarm: $e");
    }
  }

  Future<void> stopAlarm() async {
    try {
      await _audioPlayers?.stop();
      await _audioPlayers?.dispose();
      _isPlaying = false;
      _audioPlayers = null;
      debugPrint("Alarm stopped");
    } catch (e) {
      debugPrint("Error stopping alarm: $e");
    }
  }
}
