import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../model_config.dart';
import 'sms_page.dart';

const Color _bg = Color(0xFFF8F9FC);
const Color _card = Color(0xFFFFFFFF);
const Color _surface = Color(0xFFF0F2F8);
const Color _border = Color(0xFFE4E6EC);
const Color _textPrimary = Color(0xFF2D3142);
const Color _textSecondary = Color(0xFF9094A6);
const Color _textMuted = Color(0xFFB8BCC8);

const Color _pastelBlue = Color(0xFFB4D4FF);
const Color _pastelPurple = Color(0xFFD4B4FF);
const Color _pastelPink = Color(0xFFFFB4D4);
const Color _pastelGreen = Color(0xFFB4FFD4);
const Color _pastelYellow = Color(0xFFFFEAB4);

class ConfigRunPage extends StatefulWidget {
  const ConfigRunPage({super.key});

  @override
  State<ConfigRunPage> createState() => _ConfigRunPageState();
}

class _ConfigRunPageState extends State<ConfigRunPage> {
  String _runType = 'single';
  String _taskType = 'classification';
  int _messageCount = 20;
  String? _selectedModel;
  List<String> _availableModels = [];
  List<String> _selectedModels = [];
  bool _loadingModels = true;

  @override
  void initState() {
    super.initState();
    _loadModels();
  }

