import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class ImagePickerWidget extends StatelessWidget {
  final File? imageFile;
  final String? imageUrl;
  final bool viewOnly;
  final Function(File) onImagePicked;
  final VoidCallback onImageRemoved;
  final double height, width;

  const ImagePickerWidget({
    super.key,
    required this.imageFile,
    this.imageUrl,
    this.viewOnly = false,
    required this.onImagePicked,
    required this.onImageRemoved,
    required this.height,
    required this.width,
  });

  Future<void> _pickImage(BuildContext context) async {
    if (viewOnly) return;

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final pickedFile = File(result.files.single.path!);
        onImagePicked(pickedFile);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Text('Erro ao selecionar imagem: $e'),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final bool hasImage =
        imageFile != null || (imageUrl != null && imageUrl!.isNotEmpty);

    return Column(
      children: [
        GestureDetector(
          onTap: viewOnly ? null : () => _pickImage(context),
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outlineVariant,
                width: 2,
                strokeAlign: BorderSide.strokeAlignInside,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: hasImage ? _buildImage() : _buildPlaceholder(theme),
            ),
          ),
        ),
        if (hasImage && !viewOnly) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filledTonal(
                onPressed: () => _pickImage(context),
                icon: const Icon(Icons.edit, size: 18),
                tooltip: 'Alterar foto',
                iconSize: 18,
                padding: const EdgeInsets.all(8),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                onPressed: onImageRemoved,
                icon: const Icon(Icons.delete, size: 18),
                tooltip: 'Remover foto',
                iconSize: 18,
                padding: const EdgeInsets.all(8),
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.errorContainer,
                  foregroundColor: theme.colorScheme.onErrorContainer,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildImage() {
    if (imageFile != null) {
      return Image.file(imageFile!, width: 300, height: 250, fit: BoxFit.cover);
    }

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        width: 300,
        height: 250,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) => progress == null
            ? child
            : const Center(child: CircularProgressIndicator()),
        errorBuilder: (context, error, stack) =>
            const Icon(Icons.error_outline, size: 48),
      );
    }

    return Container();
  }

  Widget _buildPlaceholder(ThemeData theme) {
    if (viewOnly) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_outline,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          Text(
            'Sem foto',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate_outlined,
          size: 40,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 8),
        Text(
          'Adicionar\nFoto',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
