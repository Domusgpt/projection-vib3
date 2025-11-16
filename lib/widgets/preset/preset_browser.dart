import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/preset.dart';
import '../../services/preset_manager.dart';
import '../../providers/engine_provider.dart';
import '../../utils/vib3_colors.dart';
import '../../utils/vib3_theme.dart';

/// Preset browser for loading, saving, and managing presets
class PresetBrowser extends ConsumerStatefulWidget {
  const PresetBrowser({super.key});

  @override
  ConsumerState<PresetBrowser> createState() => _PresetBrowserState();
}

class _PresetBrowserState extends ConsumerState<PresetBrowser> {
  final PresetManager _presetManager = PresetManager();
  List<VIB3Preset> _presets = [];
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPresets();
  }

  Future<void> _loadPresets() async {
    setState(() => _isLoading = true);
    await _presetManager.init();
    setState(() {
      _presets = _presetManager.getAllPresets();
      _isLoading = false;
    });
  }

  List<VIB3Preset> get _filteredPresets {
    if (_searchQuery.isEmpty) {
      return _presets;
    }
    return _presetManager.searchPresets(_searchQuery);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: VIB3Colors.backgroundGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            if (_isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: VIB3Colors.purple),
                ),
              )
            else
              Expanded(
                child: _buildPresetGrid(),
              ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        border: Border(
          bottom: BorderSide(
            color: VIB3Colors.purple.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.photo_library, color: VIB3Colors.purple, size: 24),
          const SizedBox(width: 12),
          const Text(
            'Preset Browser',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          Text(
            '${_presets.length} presets',
            style: TextStyle(
              fontSize: 14,
              color: VIB3Colors.purple.withOpacity(0.8),
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.close),
            color: Colors.white,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search presets...',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          prefixIcon: Icon(Icons.search, color: VIB3Colors.purple),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: VIB3Colors.purple.withOpacity(0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: VIB3Colors.purple.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: VIB3Colors.purple, width: 2),
          ),
        ),
        style: const TextStyle(color: Colors.white),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildPresetGrid() {
    final filteredPresets = _filteredPresets;

    if (filteredPresets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No presets found',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: filteredPresets.length,
      itemBuilder: (context, index) {
        return _buildPresetCard(filteredPresets[index]);
      },
    );
  }

  Widget _buildPresetCard(VIB3Preset preset) {
    return GestureDetector(
      onTap: () => _loadPresetToEngine(preset),
      child: GlassmorphicContainer(
        opacity: 0.15,
        blur: 10,
        borderColor: VIB3Colors.purple.withOpacity(0.3),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail placeholder
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: VIB3Colors.purple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: VIB3Colors.purple.withOpacity(0.3),
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.view_in_ar,
                    size: 48,
                    color: VIB3Colors.purple.withOpacity(0.5),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Preset name
            Text(
              preset.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            if (preset.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                preset.description,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.6),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            const SizedBox(height: 8),

            // Tags
            if (preset.tags.isNotEmpty)
              Wrap(
                spacing: 4,
                children: preset.tags.take(2).map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: VIB3Colors.purple.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        fontSize: 9,
                        color: VIB3Colors.purple,
                      ),
                    ),
                  );
                }).toList(),
              ),

            const SizedBox(height: 8),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${preset.parameters.length} params',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete, size: 16),
                      color: Colors.red.withOpacity(0.7),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      onPressed: () => _deletePreset(preset),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        border: Border(
          top: BorderSide(
            color: VIB3Colors.purple.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _saveCurrentAsPreset,
              icon: const Icon(Icons.save),
              label: const Text('Save Current State'),
              style: ElevatedButton.styleFrom(
                backgroundColor: VIB3Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _loadPresetToEngine(VIB3Preset preset) {
    final paramMap = preset.toParameterMap();
    ref.read(engineProvider.notifier).loadPreset(paramMap);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Loaded preset: ${preset.name}'),
        backgroundColor: VIB3Colors.purple,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _saveCurrentAsPreset() async {
    final controller = TextEditingController();
    final descController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: VIB3Colors.darkNavy,
        title: const Text(
          'Save Preset',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'Preset Name',
                labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: VIB3Colors.purple.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: VIB3Colors.purple),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: InputDecoration(
                labelText: 'Description (optional)',
                labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: VIB3Colors.purple.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: VIB3Colors.purple),
                ),
              ),
              style: const TextStyle(color: Colors.white),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: VIB3Colors.purple),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true && controller.text.isNotEmpty) {
      final engineState = ref.read(engineProvider);
      final preset = VIB3Preset.fromParameters(
        engineState.parameters,
        name: controller.text,
        description: descController.text,
        tags: ['custom'],
      );

      await _presetManager.savePreset(preset);
      await _loadPresets();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Preset saved: ${preset.name}'),
            backgroundColor: VIB3Colors.purple,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _deletePreset(VIB3Preset preset) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: VIB3Colors.darkNavy,
        title: const Text(
          'Delete Preset?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete "${preset.name}"?',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (result == true) {
      await _presetManager.deletePreset(preset.id);
      await _loadPresets();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleted preset: ${preset.name}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _presetManager.dispose();
    super.dispose();
  }
}
