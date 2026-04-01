class ModelConfig {
  final String id;
  final String name;
  final String modelPath;
  final String tokenizerPath;

  const ModelConfig({
    required this.id,
    required this.name,
    required this.modelPath,
    required this.tokenizerPath,
  });
}

class AvailableModels {
  static const List<ModelConfig> models = [
    ModelConfig(
      id: 'onnx-adaptruncate_270326-2002',
      name: 'Onnx-Adaptruncate 270326-2002',
      modelPath: 'assets/models/onnx-adaptruncate_270326-2002/model.onnx',
      tokenizerPath: 'assets/models/onnx-adaptruncate_270326-2002/tokenizer.json',
    ),
  ];

  static ModelConfig get defaultModel => models.first;
}

class ProcessingResult {
  final String sender;
  final String body;
  final DateTime date;
  final bool isSpam;
  final double confidence;
  final int messageLength;
  final Duration processingTime;

  ProcessingResult({
    required this.sender,
    required this.body,
    required this.date,
    required this.isSpam,
    required this.confidence,
    required this.messageLength,
    required this.processingTime,
  });
}

class BenchmarkResult {
  final String modelId;
  final String modelName;
  final int totalSms;
  final Duration totalTime;
  final Duration avgTime;
  final Duration minTime;
  final Duration maxTime;
  final int maxMsgLength;
  final int minMsgLength;
  final double avgMsgLength;
  final int spamCount;
  final int hamCount;
  final DateTime timestamp;

  BenchmarkResult({
    required this.modelId,
    required this.modelName,
    required this.totalSms,
    required this.totalTime,
    required this.avgTime,
    required this.minTime,
    required this.maxTime,
    required this.maxMsgLength,
    required this.minMsgLength,
    required this.avgMsgLength,
    required this.spamCount,
    required this.hamCount,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'modelId': modelId,
    'modelName': modelName,
    'totalSms': totalSms,
    'totalTimeMs': totalTime.inMilliseconds,
    'avgTimeMs': avgTime.inMilliseconds,
    'minTimeMs': minTime.inMilliseconds,
    'maxTimeMs': maxTime.inMilliseconds,
    'maxMsgLength': maxMsgLength,
    'minMsgLength': minMsgLength,
    'avgMsgLength': avgMsgLength,
    'spamCount': spamCount,
    'hamCount': hamCount,
    'timestamp': timestamp.toIso8601String(),
  };
}

class BenchmarkHistory {
  static final List<BenchmarkResult> results = [];

  static void addResult(BenchmarkResult result) {
    results.insert(0, result);
    if (results.length > 50) {
      results.removeLast();
    }
  }

  static BenchmarkResult? get latest =>
      results.isNotEmpty ? results.first : null;

  static BenchmarkResult? getByModel(String modelId) {
    try {
      return results.firstWhere((r) => r.modelId == modelId);
    } catch (_) {
      return null;
    }
  }
}
