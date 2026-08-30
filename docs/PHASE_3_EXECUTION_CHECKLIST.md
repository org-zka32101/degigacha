# Phase 3: AI Validation Testing - Execution Checklist

**Status**: 🔄 READY FOR EXECUTION  
**Date Created**: 2026-08-30  
**Critical Gate**: Must achieve ≥85% accuracy to proceed to Phase 6+ full features

---

## ✅ Pre-Execution Checklist

### Infrastructure Ready (✅ Complete)
- [x] AI Validation test suite created (`test/ai_validation/ai_validator_test.dart`)
- [x] Test data manifest template ready (`test/ai_validation/test_data_manifest.json`)
- [x] Results documentation template ready (`test/ai_validation/RESULTS_TEMPLATE.md`)
- [x] AIService implementation complete (`lib/services/ai_service.dart`)
- [x] All dependencies in `pubspec.yaml`
- [x] Execution guide documented (`docs/PHASE_3_EXECUTION_GUIDE.md`)

### Code Ready (✅ Complete)
- [x] Phase 6 Preview implementation complete
- [x] Phase 6 tests pass (65+ test cases)
- [x] CaptureScreen working with AI judgment
- [x] Firebase Storage image uploads functional
- [x] CI/CD pipeline configured
- [x] HomeScreen integration complete

---

## 📋 Data Collection Phase (Days 1-3)

### Step 1: Image Collection Requirements

**Target**: 100-150+ gacha item images with ground truth

```
Images Needed:
├── By Quality Level:
│   ├── High quality (50+ images)
│   │   - Studio lighting
│   │   - Clear focus
│   │   - Good angle
│   ├── Blurry (20+ images)
│   │   - Out of focus
│   │   - Motion blur
│   │   - Partial focus
│   ├── Damaged (15+ images)
│   │   - Worn/used
│   │   - Discolored
│   │   - Scratched
│   └── Poor lighting (15+ images)
│       - Dim room
│       - Shadow areas
│       - Backlit
└── By Rarity Distribution:
    ├── Normal (N): ~25-30 images
    ├── Rare (R): ~25-30 images
    ├── Super Rare (SR): ~25-30 images
    └── Super Super Rare (SSR): ~20-25 images
```

**Collection Methods**:
- [ ] Take photos of actual figures
- [ ] Use existing collection images
- [ ] Screenshot from official sources
- [ ] Download from manufacturer websites
- [ ] Use AI-generated images (labeled as such)

### Step 2: Organize Test Images

```bash
mkdir -p test/ai_validation/test_images/{normal,blurry,damaged,poor_lighting}
```

**File Naming Convention**:
```
sample_001_ssr_normal.jpg
sample_025_sr_blurry.jpg
sample_050_r_damaged.jpg
sample_100_n_poor_lighting.jpg

Format: sample_{ID}_{rarity}_{condition}.jpg
```

### Step 3: Create Ground Truth Manifest

**File**: `test/ai_validation/test_data_manifest.json`

```json
{
  "testImages": [
    {
      "id": "001",
      "imagePath": "test/ai_validation/test_images/normal/sample_001.jpg",
      "expectedName": "Fischl (Winter)",
      "expectedSeries": "Genshin Impact",
      "expectedRarity": "SSR",
      "minConfidence": 0.80,
      "imageCondition": "normal",
      "notes": "High quality image, clear item, studio lighting"
    },
    {
      "id": "002",
      "imagePath": "test/ai_validation/test_images/blurry/sample_025.jpg",
      "expectedName": "Nahida",
      "expectedSeries": "Genshin Impact",
      "expectedRarity": "SSR",
      "minConfidence": 0.70,
      "imageCondition": "blurry",
      "notes": "Out of focus, but item identifiable"
    }
  ],
  "totalImages": 0,
  "collectionDate": "2026-08-30",
  "collector": "your_name"
}
```

---

## 🧪 Execution Phase (Days 4-6)

### Step 4: Verify Setup

- [ ] Flutter SDK installed and working
- [ ] `pubspec.yaml` dependencies resolved (`flutter pub get`)
- [ ] Firebase configured with valid API key
- [ ] Claude Vision API credentials available
- [ ] All test images organized and named correctly
- [ ] `test_data_manifest.json` populated with 100+ entries

