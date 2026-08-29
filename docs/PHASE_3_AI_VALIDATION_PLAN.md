# Phase 3: AI Recognition Validation Plan

**Critical Milestone**: 7-day AI accuracy validation (≥85% required before proceeding)

## Overview

This phase focuses on validating that the Claude Vision API can accurately recognize gacha items with ≥85% confidence before proceeding to full feature development.

## Validation Strategy

### 1. Test Data Preparation

**Test Set Size**: Minimum 100 gacha items from various series
- Diverse rarity levels (N, R, SR, SSR)
- Multiple series (5+ different gacha collections)
- Various lighting conditions and angles
- Different image qualities (HD, phone camera)

**Target Series for Testing**:
- [ ] Popular anime/game series 1
- [ ] Popular anime/game series 2
- [ ] Niche series
- [ ] Recent releases
- [ ] Older collections

### 2. Validation Metrics

**Primary Metric**: Overall Accuracy
- Formula: (Correct Predictions / Total Predictions) × 100
- Target: ≥85%

**Secondary Metrics**:

| Metric | Description | Target |
|--------|-------------|--------|
| Name Accuracy | Correct character/item name recognition | ≥85% |
| Series Accuracy | Correct series/franchise identification | ≥90% |
| Rarity Accuracy | Correct rarity classification (N/R/SR/SSR) | ≥80% |
| Confidence Score | Average AI confidence on correct predictions | ≥0.85 |
| False Positive Rate | Incorrect items recognized as gacha items | <5% |
| Edge Case Handling | Recognition with: damaged, dirty, blurry photos | ≥70% |

### 3. Testing Procedure

**Day 1-2: Baseline Testing**
```
1. Collect and organize 100 test images
2. Document ground truth for each image
3. Run inference on all images
4. Record results and confidence scores
```

**Day 3-4: Error Analysis**
```
1. Categorize errors:
   - Incorrect name (wrong character)
   - Incorrect series
   - Incorrect rarity
   - Total false positives
   
2. Analyze patterns:
   - Similar-looking items that confuse the model
   - Series with similar art styles
   - Rarity misclassifications
```

**Day 5: Refinement & Prompting**
```
1. Analyze top error categories
2. Refine Claude Vision API prompt for better accuracy
3. Add context hints in prompt
4. Re-test on error cases
```

**Day 6-7: Final Validation**
```
1. Run complete test suite again
2. Validate against ≥85% threshold
3. Document final results
4. Create inference guidelines for users
```

### 4. Testing Script

**test/ai_validation/validate_ai.dart**:
```dart
// Pseudocode structure
void main() async {
  final validator = AIValidator();
  
  // Load test images
  final testCases = await loadTestCases('test_data/images');
  
  // Run inference
  final results = await validator.runValidation(testCases);
  
  // Calculate metrics
  final metrics = validator.calculateMetrics(results);
  
  // Report results
  validator.generateReport(metrics);
}
```

### 5. Prompt Optimization

**Current Prompt** (in `lib/services/ai_service.dart`):
```
この画像はガチャの戦利品です。以下の情報を JSON 形式で返してください:
{
  "name": "キャラクター名またはアイテム名",
  "series": "シリーズ名",
  "rarity": "N|R|SR|SSR",
  "confidence": 0.0-1.0,
  "notes": "判定時のメモ（オプション）"
}
```

**Optimization Ideas** (if accuracy < 85%):
- Add examples of N/R/SR/SSR items in prompt
- Request reasoning for confidence score
- Clarify common misidentifications
- Add Japanese context about gacha culture
- Request alternative suggestions if confidence low

### 6. Success Criteria

**Phase 3 Pass**:
- ✅ Overall accuracy ≥85%
- ✅ Name accuracy ≥85%
- ✅ Series accuracy ≥90%
- ✅ Rarity accuracy ≥80%
- ✅ Average confidence ≥0.85
- ✅ False positive rate <5%
- ✅ Test results documented

**Phase 3 Fail** (if metrics not met):
- Refine prompt further or adjust inference logic
- Extend validation period by 3-5 days
- Consider alternative API settings
- May need to focus on specific series accuracy first

### 7. Decision Tree

```
Run AI Validation Tests
    |
    ├─→ Accuracy ≥85%? 
    │   ├─→ YES: Proceed to Phase 4 (Aha Moment Implementation)
    │   └─→ NO: Analyze errors
    │
    └─→ Error Analysis
        ├─→ Systematic issue? (e.g., all items misclassified)
        │   ├─→ YES: Adjust prompt/model settings
        │   └─→ NO: Continue
        │
        └─→ Series-specific issues?
            ├─→ YES: Add series examples to prompt
            └─→ NO: Proceed to Day 5 refinement
```

### 8. Documentation Requirements

**test/ai_validation/RESULTS.md** (to be created):
- Date range: 2024-XX-XX to 2024-XX-XX
- Total images tested: X
- Overall accuracy: X%
- Per-series accuracy breakdown
- Error categories and examples
- Recommended inference guidelines for end users
- Confidence score thresholds for auto-acceptance

### 9. User Acceptance Criteria

Once validation passes (≥85%), document for users:

**High Confidence (≥90%)**:
- Auto-register without review

**Medium Confidence (75-90%)**:
- Show for user review before registration

**Low Confidence (<75%)**:
- Require manual edit/confirmation

### 10. Timeline

| Day | Task | Status |
|-----|------|--------|
| 1-2 | Prepare test data + baseline testing | TODO |
| 3-4 | Error analysis + categorization | TODO |
| 5 | Prompt optimization + re-testing | TODO |
| 6-7 | Final validation + documentation | TODO |

## Rollout Strategy (Post-Validation)

Once ≥85% accuracy is confirmed:

1. **Phase 4-5**: Build 3-tap Aha Moment experience
2. **Phase 6-11**: Implement full feature set (onboarding, paywall, etc.)
3. **Alpha Testing**: Internal team testing with real images
4. **Beta Testing**: Limited user group (50-100 users)
5. **General Release**: Public beta → production

## Risk Mitigation

### If Accuracy Falls Short:

1. **Series-specific focusing**: Instead of 85% overall, aim for 95%+ on popular series
2. **Confidence thresholding**: Only auto-register items with ≥90% confidence
3. **Manual review workflow**: Always allow user override
4. **Iterative improvement**: Plan bi-weekly AI accuracy improvements

### Graceful Degradation:

Even if accuracy <85%, the app can still launch with:
- Manual entry option always available
- AI as "assistance" rather than "automation"
- Clear confidence indicators to users
- Manual review step always available

## Success Definition

Phase 3 is considered successful when:

> "Claude Vision API can identify gacha items with ≥85% overall accuracy across diverse test cases, with consistent performance across multiple series and image conditions."

This enables the 3-tap Aha Moment experience to work reliably for most users without requiring constant manual corrections.
