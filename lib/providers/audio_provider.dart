import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import '../models/track.dart';

class AudioProvider extends ChangeNotifier {
  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _naturePlayer = AudioPlayer();
  
  Track? _currentTrack;
  List<Track> _playlist = [];
  int _currentIndex = 0;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _musicVolume = 0.7;
  double _natureVolume = 0.3;
  bool _isRepeatOne = false;
  Duration? _sleepTimerDuration;
  DateTime? _sleepTimerEndTime;

  Track? get currentTrack => _currentTrack;
  List<Track> get playlist => _playlist;
  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  Duration get duration => _duration;
  double get musicVolume => _musicVolume;
  double get natureVolume => _natureVolume;
  bool get isRepeatOne => _isRepeatOne;
  bool get hasPrevious => _currentIndex > 0;
  bool get hasNext => _currentIndex < _playlist.length - 1;
  Duration? get sleepTimerDuration => _sleepTimerDuration;
  DateTime? get sleepTimerEndTime => _sleepTimerEndTime;

  AudioProvider() {
    _init();
  }

  void _init() {
    _musicPlayer.positionStream.listen((position) {
      _position = position;
      notifyListeners();
    });

    _musicPlayer.durationStream.listen((duration) {
      _duration = duration ?? Duration.zero;
      notifyListeners();
    });

    _musicPlayer.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      notifyListeners();
    });

    _musicPlayer.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        if (_isRepeatOne) {
          _musicPlayer.seek(Duration.zero);
          _musicPlayer.play();
        } else {
          skipToNext();
        }
      }
    });
  }

  Future<void> loadTrack(Track track) async {
    _currentTrack = track;
    await _musicPlayer.setAudioSource(
      AudioSource.uri(
        Uri.parse(track.url),
        tag: MediaItem(
          id: track.id,
          album: track.category,
          title: track.title,
          artist: track.artist,
          artUri: Uri.parse(track.thumbnail),
        ),
      ),
    );
    notifyListeners();
  }

  Future<void> loadPlaylist(List<Track> tracks, {int startIndex = 0}) async {
    _playlist = tracks;
    _currentIndex = startIndex;
    if (tracks.isNotEmpty) {
      await loadTrack(tracks[startIndex]);
    }
  }

  Future<void> play() async {
    await _musicPlayer.play();
  }

  Future<void> pause() async {
    await _musicPlayer.pause();
  }

  Future<void> stop() async {
    await _musicPlayer.stop();
    _position = Duration.zero;
    notifyListeners();
  }

  Future<void> seek(Duration position) async {
    await _musicPlayer.seek(position);
  }

  Future<void> skipToPrevious() async {
    if (hasPrevious) {
      _currentIndex--;
      await loadTrack(_playlist[_currentIndex]);
      await play();
    }
  }

  Future<void> skipToNext() async {
    if (hasNext) {
      _currentIndex++;
      await loadTrack(_playlist[_currentIndex]);
      await play();
    }
  }

  void setMusicVolume(double volume) {
    _musicVolume = volume;
    _musicPlayer.setVolume(volume);
    notifyListeners();
  }

  void setNatureVolume(double volume) {
    _natureVolume = volume;
    _naturePlayer.setVolume(volume);
    notifyListeners();
  }

  void toggleRepeatOne() {
    _isRepeatOne = !_isRepeatOne;
    notifyListeners();
  }

  Future<void> loadNatureSound(String url) async {
    await _naturePlayer.setAudioSource(
      AudioSource.uri(Uri.parse(url)),
    );
    await _naturePlayer.setLoopMode(LoopMode.all);
    await _naturePlayer.play();
  }

  void setSleepTimer(Duration duration) {
    _sleepTimerDuration = duration;
    _sleepTimerEndTime = DateTime.now().add(duration);
    
    Future.delayed(duration, () {
      if (_sleepTimerEndTime != null && 
          DateTime.now().isAfter(_sleepTimerEndTime!.subtract(const Duration(seconds: 1)))) {
        stop();
        _sleepTimerDuration = null;
        _sleepTimerEndTime = null;
        notifyListeners();
      }
    });
    
    notifyListeners();
  }

  void cancelSleepTimer() {
    _sleepTimerDuration = null;
    _sleepTimerEndTime = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _musicPlayer.dispose();
    _naturePlayer.dispose();
    super.dispose();
  }
}