### Step 5: Run Initial Test Batch

```bash
# Single test run with logging
flutter test test/ai_validation/ai_validator_test.dart -v

# Expected output:
# ✅ Loaded 100+ images from manifest
# ✅ Started AI validation run
# 🔄 Processing: sample_001_ssr_normal.jpg
#    Predicted: Fischl (Winter) | Genshin Impact | SSR
#    Expected:  Fischl (Winter) | Genshin Impact | SSR
#    ✅ MATCH (confidence: 0.95)
# ...
# 📊 Results saved to: test/ai_validation/test_results/
```

### Step 6: Monitor Progress

**Daily Tasks (Days 4-6)**:
- [ ] Run test batch each day
- [ ] Document any errors or anomalies
- [ ] Check API usage and rate limits
- [ ] Review confidence distributions
- [ ] Note any patterns in failures

**Tracking**:
```
Day 4: Run tests on 30 images
       Status: ✅/❌ (note failures)
       
Day 5: Run tests on 35 images
       Status: ✅/❌ (check for patterns)
       
Day 6: Run tests on 35 images
       Status: ✅/❌ (final batch)
```

---

## 📊 Analysis Phase (Days 5-7)

### Step 7: Collect Results

Results automatically saved to:
```
test/ai_validation/test_results/
├── report.json              # Detailed results
├── metrics.json             # Aggregated metrics
└── errors.log               # Any errors/warnings
```

### Step 8: Analyze Results

**Create**: `test/ai_validation/RESULTS.md` (from RESULTS_TEMPLATE.md)

```markdown
# Phase 3 Validation Results

## Executive Summary
- Total images tested: 123
- Correct predictions: 107
- **Overall accuracy: 87.0%** ✅ (Target: ≥85%)

## Detailed Metrics

### Accuracy by Category
- Series Accuracy: 91.5% ✅ (Target: ≥90%)
- Rarity Accuracy: 82.3% ✅ (Target: ≥80%)
- Name Accuracy: 87.0% ✅ (Target: ≥85%)

### Confidence Analysis
- Average Confidence: 0.88 ✅ (Target: ≥0.85)
- False Positive Rate: 2.4% ✅ (Target: <5%)

## Error Analysis
[Detail specific failures and patterns]

## Recommendations
[Any refinements needed]
```

### Step 9: Decision Point

**If Accuracy ≥85% (PASS)**:
```
✅ PHASE 3 PASSED
   Go/No-Go: ✅ PROCEED
   Status: AI system production-ready
   Next: Begin Phase 6+ full implementation
   Timeline: Can start immediately
```

**If Accuracy <85% (FAIL)**:
```
❌ PHASE 3 FAILED
   Go/No-Go: ❌ REFINE & RETRY
   Analysis: [Identify error patterns]
   Refinement: [Update prompt/add test cases]
   Retry Timeline: 3-7 additional days
```

---

## 🎯 Success Criteria Checklist

### Must-Pass Thresholds (All Required)
- [ ] Overall Accuracy ≥85%
- [ ] Series Accuracy ≥90%
- [ ] Rarity Accuracy ≥80%
- [ ] Average Confidence ≥0.85
- [ ] False Positive Rate <5%

### Nice-to-Have Metrics
- [ ] Per-series breakdown
- [ ] Rarity-level breakdown
- [ ] Confidence distribution chart
- [ ] Image condition impact analysis

### Documentation Complete
- [ ] test_data_manifest.json populated
- [ ] RESULTS.md completed
- [ ] Error analysis documented
- [ ] Recommendations provided

---

## 🚨 Troubleshooting

### Issue: "Cannot connect to AI API"
**Solutions**:
- [ ] Verify API key in Firebase Remote Config
- [ ] Check network connectivity
- [ ] Test single image manually first
- [ ] Review Firebase logs for errors

### Issue: "Image file not found"
**Solutions**:
- [ ] Verify image paths in manifest are correct
- [ ] Check paths are relative to project root
- [ ] Ensure images are in test/ai_validation/test_images/
- [ ] List images: `ls -R test/ai_validation/test_images/`

### Issue: "Tests running very slowly"
**Expected**: 2-5 seconds per image × 100 images = 3-8 minutes total
**Solutions**:
- [ ] Run during off-peak hours
- [ ] Split into smaller batches
- [ ] Check API rate limits
- [ ] Monitor Firebase usage

