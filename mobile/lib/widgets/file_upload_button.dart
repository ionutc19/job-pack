import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import '../config/app_config.dart';
import '../l10n/app_localizations.dart';
import '../services/user_identity.dart';

class FileUploadButton extends StatefulWidget {
  final String label;
  final TextEditingController targetController;

  const FileUploadButton({
    super.key,
    required this.label,
    required this.targetController,
  });

  @override
  State<FileUploadButton> createState() => _FileUploadButtonState();
}

class _FileUploadButtonState extends State<FileUploadButton> {
  String? _fileName;
  bool _uploading = false;

  Future<void> _pickAndUpload() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'txt'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;

    if (file.bytes == null) return;

    if (file.size > 10 * 1024 * 1024) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).fileTooLarge)),
        );
      }
      return;
    }

    setState(() {
      _uploading = true;
      _fileName = file.name;
    });

    try {
      final identity = UserIdentity();
      final uri = Uri.parse('${AppConfig.baseUrl}/api/files/extract-text');
      final request = http.MultipartRequest('POST', uri)
        ..headers['X-User-Id'] = identity.userId
        ..headers['X-Device-Id'] = identity.deviceId
        ..files.add(http.MultipartFile.fromBytes(
          'file',
          file.bytes!,
          filename: file.name,
        ));

      final response = await request.send();
      final body = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(body);
        widget.targetController.text = data['text'] as String;
      } else {
        final data = jsonDecode(body);
        final detail = data['detail'] ?? 'Upload failed';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$detail')),
          );
        }
        setState(() => _fileName = null);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context).error}: $e')),
        );
      }
      setState(() => _fileName = null);
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  void _clearFile() {
    setState(() => _fileName = null);
    widget.targetController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    if (_fileName != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.insert_drive_file_outlined, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _fileName!,
                style: Theme.of(context).textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: _clearFile,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: l.removeFile,
            ),
          ],
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: _uploading ? null : _pickAndUpload,
      icon: _uploading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.upload_file, size: 18),
      label: Text(_uploading ? l.extractingText : widget.label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}
