import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:audioplayers/audioplayers.dart' as ap;
import '../models/track.dart';
import '../models/nature_sound.dart';

class AudioProvider extends ChangeNotifier {
  final AudioPlayer _musicPlayer = AudioPlayer();
  final ap.AudioPlayer _naturePlayer = ap.AudioPlayer(); // audioplayers 사용
  
  Track? _currentTrack;
  List<Track> _playlist = [];
  int _currentIndex = 0;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _musicVolume = 0.7;
  double _natureVolume = 0.2;
  bool _isRepeatOne = false;
  bool _isRepeatAll = false;
  Duration? _sleepTimerDuration;
  DateTime? _sleepTimerEndTime;
  NatureSound? _currentNatureSound;
  bool _isNaturePlaying = false;
  
  // 피드백 관련
  Function(Track)? _onTrackCompleted;

  Track? get currentTrack => _currentTrack;
  List<Track> get playlist => _playlist;
  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  Duration get duration => _duration;
  double get musicVolume => _musicVolume;
  double get natureVolume => _natureVolume;
  bool get isRepeatOne => _isRepeatOne;
  bool get isRepeatAll => _isRepeatAll;
  bool get hasPrevious => _currentIndex > 0;
  bool get hasNext => _currentIndex < _playlist.length - 1;
  Duration? get sleepTimerDuration => _sleepTimerDuration;
  DateTime? get sleepTimerEndTime => _sleepTimerEndTime;
  NatureSound? get currentNatureSound => _currentNatureSound;
  bool get isNaturePlaying => _isNaturePlaying;

  // StreamSubscription 저장용
  final List<StreamSubscription> _subscriptions = [];

  AudioProvider() {
    _init();
  }

