import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../data/question_bank.dart';
import '../models/quiz_question.dart';
import '../models/quiz_result.dart';
import '../models/quiz_session.dart';
import '../models/user_profile.dart';
import '../services/local_storage_service.dart';

class AppController extends ChangeNotifier {
  AppController(this._storage);
  final LocalStorageService _storage;
  final List<UserProfile> users = [];
  final List<QuizSession> sessions = [];
  final List<QuizResult> results = [];
  bool isDarkMode = false;
  UserProfile? currentUser;
  QuizSession? currentSession;
  QuizResult? latestResult;
  Stopwatch? _stopwatch;
  Timer? _ticker;
  bool _ready = false;
  bool get isReady => _ready;
  int get elapsedSeconds => (currentSession?.elapsedSeconds ?? 0) + (_stopwatch?.elapsed.inSeconds ?? 0);
  List<QuizQuestion> get currentQuestions => currentSession == null ? [] : currentSession!.questionIds.map((id) => questionBank.firstWhere((q) => q.id == id)).toList();
  List<QuizResult> get currentUserResults => results.where((r) => r.userId == currentUser?.id).toList()..sort((a,b) => b.completedAt.compareTo(a.completedAt));
  QuizSession? get pausedSession => sessions.where((s) => s.userId == currentUser?.id && s.status == SessionStatus.paused).fold<QuizSession?>(null, (best, s) => best == null || (s.lastPausedAt ?? s.startedAt).isAfter(best.lastPausedAt ?? best.startedAt) ? s : best);

  Future<void> initialize() async {
    final data = await _storage.load();
    isDarkMode = data['isDarkMode'] as bool? ?? false;
    users.addAll(((data['users'] as List?) ?? []).map((e) => UserProfile.fromJson(Map<String,dynamic>.from(e as Map))));
    sessions.addAll(((data['sessions'] as List?) ?? []).map((e) => QuizSession.fromJson(Map<String,dynamic>.from(e as Map))));
    results.addAll(((data['results'] as List?) ?? []).map((e) => QuizResult.fromJson(Map<String,dynamic>.from(e as Map))));
    _ready = true; notifyListeners();
  }
  Future<void> _save() => _storage.save({'isDarkMode':isDarkMode,'users':users.map((e)=>e.toJson()).toList(),'sessions':sessions.map((e)=>e.toJson()).toList(),'results':results.map((e)=>e.toJson()).toList()});
  Future<void> toggleTheme() async { isDarkMode = !isDarkMode; notifyListeners(); await _save(); }
  String? validateName(String raw) { final name = raw.trim(); if (name.length < 3) return 'Nama harus diisi dengan minimal 3 karakter.'; return null; }
  Future<UserProfile?> enterName(String raw) async {
    if (validateName(raw) != null) return null;
    final name = raw.trim(); final normalized = name.toLowerCase();
    currentUser = users.where((u)=>u.normalizedName == normalized).firstOrNull;
    currentUser ??= UserProfile(id: DateTime.now().microsecondsSinceEpoch.toString(), displayName:name, normalizedName:normalized);
    if (!users.any((u)=>u.id == currentUser!.id)) users.add(currentUser!);
    currentSession = pausedSession;
    await _save(); notifyListeners(); return currentUser;
  }
  Future<QuizSession> startSession() async {
    if (currentUser == null) throw StateError('Pengguna belum dipilih.');
    final ids = questionBank.map((q)=>q.id).toList()..shuffle(Random());
    final session = QuizSession(id:DateTime.now().microsecondsSinceEpoch.toString(), userId:currentUser!.id, questionIds:ids, startedAt:DateTime.now());
    sessions.add(session); currentSession = session; latestResult = null; _startClock(); await _save(); notifyListeners(); return session;
  }
  void _startClock() { _stopClock(); _stopwatch = Stopwatch()..start(); _ticker = Timer.periodic(const Duration(seconds:1), (_) { notifyListeners(); }); }
  void _stopClock() { _ticker?.cancel(); _ticker = null; _stopwatch?.stop(); _stopwatch = null; }
  Future<void> chooseAnswer(String questionId, int? optionIndex) async { final s=currentSession; if (s==null || s.status!=SessionStatus.active) return; s.answers[questionId]=optionIndex; await _save(); notifyListeners(); }
  Future<void> goToQuestion(int index) async { final s=currentSession; if(s==null)return; s.currentIndex=index.clamp(0,s.questionIds.length-1).toInt(); await _save(); notifyListeners(); }
  Future<void> resumeSession() async {
    final s = pausedSession;
    if (s == null) return;
    currentSession = s;
    s.status = SessionStatus.active;
    s.lastPausedAt = null;
    _startClock();
    await _save();
    notifyListeners();
  }
  Future<void> pauseSession() async { final s=currentSession; if(s==null || s.status!=SessionStatus.active)return; s.elapsedSeconds=elapsedSeconds; s.status=SessionStatus.paused; s.lastPausedAt=DateTime.now(); _stopClock(); await _save(); notifyListeners(); }
  Future<QuizResult?> completeSession() async {
    final s=currentSession; if(s==null || s.status==SessionStatus.completed)return latestResult;
    s.elapsedSeconds=elapsedSeconds; _stopClock();
    final correct = s.questionIds.where((id)=>s.answers[id] != null && s.answers[id] == questionBank.firstWhere((q)=>q.id==id).correctIndex).length;
    final result=QuizResult(sessionId:s.id,userId:s.userId,correctCount:correct,totalQuestions:s.questionIds.length,durationSeconds:s.elapsedSeconds,completedAt:DateTime.now());
    s.status=SessionStatus.completed; s.completedAt=result.completedAt; latestResult=result;
    if(!results.any((r)=>r.sessionId==s.id)) results.add(result);
    await _save(); notifyListeners(); return result;
  }
  QuizResult? resultForSession(String id) { for(final r in results){if(r.sessionId==id)return r;} return null; }
  List<QuizResult> get leaderboardByScore { final best=<String,QuizResult>{}; for(final r in results){final old=best[r.userId]; if(old==null || r.percentage>old.percentage || (r.percentage==old.percentage && r.durationSeconds<old.durationSeconds)) best[r.userId]=r;} final list=best.values.toList()..sort((a,b){final c=b.percentage.compareTo(a.percentage); return c!=0?c:a.durationSeconds.compareTo(b.durationSeconds);}); return list; }
  List<QuizResult> get leaderboardByDuration { final best=<String,QuizResult>{}; for(final r in results){final old=best[r.userId]; if(old==null || r.durationSeconds<old.durationSeconds || (r.durationSeconds==old.durationSeconds && r.percentage>old.percentage)) best[r.userId]=r;} final list=best.values.toList()..sort((a,b){final c=a.durationSeconds.compareTo(b.durationSeconds); return c!=0?c:b.percentage.compareTo(a.percentage);}); return list; }
  @override void dispose(){_stopClock(); super.dispose();}
}

extension _FirstOrNull<E> on Iterable<E> { E? get firstOrNull { final iterator= this.iterator; return iterator.moveNext()?iterator.current:null; } }
