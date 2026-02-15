import 'dart:async';

class TokenService {
  static const int _dailyLimit = 50;
  int _usageCount = 0;
  final StreamController<int> _usageController = StreamController<int>.broadcast();

  // Singleton pattern
  static final TokenService _instance = TokenService._internal();
  factory TokenService() => _instance;
  TokenService._internal();

  Stream<int> get usageStream => _usageController.stream;
  int get currentUsage => _usageCount;
  int get remainingTokens => _dailyLimit - _usageCount;

  /// Checks if the user has enough tokens to perform an action.
  /// Throws an exception if the limit is reached.
  void checkLimit() {
    if (_usageCount >= _dailyLimit) {
      throw Exception('Daily AI Token Limit Reached ($_dailyLimit). Upgrade plan to continue.');
    }
  }

  /// Increments the usage count.
  /// Should be called after a successful API call.
  void incrementUsage() {
    _usageCount++;
    _usageController.add(_usageCount);
  }

  /// Resets usage (for testing or daily reset logic).
  void resetUsage() {
    _usageCount = 0;
    _usageController.add(_usageCount);
  }
}