  Future<void> _loadModels() async {
    setState(() => _loadingModels = true);
    try {
      final modelNames = AvailableModels.models.map((m) => m.id).toList();
      print("List of available Models: $modelNames");
      setState(() {
        _availableModels = modelNames;
        _selectedModel = modelNames.isNotEmpty ? modelNames.first : null;
        _selectedModels = modelNames.isNotEmpty ? [modelNames.first] : [];
        _loadingModels = false;
      });
    } catch (e) {
      print("Error loading models: ${e.toString()}");
      setState(() {
        _availableModels = [];
        _loadingModels = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      'Benchmark\nConfiguration',
                      style: GoogleFonts.poppins(
                        fontSize: 25,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Configure your run parameters',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: _textSecondary,
                      ),
                    ),
                    const SizedBox(height: 32),

                    _buildSection(
                      title: 'Run Type',
                      icon: Icons.speed_rounded,
                      color: _pastelBlue,
                      child: _buildRunTypeSelector(),
                    ),
                    const SizedBox(height: 20),

                    if (_runType == 'single')
                      _buildSection(
                        title: 'Select Model',
                        icon: Icons.model_training_rounded,
                        color: _pastelPurple,
                        child: _buildSingleModelSelector(),
                      )
                    else
                      _buildSection(
                        title: 'Select Models',
                        icon: Icons.merge_type_rounded,
                        color: _pastelPurple,
                        child: _buildMultiModelSelector(),
                      ),
                    const SizedBox(height: 20),

                    _buildSection(
                      title: 'Task Type',
                      icon: Icons.task_alt_rounded,
                      color: _pastelPink,
                      child: _buildTaskTypeSelector(),
                    ),
                    const SizedBox(height: 20),

                    _buildSection(
                      title: 'Number of Messages',
                      icon: Icons.message_rounded,
                      color: _pastelGreen,
                      child: _buildMessageCountSelector(),
                    ),
                    const SizedBox(height: 20),

                    _buildSection(
                      title: 'Data Source',
                      icon: Icons.source_rounded,
                      color: _pastelYellow,
                      child: _buildDataSourceSelector(),
                    ),
                  ],
                ),
              ),
            ),
            _buildStartButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: _textPrimary, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildRunTypeSelector() {
    return Row(
      children: [
        Expanded(
          child: _selectableChip(
            label: 'Single Model',
            icon: Icons.person_outline,
            isSelected: _runType == 'single',
            color: _pastelBlue,
            onTap: () => setState(() {
              _runType = 'single';
              _selectedModels = _availableModels.isNotEmpty
                  ? [_availableModels.first]
                  : [];
            }),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _selectableChip(
            label: 'Multi Model',
            icon: Icons.people_outline,
            isSelected: _runType == 'multi',
            color: _pastelBlue,
            onTap: () => setState(() {
              _runType = 'multi';
              _selectedModels = List.from(_availableModels);
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildSingleModelSelector() {
    if (_loadingModels) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: CircularProgressIndicator(
            color: _pastelPurple,
            strokeWidth: 2,
          ),
        ),
      );
    }
    if (_availableModels.isEmpty) {
      return Text(
        'No models found in assets/models/',
        style: GoogleFonts.inter(color: _textMuted, fontSize: 13),
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _availableModels.map((model) {
        final isSelected = _selectedModel == model;
        return GestureDetector(
          onTap: () => setState(() {
            _selectedModel = model;
            _selectedModels = [model];
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? _pastelPurple.withValues(alpha: 0.3)
                  : _surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isSelected ? _pastelPurple : _border),
            ),
            child: Text(
              model,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? _textPrimary : _textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMultiModelSelector() {
    if (_loadingModels) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: CircularProgressIndicator(
            color: _pastelPurple,
            strokeWidth: 2,
          ),
        ),
      );
    }
    if (_availableModels.isEmpty) {
      return Text(
        'No models found in assets/models/',
        style: GoogleFonts.inter(color: _textMuted, fontSize: 13),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select models to compare (${_selectedModels.length} selected)',
          style: GoogleFonts.inter(fontSize: 11, color: _textMuted),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableModels.map((model) {
            final isSelected = _selectedModels.contains(model);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedModels.remove(model);
                  } else {
                    _selectedModels.add(model);
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? _pastelPurple.withValues(alpha: 0.3)
                      : _surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? _pastelPurple : _border,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSelected
                          ? Icons.check_circle_rounded
                          : Icons.circle_outlined,
                      size: 14,
                      color: isSelected ? _pastelPurple : _textMuted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      model,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: isSelected ? _textPrimary : _textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTaskTypeSelector() {
    return Row(
      children: [
        Expanded(
          child: _selectableChip(
            label: 'Classification',
            icon: Icons.category_rounded,
            isSelected: _taskType == 'classification',
            color: _pastelPink,
            onTap: () => setState(() => _taskType = 'classification'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _selectableChip(
            label: 'Benchmark',
            icon: Icons.analytics_rounded,
            isSelected: _taskType == 'benchmark',
            color: _pastelPink,
            onTap: () => setState(() => _taskType = 'benchmark'),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageCountSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: _pastelGreen,
                  inactiveTrackColor: _surface,
                  thumbColor: _pastelGreen,
                  overlayColor: _pastelGreen.withValues(alpha: 0.2),
                  trackHeight: 6,
                ),
                child: Slider(
                  value: _messageCount.toDouble(),
                  min: 1,
                  max: 500,
                  divisions: 499,
                  onChanged: (v) => setState(() => _messageCount = v.round()),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => _showMessageCountDialog(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$_messageCount',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _quickSelectChip('10', () => setState(() => _messageCount = 10)),
            const SizedBox(width: 6),
            _quickSelectChip('20', () => setState(() => _messageCount = 20)),
            const SizedBox(width: 6),
            _quickSelectChip('50', () => setState(() => _messageCount = 50)),
            const SizedBox(width: 6),
            _quickSelectChip('100', () => setState(() => _messageCount = 100)),
            const SizedBox(width: 6),
            _quickSelectChip('200', () => setState(() => _messageCount = 200)),
          ],
        ),
      ],
    );
  }

  Widget _quickSelectChip(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(fontSize: 11, color: _textSecondary),
        ),
      ),
    );
  }

  Widget _buildDataSourceSelector() {
    final bool needsCsv = _taskType == 'classification';
    return Row(
      children: [
        Expanded(
          child: _selectableChip(
            label: 'Local Messages',
            icon: Icons.phone_android_rounded,
            isSelected: true,
            color: _pastelYellow,
            onTap: () {},
            fullWidth: true,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: needsCsv
                ? () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('CSV File'),
                        content: const Text(
                          'CSV selection would be implemented here',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  }
                : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: needsCsv ? _surface : _surface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.table_chart_rounded,
                    size: 16,
                    color: needsCsv ? _textSecondary : _textMuted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'CSV File',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: needsCsv ? _textSecondary : _textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _selectableChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
    bool fullWidth = false,
  }) {
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: fullWidth
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      children: [
        Icon(
          isSelected ? Icons.check_circle_rounded : icon,
          size: 16,
          color: isSelected ? _textPrimary : _textMuted,
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? _textPrimary : _textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: fullWidth ? 16 : 14,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.3) : _surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : _border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: fullWidth
            ? FittedBox(fit: BoxFit.scaleDown, child: content)
            : content,
      ),
    );
  }

  void _showMessageCountDialog() {
    final controller = TextEditingController(text: _messageCount.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Enter Message Count',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
            hintText: '1-500',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value != null && value >= 1 && value <= 500) {
                setState(() => _messageCount = value);
              }
              Navigator.pop(ctx);
            },
            child: Text('Apply'),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _card,
        border: Border(top: BorderSide(color: _border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const Placeholder()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.history_rounded,
                  color: _textSecondary,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _startRun,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _pastelPurple,
                  foregroundColor: _textPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.play_arrow_rounded, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Start Run',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startRun() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ClassificationScreen()),
    );
  }
}
