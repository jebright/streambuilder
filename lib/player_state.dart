class PlayerState {
  final bool isInitial;
  final bool isPlaying;
  final bool isPaused;
  final bool isStopped;
  final double position;

  PlayerState.initial(
      {this.isInitial = true, this.isPlaying = false, this.isPaused = false, this.isStopped = false, this.position = 0.0});

  PlayerState.playing(this.position,
      {this.isInitial = false, this.isPlaying = true, this.isPaused = false, this.isStopped = false});

  PlayerState.paused(this.position,
      {this.isInitial = false, this.isPlaying = false, this.isPaused = true, this.isStopped = false});

  PlayerState.stopped(
    {this.isInitial = false, this.isPlaying = false, this.isPaused = false, this.isStopped = true, this.position = 0.0});

  PlayerState.muted(
    {this.isInitial = false, this.isPlaying = false, this.isPaused = false, this.isStopped = true, this.position = 0.0});
    
}
