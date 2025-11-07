import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/analysis_result.dart';
import '../services/storage_service.dart';
import 'analysis_provider.dart';

final historyProvider = StateNotifierProvider<HistoryNotifier, List<AnalysisResult>>((ref) {
  return HistoryNotifier(ref.watch(storageServiceProvider));
});

class HistoryNotifier extends StateNotifier<List<AnalysisResult>> {
  final StorageService _storageService;

  HistoryNotifier(this._storageService) : super([]) {
    loadHistory();
  }

  void loadHistory() {
    state = _storageService.getHistory();
  }

  AnalysisResult? getById(String id) {
    return _storageService.getAnalysisById(id);
  }

  Future<void> clearHistory() async {
    await _storageService.clearHistory();
    state = [];
  }
}
