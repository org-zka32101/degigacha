import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/gacha_item_model.dart';
import '../../domain/usecases/gacha_usecase.dart';
import '../../services/storage_service.dart';
import '../riverpod/auth_notifier.dart';
import '../riverpod/providers.dart';

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
  AIResult? _aiResult;
  String? _errorMessage;

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
            child: Image.file(
              File(_selectedImage!.path),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Icon(
                    Icons.error,
                    size: 40,
                    color: Theme.of(context).colorScheme.error,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // エラーメッセージ表示
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            )
          else if (_isProcessing)
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
          else if (_aiResult != null)
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
                                    _aiResult!.name,
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
                                  color: _getRarityColor(
                                    _aiResult!.rarity,
                                    context,
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _aiResult!.rarity.value,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildDetailRow(
                            context,
                            'シリーズ',
                            _aiResult!.series,
                          ),
                          const SizedBox(height: 8),
                          _buildDetailRow(
                            context,
                            '信頼度',
                            '${(_aiResult!.confidence * 100).toStringAsFixed(0)}%',
                          ),
                          if (_aiResult!.notes != null) ...[
                            const SizedBox(height: 8),
                            _buildDetailRow(
                              context,
                              'メモ',
                              _aiResult!.notes!,
                            ),
                          ],
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
                    value: _aiResult!.confidence,
                    minHeight: 8,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getConfidenceLabel(_aiResult!.confidence),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Manual Edit Option
                  OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Show edit dialog
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
                      onPressed: _isProcessing
                          ? null
                          : _confirmRegistration,
                      icon: const Icon(Icons.check_circle),
                      label: const Text('コレクションに追加'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context)
                                .colorScheme
                                .primary,
                        foregroundColor:
                            Theme.of(context)
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
                      onPressed: _isProcessing
                          ? null
                          : () {
                              setState(() {
                                _selectedImage = null;
                                _aiResult = null;
                                _errorMessage = null;
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

  /// レアリティに対応する色を取得
  Color _getRarityColor(Rarity rarity, BuildContext context) {
    return switch (rarity) {
      Rarity.ssr => const Color(0xFFFFD700), // Gold
      Rarity.sr => const Color(0xFFC0C0C0), // Silver
      Rarity.r => const Color(0xFFCD7F32), // Bronze
      Rarity.n => Colors.grey, // Gray
    };
  }

  /// 信頼度のラベルを取得
  String _getConfidenceLabel(double confidence) {
    if (confidence >= 0.95) return '非常に高い信頼度';
    if (confidence >= 0.85) return '高い信頼度';
    if (confidence >= 0.75) return '中程度の信頼度';
    return 'レビュー推奨';
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
      _errorMessage = null;
    });

    try {
      // AI Service で画像を判定
      final aiService = ref.read(aiServiceProvider);
      final result = await aiService.identifyGachaItem(_selectedImage!.path);

      if (mounted) {
        setState(() {
          _aiResult = result;
          _isProcessing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'AI判定に失敗しました: $e';
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _confirmRegistration() async {
    if (_aiResult == null) {
      _showErrorSnackBar('AI判定結果が見つかりません');
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final authState = ref.read(authNotifierProvider);
      final userId = authState.user?.uid;

      if (userId == null) {
        _showErrorSnackBar('ユーザーが見つかりません');
        return;
      }

      // Firebase Storage にアップロード
      final storageService = StorageService();
      final imageUrl = await storageService.uploadGachaItemImage(
        userId: userId,
        imagePath: _selectedImage!.path,
      );

      // Gacha Usecase でアイテムを登録
      final gachaUsecase = ref.read(gachaUsecaseProvider);
      final itemId = await gachaUsecase.registerItemFromImage(
        userId: userId,
        imagePath: _selectedImage!.path,
        imageUrl: imageUrl,
      );

      if (mounted) {
        setState(() {
          _isProcessing = false;
        });

        // 成功メッセージを表示
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✅ コレクションに追加されました！'),
            duration: const Duration(seconds: 2),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );

        // ホーム画面に戻る
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          context.go('/');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _errorMessage = 'アイテム登録に失敗しました: $e';
        });
        _showErrorSnackBar(_errorMessage!);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
