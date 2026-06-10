import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../services/app_strings.dart';

class FileScreen extends StatefulWidget {
  const FileScreen({super.key});

  @override
  State<FileScreen> createState() => _FileScreenState();
}

class _FileScreenState extends State<FileScreen> {
  final List<Map<String, dynamic>> _recentFiles = [];
  String? _selectedFilePath;
  String? _selectedFileContent;
  String? _selectedFileName;

  @override
  void initState() {
    super.initState();
    _loadRecentFiles();
  }

  Future<void> _loadRecentFiles() async {
    final dir = await _getFilesDir();
    if (await dir.exists()) {
      final files = await dir.list().toList();
      setState(() {
        _recentFiles.clear();
        for (final file in files.take(20)) {
          if (file is File) {
            final stat = file.statSync();
            _recentFiles.add({
              'name': file.path.split('\\').last.split('/').last,
              'path': file.path,
              'size': stat.size,
              'modified': stat.modified,
            });
          }
        }
      });
    }
  }

  Future<Directory> _getFilesDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDir.path}/opencode_files');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'dart', 'py', 'js', 'ts', 'rs', 'go', 'java', 'kt',
        'swift', 'c', 'cpp', 'h', 'cs', 'rb', 'php', 'html',
        'css', 'scss', 'json', 'yaml', 'xml', 'md', 'txt',
        'sql', 'sh', 'yaml', 'toml', 'gradle', 'cfg', 'ini',
      ],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      final name = result.files.single.name;

      setState(() {
        _selectedFilePath = result.files.single.path;
        _selectedFileContent = content;
        _selectedFileName = name;
        _recentFiles.insert(0, {
          'name': name,
          'path': result.files.single.path,
          'size': file.statSync().size,
          'modified': file.statSync().modified,
        });
      });
    }
  }

  Future<void> _saveToDevice() async {
    if (_selectedFilePath == null) return;
    try {
      final dir = await _getFilesDir();
      final dest = File('${dir.path}/$_selectedFileName');
      await dest.writeAsString(_selectedFileContent!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved to ${dest.path}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e')),
        );
      }
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _getFileIcon(String name) {
    final ext = name.split('.').last.toLowerCase();
    switch (ext) {
      case 'dart': return '🎯';
      case 'py': return '🐍';
      case 'js': case 'ts': return '📜';
      case 'rs': return '🦀';
      case 'go': return '🔷';
      case 'java': return '☕';
      case 'kt': return '📱';
      case 'swift': return '🍎';
      case 'c': case 'cpp': case 'h': return '⚙️';
      case 'html': return '🌐';
      case 'css': return '🎨';
      case 'json': return '📋';
      case 'yaml': case 'yml': return '⚡';
      case 'md': return '📝';
      case 'sql': return '🗄️';
      default: return '📄';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const s = AppStrings();

    if (_selectedFileContent != null) {
      return Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Text(_getFileIcon(_selectedFileName!)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(_selectedFileName!,
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.save_outlined),
              tooltip: s.saveToDevice,
              onPressed: _saveToDevice,
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() {
                _selectedFileContent = null;
                _selectedFileName = null;
                _selectedFilePath = null;
              }),
            ),
          ],
        ),
        body: Container(
          color: theme.brightness == Brightness.dark
              ? const Color(0xFF1E1E1E)
              : const Color(0xFFF8F8F8),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: SelectableText(
              _selectedFileContent!,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                height: 1.5,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(s.files),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_open_outlined),
            tooltip: s.openFile,
            onPressed: _pickFile,
          ),
        ],
      ),
      body: _recentFiles.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.folder_open, size: 64,
                      color: theme.colorScheme.outlineVariant),
                  const SizedBox(height: 16),
                  Text(s.noFiles,
                      style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.outline)),
                  const SizedBox(height: 8),
                  FilledButton.tonalIcon(
                    onPressed: _pickFile,
                    icon: const Icon(Icons.file_open),
                    label: Text(s.openFile),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(8),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Text(s.recentFiles,
                      style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.outline,
                          fontWeight: FontWeight.w600)),
                ),
                ...List.generate(_recentFiles.length, (i) {
                  final file = _recentFiles[i];
                  return ListTile(
                    leading: Text(_getFileIcon(file['name']),
                        style: const TextStyle(fontSize: 24)),
                    title: Text(file['name'],
                        overflow: TextOverflow.ellipsis),
                    subtitle: Text(
                      '${_formatFileSize(file['size'])} • ${file['name'].split('.').last}',
                      style: theme.textTheme.bodySmall,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      try {
                        final f = File(file['path']);
                        final content = await f.readAsString();
                        setState(() {
                          _selectedFileContent = content;
                          _selectedFileName = file['name'];
                          _selectedFilePath = file['path'];
                        });
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      }
                    },
                  );
                }),
              ],
            ),
    );
  }
}
