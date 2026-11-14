# Spotify Video-First Discovery Feed
## A/B Testing Experiment – Executive Summary

### 1. Objective

The Spotify Podcasts Growth team conducted an A/B test to evaluate whether introducing video-first podcast discovery cards with muted autoplay previews could improve podcast engagement compared with the existing static cover-art cards.

### 2. Experiment Design

- Total randomized users: 2,000
- Control group: 1,015 users
- Treatment group: 985 users
- Experiment duration: 14 days
- Randomization unit: User_ID
- Allocation: Approximately 50/50
- Primary metric: Average daily podcast listening minutes per randomized user.
- Significance level: 5%

The analysis followed an intention-to-treat approach by retaining randomized users in their originally assigned groups.

### 3. Primary Metric Results

| Metric | Control | Treatment |
|---|---:|---:|
| Average daily podcast minutes | 10.35 | 11.42 |

- Absolute difference: +1.08 minutes per user per day.
- Relative increase: Approximately 10.4%.
- Welch's t-test p-value: 0.0149.
- 95% confidence interval: Approximately +0.21 to +1.94 minutes.

The observed-data comparison suggests a positive and statistically significant difference. However, incomplete activity records and unresolved missing-data semantics prevent treating this as a definitive causal ITT result.

### 4. Secondary Metric Results

**Discovery engagement**
- Control: 0.98 clicks per recorded activity day.
- Treatment: 1.40 clicks per recorded activity day.
- Increase: Approximately 43.1%.
- p-value: <0.001.

Discovery engagement was significantly higher in Treatment, including after Bonferroni correction.

**Music listening**
- Control: 55.36 minutes per recorded activity day.
- Treatment: 54.51 minutes per recorded activity day.
- p-value: 0.318.

No statistically significant difference was detected.

### 5. Guardrail Results

**App crashes**
- Control users experiencing at least one recorded crash: 19.41%.
- Treatment users experiencing at least one recorded crash: 23.25%.
- Absolute difference: +3.84 percentage points.
- Chi-square p-value: 0.0411.

The difference was nominally significant but did not remain significant after Bonferroni correction across four secondary comparisons.

This is a potential stability concern that should be investigated before launch.

### 6. Data Quality and Limitations

- 78 duplicate activity records were removed.
- 12 unique impossible podcast listening values were converted to missing.
- 20 activity records belonged to users absent from the randomized user map.
- 170 podcast listening measurements were missing after cleaning.
- Approximately 94% of users had fewer than 14 recorded activity days.
- Missing podcast measurements differed across experiment groups.
- Documentation did not establish whether absent activity records represented zero activity or incomplete logging.
- Premium cancellation impact could not be evaluated due to unavailable cancellation data.

Consequently, the primary outcome and other daily activity comparisons should be interpreted cautiously.

## 7. Final Recommendation: ITERATE — DO NOT SHIP

The Video-First Discovery Feed showed promising results by increasing podcast discovery clicks by approximately 43.1%. The preliminary analysis also showed a 10.4% increase in average daily podcast listening time among Treatment users compared with Control users.

However, the Treatment group experienced a higher app crash incidence (23.25%) compared with the Control group (19.41%). Additionally, missing podcast measurements and incomplete activity records limit confidence in the primary metric results.

Therefore, the recommendation is to **ITERATE — DO NOT SHIP** the feature at this stage.

### Recommended Next Steps
1. Investigate and address the higher app crash incidence.
2. Improve activity logging and investigate missing podcast measurements.
3. Recalculate the primary metric using reliable 14-day user-level data.
4. Conduct another experiment to confirm the benefits and evaluate Premium retention before a full rollout.

The feature has potential, but further improvements and validation are necessary before launching it to all users.