  void _init() {
    _subscriptions.add(_musicPlayer.positionStream.listen((position) {
      _position = position;
      notifyListeners();
    }));

    _subscriptions.add(_musicPlayer.durationStream.listen((duration) {
      _duration = duration ?? Duration.zero;
      notifyListeners();
    }));

    _subscriptions.add(_musicPlayer.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      notifyListeners();
    }));

    _subscriptions.add(_musicPlayer.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        // 완료된 트랙 정보를 미리 저장
        final completedTrack = _currentTrack;
        
        // 트랙 완료 시 피드백 트리거 (깊은 수면 시간대가 아닌 경우에만)
        final now = DateTime.now();
        final isDeepSleepTime = now.hour >= 0 && now.hour < 5; // 자정~오전 5시
        
        if (completedTrack != null && !isDeepSleepTime && _onTrackCompleted != null) {
          // 2초 후 피드백 다이얼로그 표시
          Future.delayed(const Duration(seconds: 2), () {
            _onTrackCompleted!(completedTrack);
          });
        }
        
        // 네이티브 플레이리스트를 사용하므로 수동 처리 불필요
        // just_audio가 자동으로 다음 트랙으로 진행하거나 반복 처리
      }
    }));

    // 현재 재생 중인 트랙 인덱스 추적
    _subscriptions.add(_musicPlayer.currentIndexStream.listen((index) {
      if (index != null && index < _playlist.length) {
        _currentIndex = index;
        _currentTrack = _playlist[index];
        notifyListeners();
      }
    }));

    // 자연음 플레이어 상태 스트림을 구독 리스트에 추가
    _subscriptions.add(_naturePlayer.onPlayerStateChanged.listen((state) {
      _isNaturePlaying = (state == ap.PlayerState.playing);
      debugPrint('자연음 플레이어 상태 변경: ${state == ap.PlayerState.playing}');
      notifyListeners();
    }));

    // 자연음 플레이어 기본 설정
    _naturePlayer.setVolume(_natureVolume);
    _naturePlayer.setReleaseMode(ap.ReleaseMode.loop);
    // Android에서 동시 재생을 위한 설정 - mediaPlayer 모드 사용 (긴 오디오용)
    _naturePlayer.setPlayerMode(ap.PlayerMode.mediaPlayer);
    // 오디오 포커스를 공유하도록 설정
    _naturePlayer.setAudioContext(ap.AudioContext(
      android: ap.AudioContextAndroid(
        isSpeakerphoneOn: false,
        stayAwake: true,  // 재생 중 시스템이 sleep 모드로 가지 않도록 설정
        contentType: ap.AndroidContentType.music,
        usageType: ap.AndroidUsageType.media,
        audioFocus: ap.AndroidAudioFocus.none, // 오디오 포커스를 요청하지 않음
      ),
    ));
  }

  Future<void> loadTrack(Track track) async {
    _currentTrack = track;
    
    // 미디어 알림을 위한 태그 설정
    final mediaItem = MediaItem(
      id: track.id.toString(),
      album: track.category,
      title: track.title,
      artist: track.artist.isEmpty ? 'EverySleep' : track.artist,
      artUri: (track.thumbnail != null && track.thumbnail!.isNotEmpty) ? Uri.parse(track.thumbnail!) : null,
    );
    
    await _musicPlayer.setAudioSource(
      AudioSource.uri(
        Uri.parse(track.url),
        tag: mediaItem,
      ),
    );
    
    notifyListeners();
  }

  Future<void> _createPlaylistSource(List<Track> tracks) async {
    final audioSources = tracks.map((track) {
      final mediaItem = MediaItem(
        id: track.id.toString(),
        album: track.category,
        title: track.title,
        artist: track.artist.isEmpty ? 'EverySleep' : track.artist,
        artUri: (track.thumbnail != null && track.thumbnail!.isNotEmpty) ? Uri.parse(track.thumbnail!) : null,
      );
      
      return AudioSource.uri(
        Uri.parse(track.url),
        tag: mediaItem,
      );
    }).toList();
    
    // setAudioSources 사용 (ConcatenatingAudioSource deprecated)
    await _musicPlayer.setAudioSources(audioSources, initialIndex: _currentIndex);
  }

  Future<void> loadPlaylist(List<Track> tracks, {int startIndex = 0}) async {
    _playlist = tracks;
    _currentIndex = startIndex;
    if (tracks.isNotEmpty) {
      _currentTrack = tracks[startIndex];
      await _createPlaylistSource(tracks);
      
      // 반복 모드 설정
      await _musicPlayer.setLoopMode(_isRepeatOne 
        ? LoopMode.one 
        : _isRepeatAll 
          ? LoopMode.all 
          : LoopMode.off);
      
      notifyListeners();
    }
  }

  Future<void> play() async {
    await _musicPlayer.play();
    if (_currentNatureSound != null && !_isNaturePlaying) {
      await _naturePlayer.resume();
    }
  }

  Future<void> pause() async {
    await _musicPlayer.pause();
    if (_isNaturePlaying) {
      await _naturePlayer.pause();
    }
  }

  Future<void> stop() async {
    await _musicPlayer.stop();
    await _naturePlayer.stop();
    _position = Duration.zero;
    notifyListeners();
  }

  Future<void> seek(Duration position) async {
    await _musicPlayer.seek(position);
  }

  Future<void> skipToPrevious() async {
    await _musicPlayer.seekToPrevious();
  }

  Future<void> skipToNext() async {
    await _musicPlayer.seekToNext();
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
    if (_isRepeatOne) {
      _isRepeatAll = false; // 한 곡 반복 시 플레이리스트 반복 해제
      _musicPlayer.setLoopMode(LoopMode.one);
    } else {
      _musicPlayer.setLoopMode(LoopMode.off);
    }
    notifyListeners();
  }

  void toggleRepeatAll() {
    _isRepeatAll = !_isRepeatAll;
    if (_isRepeatAll) {
      _isRepeatOne = false; // 플레이리스트 반복 시 한 곡 반복 해제
      _musicPlayer.setLoopMode(LoopMode.all);
    } else {
      _musicPlayer.setLoopMode(LoopMode.off);
    }
    notifyListeners();
  }

  Future<void> loadNatureSound(NatureSound? sound) async {
    try {
      // 기존 재생 중인 자연음이 있으면 먼저 정지
      if (_isNaturePlaying) {
        await _naturePlayer.stop();
        await Future.delayed(const Duration(milliseconds: 100)); // 짧은 대기
      }
      
      if (sound == null) {
        _currentNatureSound = null;
        _isNaturePlaying = false;
        notifyListeners();
        return;
      }

      debugPrint('자연음 로드 시작: ${sound.name}, URL: ${sound.url}');
      _currentNatureSound = sound;
      
      // 음악과 동시 재생을 위해 mediaPlayer 모드 유지
      await _naturePlayer.setPlayerMode(ap.PlayerMode.mediaPlayer);
      
      // play 메서드를 직접 사용 (setSource + resume 대신)
      debugPrint('자연음 재생 시작');
      await _naturePlayer.play(ap.UrlSource(sound.url));
      debugPrint('자연음 재생 명령 완료');
      
      notifyListeners();
    } catch (e) {
      debugPrint('자연음 로드 오류: $e');
      _currentNatureSound = null;
      _isNaturePlaying = false;
      notifyListeners();
    }
  }

  Future<void> toggleNatureSound() async {
    if (_currentNatureSound == null) return;
    
    if (_isNaturePlaying) {
      await _naturePlayer.pause();
    } else {
      await _naturePlayer.resume();
    }
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

  // 피드백 콜백 설정
  void setTrackCompletedCallback(Function(Track)? callback) {
    _onTrackCompleted = callback;
  }

  @override
  void dispose() {
    debugPrint('🔴 AudioProvider dispose 시작 - 모든 오디오 정지');
    
    try {
      // 1. Stream 구독 해제 (메모리 누수 방지)
      for (final subscription in _subscriptions) {
        subscription.cancel();
      }
      _subscriptions.clear();
      
      // 2. 타이머 취소
      _sleepTimerDuration = null;
      _sleepTimerEndTime = null;
      
      // 3. 재생 중인 모든 오디오 즉시 정지 (비동기 처리)
      _stopAllAudioSync();
      
      debugPrint('✅ AudioProvider dispose 완료');
    } catch (e) {
      debugPrint('❌ AudioProvider dispose 실패: $e');
    }
    
    super.dispose();
  }

  void _stopAllAudioSync() {
    // 동기적으로 정지 처리
    _musicPlayer.stop().catchError((e) => debugPrint('음악 정지 실패: $e'));
    _naturePlayer.stop().catchError((e) => debugPrint('자연음 정지 실패: $e'));
    
    // 리소스 해제
    _musicPlayer.dispose().catchError((e) => debugPrint('음악 플레이어 해제 실패: $e'));
    _naturePlayer.dispose().catchError((e) => debugPrint('자연음 플레이어 해제 실패: $e'));
  }

  // 앱 종료 시 호출할 강제 정지 메서드
  Future<void> forceStopAll() async {
    try {
      debugPrint('🔴 모든 오디오 강제 정지');
      
      // 재생 중인 모든 오디오 즉시 정지
      await _musicPlayer.stop();
      await _naturePlayer.stop();
      
      // 상태 초기화
      _isPlaying = false;
      _isNaturePlaying = false;
      _currentTrack = null;
      _currentNatureSound = null;
      
      notifyListeners();
      debugPrint('✅ 모든 오디오 강제 정지 완료');
    } catch (e) {
      debugPrint('❌ 강제 정지 실패: $e');
    }
  }
}