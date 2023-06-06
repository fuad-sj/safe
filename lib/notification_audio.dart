import 'package:audioplayers/audioplayers.dart';

class NotifAudio {
  static NotifAudio? _singleton;
  AudioPlayer? player;

  NotifAudio._();

  Future<void> _init() async {
    if (player == null) {
      player = AudioPlayer(playerId: "safe_customer_player")
        ..setReleaseMode(ReleaseMode.stop);
    }
  }

  static Future<NotifAudio> getInstance() async {
    if (_singleton == null) {
      var single = NotifAudio._();
      await single._init();
      _singleton = single;
    }
    return _singleton!;
  }

  AudioPlayer getAudioPlayer() {
    return player!;
  }
}
