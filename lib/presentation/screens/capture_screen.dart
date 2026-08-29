import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

/// 撮影・AI判定画面
///
/// 「Aha Moment」: 3タップの体験フロー
/// 1. 撮影：ガチャアイテムを撮影
/// 2. 判定：Claude Vision APIでAI判定
/// 3. 自動登録：確認1タップでコレクション登録完了
class CaptureScreen extends ConsumerStatefulWidget {
  const CaptureScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends ConsumerState<CaptureScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _selectedImage;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('アイテムを撮影'),
        centerTitle: true,
      ),
      body: _selectedImage == null
          ? _buildCameraView(context)
          : _buildJudgmentView(context),
    );
  }

  /// カメラ撮影インターフェース
  Widget _buildCameraView(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Instructions
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.camera_alt,
                  size: 60,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'ガチャアイテムを撮影',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'アイテムが画面中央に映るように撮影してください',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color:
                          Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        // Camera Buttons
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _capturePhoto,
                  icon: const Icon(Icons.camera),
                  label: const Text('撮影'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.primary,
                    foregroundColor:
                        Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: _selectFromGallery,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('ギャラリーから選択'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// AI判定結果表示・登録確認インターフェース
  Widget _buildJudgmentView(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Image Preview
          Container(
            width: double.infinity,
            height: 300,
            color: Colors.grey[300],
            child: Image.network(
              _selectedImage!.path,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(Icons.error),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // TODO: Display AI judgment results
          if (_isProcessing)
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('AI判定中...'),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judgment Result Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'アイテム名',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'サンプルキャラクター',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium,
                                  ),
                                ],
                              ),
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondaryContainer,
                                  borderRadius:
                                      BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'SSR',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildDetailRow(
                            context,
                            'シリーズ',
                            'サンプルシリーズ',
                          ),
                          const SizedBox(height: 8),
                          _buildDetailRow(
                            context,
                            '信頼度',
                            '92%',
                          ),
                          const SizedBox(height: 8),
                          _buildDetailRow(
                            context,
                            '状態',
                            '新規',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Confidence Indicator
                  Text(
                    'AI判定信頼度',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: 0.92,
                    minHeight: 8,
                  ),
                  const SizedBox(height: 24),

                  // Manual Edit Option
                  OutlinedButton.icon(
                    onPressed: () {
                      // Show edit dialog
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('情報を編集'),
                  ),
                  const SizedBox(height: 12),

                  // Confirm Registration Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _confirmRegistration,
                      icon: const Icon(Icons.check_circle),
                      label: const Text('コレクションに追加'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .primary,
                        foregroundColor: Theme.of(context)
                            .colorScheme
                            .onPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Retake Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedImage = null;
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('再撮影'),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }

  Future<void> _capturePhoto() async {
    final photo = await _imagePicker.pickImage(
      source: ImageSource.camera,
    );
    if (photo != null) {
      setState(() {
        _selectedImage = photo;
      });
      _performAIJudgment();
    }
  }

  Future<void> _selectFromGallery() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
      _performAIJudgment();
    }
  }

  Future<void> _performAIJudgment() async {
    setState(() {
      _isProcessing = true;
    });

    // TODO: Call AI Service to judge the image
    // final result = await ref.read(aiServiceProvider).identifyGachaItem(
    //       _selectedImage!.path,
    //     );

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _confirmRegistration() async {
    // TODO: Add the item to collection in Firestore
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('コレクションに追加されました！'),
          duration: Duration(seconds: 2),
        ),
      );

      // Return to home
      Navigator.of(context).pop();
    }
  }
}
