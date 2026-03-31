import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../model_config.dart';

const Color _bg = Color(0xFFF5F5F7);
const Color _card = Color(0xFFFFFFFF);
const Color _surface = Color(0xFFFAFAFA);
const Color _border = Color(0xFFE5E5EA);
const Color _textPrimary = Color(0xFF1C1C1E);
const Color _textSecondary = Color(0xFF6B6B6F);
const Color _textMuted = Color(0xFFAEAEB2);
const Color _accent = Color(0xFF7B9EFF);
const Color _spamRed = Color(0xFFFF8A8A);
const Color _hamGreen = Color(0xFF8ADD8A);
const Color _warnYellow = Color(0xFFFFD666);

class StatsPage extends StatelessWidget {
  final BenchmarkResult? result;

  const StatsPage({super.key, this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Benchmark Results',
          style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),
      body: result == null
          ? _buildEmpty()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildModelInfo(),
                  const SizedBox(height: 16),
                  _buildTimingSection(),
                  const SizedBox(height: 16),
                  _buildMessageLengthSection(),
                  const SizedBox(height: 16),
                  _buildClassificationSection(),
                  const SizedBox(height: 16),
                  _buildHistorySection(),
                ],
              ),
            ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined, color: _textMuted, size: 52),
          const SizedBox(height: 14),
          Text(
            'No benchmark results yet.\nRun a classification first.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: _textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildModelInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.model_training, color: _accent, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result!.modelName,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Processed ${result!.totalSms} messages',
                  style: GoogleFonts.inter(fontSize: 12, color: _textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimingSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timer_outlined, color: _accent, size: 18),
              const SizedBox(width: 8),
              Text(
                'Processing Times',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStatRow('Total Time', _formatDuration(result!.totalTime)),
          _buildStatRow('Average Time', _formatDuration(result!.avgTime)),
          _buildStatRow('Min Time', _formatDuration(result!.minTime)),
          _buildStatRow('Max Time', _formatDuration(result!.maxTime)),
        ],
      ),
    );
  }

  Widget _buildMessageLengthSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.text_fields, color: _accent, size: 18),
              const SizedBox(width: 8),
              Text(
                'Message Lengths',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStatRow('Max Length', '${result!.maxMsgLength} chars'),
          _buildStatRow('Min Length', '${result!.minMsgLength} chars'),
          _buildStatRow(
            'Avg Length',
            '${result!.avgMsgLength.toStringAsFixed(1)} chars',
          ),
        ],
      ),
    );
  }

  Widget _buildClassificationSection() {
    final spamPct = result!.totalSms > 0
        ? (result!.spamCount / result!.totalSms * 100).toStringAsFixed(1)
        : '0.0';
    final hamPct = result!.totalSms > 0
        ? (result!.hamCount / result!.totalSms * 100).toStringAsFixed(1)
        : '0.0';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.class_outlined, color: _accent, size: 18),
              const SizedBox(width: 8),
              Text(
                'Classification',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStatRow('Spam', '${result!.spamCount} ($spamPct%)', _spamRed),
          _buildStatRow('Ham', '${result!.hamCount} ($hamPct%)', _hamGreen),
        ],
      ),
    );
  }

  Widget _buildHistorySection() {
    if (BenchmarkHistory.results.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history, color: _accent, size: 18),
              const SizedBox(width: 8),
              Text(
                'Recent Runs',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...BenchmarkHistory.results.take(5).map((r) => _buildHistoryItem(r)),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(BenchmarkResult r) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              r.modelName,
              style: GoogleFonts.inter(fontSize: 12, color: _textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${r.totalSms} msgs',
            style: GoogleFonts.inter(fontSize: 11, color: _textMuted),
          ),
          const SizedBox(width: 8),
          Text(
            _formatDuration(r.avgTime),
            style: GoogleFonts.inter(fontSize: 11, color: _accent),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 13, color: _textSecondary),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor ?? _textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    if (d.inMilliseconds >= 1000) {
      return '${(d.inMilliseconds / 1000).toStringAsFixed(2)}s';
    }
    return '${d.inMilliseconds}ms';
  }
}
