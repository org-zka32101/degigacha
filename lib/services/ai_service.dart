import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../data/models/gacha_item_model.dart';

/// Claude Vision APIを使用したガチャアイテムの AI 判定サービス
class AIService {
  static const String _anthropicApiUrl = 'https://api.anthropic.com/v1/messages';
  static const String _model = 'claude-3-5-sonnet-20241022';
  static const int _timeoutSeconds = 10;
  static const int _maxRetries = 3;

  final String _apiKey;
  final Logger _logger = Logger();

  AIService({required String apiKey}) : _apiKey = apiKey;

  /// ガチャアイテムを画像から AI 判定
  ///
  /// [imagePath]: 画像ファイルパス
  ///
  /// Returns: AI 判定結果（AIResult）
  /// Throws: AIServiceException
  Future<AIResult> identifyGachaItem(String imagePath) async {
    try {
      // 画像ファイルを読み込み
      final imageFile = File(imagePath);
      if (!imageFile.existsSync()) {
        throw AIServiceException('画像ファイルが見つかりません: $imagePath');
      }

      final imageBytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      // MIME タイプを決定
      final mimeType = _getMimeType(imagePath);

      // API 呼び出し（リトライあり）
      late AIResult result;
      for (int attempt = 0; attempt < _maxRetries; attempt++) {
        try {
          result = await _callClaudeVision(base64Image, mimeType);
          break;
        } catch (e) {
          _logger.w('AI判定リトライ ${attempt + 1}/$_maxRetries: $e');
          if (attempt == _maxRetries - 1) rethrow;
          await Future.delayed(Duration(seconds: (attempt + 1) * 2));
        }
      }

      _logger.i('AI判定成功: ${result.name} (信頼度: ${result.confidence})');
      return result;
    } catch (e) {
      _logger.e('AI判定エラー: $e');
      throw AIServiceException('AI判定に失敗しました: $e');
    }
  }

  /// Claude Vision API を呼び出し
  Future<AIResult> _callClaudeVision(
    String base64Image,
    String mimeType,
  ) async {
    final request = _buildRequest(base64Image, mimeType);

    final response = await http
        .post(
          Uri.parse(_anthropicApiUrl),
          headers: _getHeaders(),
          body: jsonEncode(request),
        )
        .timeout(const Duration(seconds: _timeoutSeconds));

    if (response.statusCode != 200) {
      throw AIServiceException(
        'API呼び出し失敗: ${response.statusCode} - ${response.body}',
      );
    }

    return _parseResponse(response.body);
  }

  /// リクエストボディを構築
  Map<String, dynamic> _buildRequest(String base64Image, String mimeType) {
    return {
      'model': _model,
      'max_tokens': 1024,
      'messages': [
        {
          'role': 'user',
          'content': [
            {
              'type': 'image',
              'source': {
                'type': 'base64',
                'media_type': mimeType,
                'data': base64Image,
              },
            },
            {
              'type': 'text',
              'text': '''この画像はガチャの戦利品です。以下の情報を JSON 形式で返してください:
{
  "name": "キャラクター名またはアイテム名",
  "series": "シリーズ名",
  "rarity": "N|R|SR|SSR",
  "confidence": 0.0-1.0,
  "notes": "判定時のメモ（オプション）"
}

必ず有効な JSON を返してください。判定できない場合も JSON 形式で confidence を 0 にして返してください。''',
            },
          ],
        },
      ],
    };
  }

  /// HTTP ヘッダーを構築
  Map<String, String> _getHeaders() {
    return {
      'x-api-key': _apiKey,
      'anthropic-version': '2023-06-01',
      'content-type': 'application/json',
    };
  }

  /// レスポンスを解析
  AIResult _parseResponse(String body) {
    try {
      final response = jsonDecode(body) as Map<String, dynamic>;

      // content 配列から text を取得
      final content = response['content'] as List<dynamic>;
      final textContent = content.firstWhere(
        (item) => item['type'] == 'text',
        orElse: () => throw AIServiceException('テキスト応答が見つかりません'),
      ) as Map<String, dynamic>;

      final text = textContent['text'] as String;

      // JSON を抽出（マークダウンコードブロック対応）
      String jsonText = text;
      if (text.contains('```json')) {
        final start = text.indexOf('```json') + 7;
        final end = text.indexOf('```', start);
        jsonText = text.substring(start, end).trim();
      } else if (text.contains('```')) {
        final start = text.indexOf('```') + 3;
        final end = text.indexOf('```', start);
        jsonText = text.substring(start, end).trim();
      }

      // JSON をパース
      final result = jsonDecode(jsonText) as Map<String, dynamic>;

      // Rarity enum に変換
      final rarityValue = (result['rarity'] as String).toUpperCase();
      final rarity = Rarity.values.firstWhere(
        (r) => r.value == rarityValue,
        orElse: () => Rarity.n,
      );

      return AIResult(
        name: result['name'] as String? ?? '不明',
        series: result['series'] as String? ?? '不明',
        rarity: rarity,
        confidence: (result['confidence'] as num?)?.toDouble() ?? 0.0,
        notes: result['notes'] as String?,
      );
    } catch (e) {
      throw AIServiceException('レスポンス解析エラー: $e');
    }
  }

  /// MIME タイプを取得
  String _getMimeType(String filePath) {
    final ext = filePath.toLowerCase().split('.').last;
    return switch (ext) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'gif' => 'image/gif',
      'webp' => 'image/webp',
      _ => 'image/jpeg', // デフォルト
    };
  }
}

/// AI Service の例外クラス
class AIServiceException implements Exception {
  final String message;
  AIServiceException(this.message);

  @override
  String toString() => 'AIServiceException: $message';
}