### Issue: "Very low accuracy (<60%)"
**Possible causes**:
- [ ] Images are too niche/obscure
- [ ] Ground truth data is incorrect
- [ ] Images don't represent items clearly
- [ ] Series names don't match training data
**Actions**:
- [ ] Verify ground truth accuracy
- [ ] Test with different image samples
- [ ] Consider prompt refinement
- [ ] Review AI response format

---

## 📞 Support Resources

### Documentation
- `docs/PHASE_3_EXECUTION_GUIDE.md` - Step-by-step execution
- `docs/PHASE_3_AI_VALIDATION_PLAN.md` - Detailed strategy
- `test/ai_validation/RESULTS_TEMPLATE.md` - Results format

### Code References
- `lib/services/ai_service.dart` - Claude Vision integration
- `test/ai_validation/ai_validator_test.dart` - Test suite
- `lib/data/models/gacha_item_model.dart` - Data models

### Tools
- Firebase Console: Monitor API usage
- VS Code: Edit manifest.json
- Terminal: Run test commands
- GitHub: Track results/PRs

---

## 📅 Timeline

```
Day 1-2: Collect & organize 100+ images
Day 3:   Create ground truth manifest
Day 4:   Run first batch (30 images)
Day 5:   Run second batch (35 images)
Day 6:   Run final batch (35 images)
Day 7:   Analyze results & make decision

Total: 7 days for validation
```

---

## ✨ What Success Looks Like

### ✅ Phase 3 PASS Scenario
```
🎉 Validation Complete!
   Overall Accuracy: 87.3% ✅
   Series Accuracy: 92.1% ✅
   Rarity Accuracy: 84.8% ✅
   False Positive Rate: 1.8% ✅
   
Status: AI recognition system is production-ready
Next: Proceed to Phase 6+ development
```

### ❌ Phase 3 FAIL Scenario
```
⚠️  Validation Results Below Threshold
   Overall Accuracy: 78.5% ❌
   Series Accuracy: 85.3% ❌
   Rarity Accuracy: 72.1% ❌
   
Analysis:
- Series confusion on similar franchises
- Low rarity confidence on N/R cards
- False positives on game-like items

Recommendation:
- Refine Claude Vision prompt with more detail
- Focus on rarity classification improvement
- Collect more N/R card samples
- Retry in 5 days with updated prompt
```

---

## 🔄 Next Steps

### Before Starting Phase 3:
1. [ ] Read `PHASE_3_EXECUTION_GUIDE.md` completely
2. [ ] Prepare image collection plan
3. [ ] Set up test images directory
4. [ ] Review success criteria
5. [ ] Schedule 7-day testing window

### During Phase 3:
1. [ ] Collect and organize images
2. [ ] Create ground truth manifest
3. [ ] Run daily test batches
4. [ ] Document progress
5. [ ] Monitor metrics

### After Phase 3:
1. [ ] Analyze results
2. [ ] Write RESULTS.md
3. [ ] Make go/no-go decision
4. [ ] If PASS: Begin Phase 6+ immediately
5. [ ] If FAIL: Refine and retry

---

## 💡 Tips for Success

### Image Collection
- ✅ DO: Use diverse real items
- ✅ DO: Include manufacturer variations
- ✅ DO: Vary image quality deliberately
- ❌ DON'T: Use AI-generated images
- ❌ DON'T: Cherry-pick only good images

### Ground Truth Accuracy
- ✅ DO: Verify item names carefully
- ✅ DO: Check series against official sources
- ✅ DO: Confirm rarity ratings
- ✅ DO: Document source/notes
- ❌ DON'T: Guess on uncertain items

### Test Execution
- ✅ DO: Run tests during off-peak hours
- ✅ DO: Monitor API usage
- ✅ DO: Check logs for errors
- ✅ DO: Save results daily
- ❌ DON'T: Manually edit AI responses

---

**Checklist Version**: 1.0  
**Last Updated**: 2026-08-30  
**Author**: Claude (AI)  
**Status**: Ready for Execution  
**Critical Gate**: Phase 3 determines Phase 6+ viability

**Ready to start Phase 3? Begin with image collection!** 📸

