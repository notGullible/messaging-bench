// ignore_for_file: avoid_print

import 'package:flutter_embedder/flutter_embedder.dart';
import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';
import 'dart:typed_data';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'dart:math';
import 'model_config.dart';

class SmsClassification {
  final bool isSpam;
  final double confidence;
  SmsClassification({required this.isSpam, required this.confidence});
}

class ProcessedSms {
  final String sender;
  final String body;
  final DateTime date;
  final bool isSpam;
  final double confidence;
  final int messageLength;
  final Duration processingTime;

  ProcessedSms({
    required this.sender,
    required this.body,
    required this.date,
    required this.isSpam,
    required this.confidence,
    required this.messageLength,
    required this.processingTime,
  });
}

class SmsService {
  static final SmsQuery _query = SmsQuery();

  static Future<bool> requestPermission() async {
    final status = await Permission.sms.request();
    return status.isGranted;
  }

  static Future<bool> hasPermission() async => await Permission.sms.isGranted;

  static Future<void> openSettings() async => await openAppSettings();

  static Future<List<ProcessedSms>> getNSms(
    int numSms, {
    ModelConfig? modelConfig,
  }) async {
    final config = modelConfig ?? AvailableModels.defaultModel;
    print("!! Initializing Tokenizer & Model Session...\n");
    print("!! Using model: ${config.name}\n");

    final tokenizer = await HfTokenizer.fromAsset(config.tokenizerPath);

    final ort = OnnxRuntime();
    final session = await ort.createSessionFromAsset(config.modelPath);
    print("!! Tokenizer & Model Session Initialized\n");
    print("!! Fetching All Messages !!\n");
    try {
      final messages = await _query.querySms(
        kinds: [SmsQueryKind.inbox],
        count: numSms,
      );

      print("Got all Messages\n");
      final processed = await Future.wait(
        messages.map((sms) async {
          final body = sms.body ?? '';
          final sender = sms.sender ?? 'Unknown';
          final date = sms.date ?? DateTime.now();
          print("\tProccessing Messages:\n\t\t$body\n");

          final stopwatch = Stopwatch()..start();
          final classification = await _classify(
            body,
            sender,
            tokenizer,
            session,
          );
          stopwatch.stop();

          return ProcessedSms(
            sender: sender,
            body: body,
            date: date,
            isSpam: classification.isSpam,
            confidence: classification.confidence,
            messageLength: body.length,
            processingTime: stopwatch.elapsed,
          );
        }),
      );

      return processed;
    } catch (e, stackTrace) {
      print('❌ Error: $e');
      print(stackTrace);
      return [];
    }
  }

  static Future<SmsClassification> _classify(
    String body,
    String sender,
    HfTokenizer tokenizer,
    OrtSession session,
  ) async {
    // final text = body.toLowerCase();

    final tokenizedText = tokenizer.encode(body, addSpecialTokens: true);

    final tokens = tokenizedText.ids;
    print("\t\tTokenized Text: $tokens\n");
    print("\t\tRunning Model ... for above text\n");

    print('Inputs:  ${session.inputNames}');
    print('Outputs: ${session.outputNames}');

    final inputIds = Int64List.fromList(tokenizedText.ids);
    final attentionMask = Int64List.fromList(tokenizedText.attentionMask);
    final seqLen = tokenizedText.ids.length;

    final inputs = {
      'input_ids': await OrtValue.fromList(inputIds, [1, seqLen]),
      'attention_mask': await OrtValue.fromList(attentionMask, [1, seqLen]),
    };

    final outputs = await session.run(inputs);

    final finalScore = await outputs['logits']!.asList();
    // Softmax ------------------------
    // logits is [[ham_score, spam_score]] — flatten it
    final logits = (finalScore[0] as List).cast<double>();
    print('\t\tLogits: $logits');
    // logits = [3.458, -3.014]

    // Apply softmax
    final hamLogit = logits[0];
    final spamLogit = logits[1];

    final maxLogit = hamLogit > spamLogit
        ? hamLogit
        : spamLogit; // for numerical stability
    final expHam = exp(hamLogit - maxLogit);
    final expSpam = exp(spamLogit - maxLogit);
    final sumExp = expHam + expSpam;

    final spamScore = expSpam / sumExp;

    print('SPAM: ${(spamScore * 100).toStringAsFixed(1)}%');

    final confidence = spamScore.clamp(0.0, 1.0);
    return SmsClassification(
      isSpam: confidence >= 0.35,
      confidence: confidence >= 0.35 ? confidence : (1.0 - confidence),
    );
  }

  // ─── Aggregate stats ───────────────────────────────────────────
  static Map<String, int> getStats(List<ProcessedSms> messages) {
    final spam = messages.where((m) => m.isSpam).length;
    return {
      'total': messages.length,
      'spam': spam,
      'ham': messages.length - spam,
    };
  }

  static BenchmarkResult getBenchmarkResult(
    List<ProcessedSms> messages,
    ModelConfig modelConfig,
    Duration totalTime
  ) {
    if (messages.isEmpty) {
      return BenchmarkResult(
        modelId: modelConfig.id,
        modelName: modelConfig.name,
        totalSms: 0,
        totalTime: Duration.zero,
        avgTime: Duration.zero,
        minTime: Duration.zero,
        maxTime: Duration.zero,
        maxMsgLength: 0,
        minMsgLength: 0,
        avgMsgLength: 0,
        spamCount: 0,
        hamCount: 0,
        timestamp: DateTime.now(),
      );
    }

    final msgLengths = messages.map((m) => m.messageLength).toList();
    final processingTimes = messages
        .map((m) => m.processingTime.inMilliseconds)
        .toList();
    final spamCount = messages.where((m) => m.isSpam).length;

    return BenchmarkResult(
      modelId: modelConfig.id,
      modelName: modelConfig.name,
      totalSms: messages.length,
      totalTime: totalTime,
      avgTime: Duration(
        milliseconds:
            messages.fold(
              0,
              (sum, m) => sum + m.processingTime.inMilliseconds,
            ) ~/
            messages.length,
      ),
      minTime: Duration(
        milliseconds: processingTimes.reduce((a, b) => a < b ? a : b),
      ),
      maxTime: Duration(
        milliseconds: processingTimes.reduce((a, b) => a > b ? a : b),
      ),
      maxMsgLength: msgLengths.reduce((a, b) => a > b ? a : b),
      minMsgLength: msgLengths.reduce((a, b) => a < b ? a : b),
      avgMsgLength: msgLengths.reduce((a, b) => a + b) / messages.length,
      spamCount: spamCount,
      hamCount: messages.length - spamCount,
      timestamp: DateTime.now(),
    );
  }
}
