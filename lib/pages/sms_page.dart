import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../sms.dart';

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

class ClassificationScreen extends StatefulWidget {
  const ClassificationScreen({super.key});

  @override
  State<ClassificationScreen> createState() => _ClassificationScreenState();
}

class _ClassificationScreenState extends State<ClassificationScreen> {
  List<ProcessedSms> _all = [];
  List<ProcessedSms> _filtered = [];
  bool _loading = true;
  bool _noPerm = false;
  String _filter = 'All';
  String _query = '';
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSms();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSms() async {
    setState(() {
      _loading = true;
      _noPerm = false;
    });

    final hasPerm = await SmsService.hasPermission();
    if (!hasPerm) {
      setState(() {
        _loading = false;
        _noPerm = true;
      });
      return;
    }

    final messages = await SmsService.getNSms(20);
    setState(() {
      _all = messages;
      _loading = false;
    });
    _applyFilter();
  }

  void _applyFilter() {
    List<ProcessedSms> result = _all;
    if (_filter == 'Spam') result = result.where((m) => m.isSpam).toList();
    if (_filter == 'Ham') result = result.where((m) => !m.isSpam).toList();
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      result = result
          .where(
            (m) =>
                m.sender.toLowerCase().contains(q) ||
                m.body.toLowerCase().contains(q),
          )
          .toList();
    }
    setState(() => _filtered = result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        automaticallyImplyLeading: false,
        title: Text(
          'Messages',
          style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadSms,
            tooltip: 'Refresh',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(106),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) {
                    _query = v;
                    _applyFilter();
                  },
                  style: GoogleFonts.inter(fontSize: 14, color: _textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Search sender or message...',
                    hintStyle: GoogleFonts.inter(color: _textMuted),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      size: 18,
                      color: _textMuted,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    filled: true,
                    fillColor: _card,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                child: Row(
                  children: ['All', 'Spam', 'Ham'].map((f) {
                    final sel = _filter == f;
                    final col = f == 'Spam'
                        ? _spamRed
                        : f == 'Ham'
                        ? _hamGreen
                        : _accent;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          _filter = f;
                          _applyFilter();
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: sel ? col.withValues(alpha: 0.15) : _card,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: sel ? col : _border,
                              width: 1.2,
                            ),
                          ),
                          child: Text(
                            f,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: sel
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: sel ? col : _textMuted,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: _accent, strokeWidth: 2.5),
            const SizedBox(height: 16),
            Text(
              'Reading your messages...',
              style: GoogleFonts.inter(color: _textSecondary),
            ),
          ],
        ),
      );
    }

    if (_noPerm) {
      return _buildNoPermission();
    }

    if (_filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, color: _textMuted, size: 52),
            const SizedBox(height: 14),
            Text(
              _query.isNotEmpty
                  ? 'No messages match your search.'
                  : 'No messages found.',
              style: GoogleFonts.inter(color: _textSecondary),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: _accent,
      backgroundColor: _card,
      onRefresh: _loadSms,
      child: Column(
        children: [
          // Stats bar
          _buildStatsBar(),
          // Message list
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 90),
              itemCount: _filtered.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (_, i) => _SmsCard(
                sms: _filtered[i],
                onTap: () => _showDetail(_filtered[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBar() {
    final stats = SmsService.getStats(_all);
    return Container(
      color: _surface,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      child: Row(
        children: [
          _statChip('${stats['total']}', 'Total', _accent),
          _statChip('${stats['spam']}', 'Spam', _spamRed),
          _statChip('${stats['ham']}', 'Safe', _hamGreen),
          const Spacer(),
          Text(
            'Showing ${_filtered.length}',
            style: GoogleFonts.inter(color: _textMuted, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _statChip(String count, String label, Color color) => Container(
    margin: const EdgeInsets.only(right: 14),
    child: Row(
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          '$count $label',
          style: GoogleFonts.inter(fontSize: 11, color: _textSecondary),
        ),
      ],
    ),
  );

  Widget _buildNoPermission() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _warnYellow.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.no_encryption_outlined,
                color: _warnYellow,
                size: 44,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'SMS Access Required',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'SpamShield needs SMS permission to display your messages.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: _textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await SmsService.requestPermission();
                  _loadSms();
                },
                icon: const Icon(Icons.message_rounded),
                label: Text(
                  'Grant SMS Access',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => SmsService.openSettings(),
              child: Text(
                'Open App Settings',
                style: GoogleFonts.inter(color: _textMuted, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(ProcessedSms sms) {
    final color = sms.isSpam ? _spamRed : _hamGreen;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        maxChildSize: 0.85,
        minChildSize: 0.35,
        builder: (_, ctrl) => Container(
          decoration: BoxDecoration(
            color: _card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(color: _border.withValues(alpha: 0.5)),
          ),
          child: ListView(
            controller: ctrl,
            padding: const EdgeInsets.all(22),
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        sms.sender.isNotEmpty
                            ? sms.sender[0].toUpperCase()
                            : '?',
                        style: GoogleFonts.inter(
                          color: color,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sms.sender,
                          style: GoogleFonts.inter(
                            color: _textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          _formatDate(sms.date),
                          style: GoogleFonts.inter(
                            color: _textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      sms.isSpam ? 'SPAM' : 'SAFE',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              // Message body
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _border),
                ),
                child: Text(
                  sms.body,
                  style: GoogleFonts.inter(
                    color: _textPrimary,
                    fontSize: 13,
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              // Confidence
              Text(
                'Detection confidence',
                style: GoogleFonts.inter(color: _textMuted, fontSize: 11),
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: sms.confidence,
                  minHeight: 7,
                  backgroundColor: _surface,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${(sms.confidence * 100).toStringAsFixed(0)}% confidence',
                style: GoogleFonts.inter(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 22),
              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.check_circle_outline, size: 16),
                      label: Text(
                        'Mark Safe',
                        style: GoogleFonts.inter(fontSize: 13),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _hamGreen,
                        side: BorderSide(
                          color: _hamGreen.withValues(alpha: 0.4),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.block, size: 16),
                      label: Text(
                        'Mark Spam',
                        style: GoogleFonts.inter(fontSize: 13),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _spamRed,
                        side: BorderSide(
                          color: _spamRed.withValues(alpha: 0.4),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    final now = DateTime.now();
    final diff = now.difference(d);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${d.day}/${d.month}/${d.year}';
  }
}

// ─── SMS Card Widget ──────────────────────────────────────────────
class _SmsCard extends StatelessWidget {
  final ProcessedSms sms;
  final VoidCallback onTap;
  const _SmsCard({required this.sms, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = sms.isSpam ? _spamRed : _hamGreen;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: sms.isSpam
                ? _spamRed.withValues(alpha: 0.25)
                : _border.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  sms.sender.isNotEmpty ? sms.sender[0].toUpperCase() : '?',
                  style: GoogleFonts.inter(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 11),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          sms.sender,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _shortDate(sms.date),
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: _textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    sms.body,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: _textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Confidence bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: sms.confidence,
                      minHeight: 3,
                      backgroundColor: _surface,
                      color: color.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                sms.isSpam ? 'SPAM' : 'HAM',
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: color,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _shortDate(DateTime d) {
    final now = DateTime.now();
    final diff = now.difference(d);
    if (diff.inHours < 24) {
      return '${d.hour}:${d.minute.toString().padLeft(2, '0')}';
    }
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${d.day}/${d.month}';
  }
}
