import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/analysis_result.dart';
import '../services/storage_service.dart';
import 'analysis_provider.dart';

final historyProvider = NotifierProvider<HistoryNotifier, List<AnalysisResult>>(() {
  return HistoryNotifier();
});

class HistoryNotifier extends Notifier<List<AnalysisResult>> {
  @override
  List<AnalysisResult> build() {
    debugPrint('🟠 [HISTORY PROVIDER] Building history provider');
    final storageService = ref.watch(storageServiceProvider);
    final history = storageService.getHistory();
    debugPrint('🟠 [HISTORY PROVIDER] Loaded ${history.length} history items');
    return history;
  }

  void loadHistory() {
    debugPrint('🟠 [HISTORY PROVIDER] Reloading history');
    final storageService = ref.read(storageServiceProvider);
    state = storageService.getHistory();
  }

  AnalysisResult? getById(String id) {
    final storageService = ref.read(storageServiceProvider);
    return storageService.getAnalysisById(id);
  }

  Future<void> updateResult(AnalysisResult result) async {
    final storageService = ref.read(storageServiceProvider);
    await storageService.updateAnalysis(result);
    loadHistory();
  }

  Future<void> clearHistory() async {
    final storageService = ref.read(storageServiceProvider);
    await storageService.clearHistory();
    state = [];
  }
}
