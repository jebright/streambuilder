import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayer/audioplayer.dart';

import 'player_state.dart';

class _PlayerWidgetState extends State<Player> {
  final AudioPlayer audioPlayer = new AudioPlayer();
  final StreamController<PlayerState> _streamController =
      new StreamController<PlayerState>();
  double mediaDuration;
  double mediaPosition;
  bool muted = false;

  _PlayerWidgetState() {
    audioPlayer.setCompletionHandler(() {
      _streamController.add(PlayerState.stopped());
    });

    audioPlayer.setDurationHandler((d) {
      mediaDuration = d.inMilliseconds.toDouble();
      print('Duration: ' + mediaDuration.toString());
      _streamController.add(PlayerState.initial());
    });

    audioPlayer.setPositionHandler((p) {
      mediaPosition = p.inMilliseconds.toDouble();
      print('Position: ' + mediaPosition.toString());
      _streamController.add(PlayerState.playing(mediaPosition));
    });
  }

  Future<String> load(BuildContext context) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = new File("${dir.path}/Top Gun Anthem.mp3");
    if (!(await file.exists())) {
      final soundData = await DefaultAssetBundle
          .of(context)
          .load("assets/Top Gun Anthem.mp3");
      final bytes = soundData.buffer.asUint8List();
      await file.writeAsBytes(bytes, flush: true);
    }
    return file.path;
  }

  Widget buildUi(BuildContext context, PlayerState ps) {
    List<Widget> buttons = new List<Widget>();

    print('building UI for state: ' +
        (ps.isInitial
            ? "initial"
            : ps.isPlaying ? "playing" : ps.isPaused ? "paused" : "unknown"));

    buttons.add(new IconButton(
        onPressed: ps.isPlaying ? null : () => play(context),
        iconSize: 64.0,
        icon: new Icon(Icons.play_arrow),
        color: Colors.cyan));

    buttons.add(new IconButton(
        onPressed: !ps.isPlaying ? null : () => pause(),
        iconSize: 64.0,
        icon: new Icon(Icons.pause),
        color: Colors.cyan));

    buttons.add(new IconButton(
        onPressed: ps.isPlaying ? () => stop() : null,
        iconSize: 64.0,
        icon: new Icon(Icons.stop),
        color: Colors.cyan));

    buttons.add(new IconButton(
        onPressed: () => muted ? mute(false) : mute(true),
        iconSize: 64.0,
        icon: muted ? new Icon(Icons.headset) : new Icon(Icons.headset_off),
        color: Colors.cyan));

    var c = new Column(children: [
      new Row(children: buttons, mainAxisAlignment: MainAxisAlignment.spaceEvenly),
      new Slider(
        value: ps?.position ?? 0.0,
        onChanged: (double value) =>
            audioPlayer.seek((value / 1000).roundToDouble()),
        min: 0.0,
        max: mediaDuration ?? 0.0,
      ),
      new Row(children: [
      ])
    ]);
    return c;
  }

  play(BuildContext context) async {
    var url = await load(context);
    final result = await audioPlayer.play(url, isLocal: true);

    if (result == 1) {
      _streamController.add(PlayerState.playing(mediaPosition));
    }
  }

  pause() async {
    final result = await audioPlayer.pause();
    if (result == 1) {
      _streamController.add(PlayerState.paused(mediaPosition));
    }
  }

  stop() async {
    final result = await audioPlayer.stop();
    if (result == 1) {
      _streamController.add(PlayerState.stopped());
    }
  }

  mute(bool muting) async {
    print('muting ? ' + (muting? 'yes' : 'no')); 
    this.muted = muting;
    final result = await audioPlayer.mute(muted);
    if(result == 1) {
      _streamController.add(PlayerState.muted());
    }
  }


  @override
  build(BuildContext context) {
    return new StreamBuilder<PlayerState>(
        stream: _streamController.stream,
        initialData: new PlayerState.initial(),
        builder: (BuildContext context, AsyncSnapshot<PlayerState> snapshot) {
          final playerState = snapshot.data;
          return buildUi(context, playerState);
        });
  }
}

class Player extends StatefulWidget {
  const Player(Key key) : super(key: key);

  @override
  _PlayerWidgetState createState() => new _PlayerWidgetState();
}
