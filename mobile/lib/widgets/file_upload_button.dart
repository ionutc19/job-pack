import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
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
  String? _errorMessage;

  Future<bool> _showConsentDialog() async {
    final l = AppLocalizations.of(context);
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.upload_file, color: Theme.of(ctx).colorScheme.primary),
                const SizedBox(width: 10),
                Text(
                  l.fileConsentTitle,
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _ConsentRow(icon: Icons.folder_open, text: l.fileConsentPicker),
            const SizedBox(height: 12),
            _ConsentRow(icon: Icons.touch_app_outlined, text: l.fileConsentSelected),
            const SizedBox(height: 12),
            _ConsentRow(icon: Icons.timer_outlined, text: l.fileConsentTemporary),
            const SizedBox(height: 12),
            _ConsentRow(icon: Icons.delete_outline, text: l.fileConsentNoStorage),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.pop(ctx, true),
                icon: const Icon(Icons.file_open_outlined, size: 18),
                label: Text(l.fileConsentContinue),
              ),
            ),
          ],
        ),
      ),
    );
    return result == true;
  }

  static String _mimeType(String filename) {
    final ext = filename.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return 'application/pdf';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'txt':
        return 'text/plain';
      default:
        return 'application/octet-stream';
    }
  }

  Future<void> _pickAndUpload() async {
    final l = AppLocalizations.of(context);
    final consented = await _showConsentDialog();
    if (!consented) return;

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
        setState(() {
          _errorMessage = AppLocalizations.of(context).fileTooLarge;
        });
      }
      return;
    }

    setState(() {
      _uploading = true;
      _fileName = file.name;
      _errorMessage = null;
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
          contentType: MediaType.parse(_mimeType(file.name)),
        ));

      final response = await request.send();
      final body = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(body);
        widget.targetController.text = data['text'] as String;
        setState(() => _errorMessage = null);
      } else {
        String detail;
        try {
          final data = jsonDecode(body);
          detail = data['detail'] as String? ?? l.fileUploadError;
        } catch (_) {
          detail = l.fileUploadError;
        }
        if (mounted) {
          setState(() {
            _fileName = null;
            _errorMessage = detail;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _fileName = null;
          _errorMessage = '${AppLocalizations.of(context).error}: $e';
        });
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  void _clearFile() {
    setState(() {
      _fileName = null;
      _errorMessage = null;
    });
    widget.targetController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_fileName != null && !_uploading)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.insert_drive_file_outlined,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _fileName!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton.icon(
                  onPressed: _pickAndUpload,
                  icon: const Icon(Icons.swap_horiz, size: 16),
                  label: Text(l.replaceFile),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    textStyle: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
                const SizedBox(width: 4),
                TextButton.icon(
                  onPressed: _clearFile,
                  icon: const Icon(Icons.close, size: 16),
                  label: Text(l.removeFile),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red.shade600,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    textStyle: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
              ],
            ),
          )
        else
          OutlinedButton.icon(
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
          ),
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              _errorMessage!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
          ),
      ],
    );
  }
}

class _ConsentRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ConsentRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.green.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
