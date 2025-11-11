import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/analysis_result.dart';
import '../services/storage_service.dart';
import 'analysis_provider.dart';

final historyProvider = NotifierProvider<HistoryNotifier, List<AnalysisResult>>(() {
  return HistoryNotifier();
});

class HistoryNotifier extends Notifier<List<AnalysisResult>> {
  late final StorageService _storageService;

  @override
  List<AnalysisResult> build() {
    _storageService = ref.watch(storageServiceProvider);
    return _storageService.getHistory();
  }

  void loadHistory() {
    state = _storageService.getHistory();
  }

  AnalysisResult? getById(String id) {
    return _storageService.getAnalysisById(id);
  }

  Future<void> updateResult(AnalysisResult result) async {
    await _storageService.updateAnalysis(result);
    loadHistory();
  }

  Future<void> clearHistory() async {
    await _storageService.clearHistory();
    state = [];
  }
}
