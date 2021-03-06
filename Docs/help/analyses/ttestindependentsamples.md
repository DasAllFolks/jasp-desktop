Independent Samples T-Test
==========================

The independent samples t-test allows you to test the null hypothesis that the population means of two independent groups are equal.

Assumptions
-----------
- Numeric dependent variable.
- The observations from both groups are a random sample from the population.
- The dependent variable is normally distributed in both populations.
- The population variances in the two groups are homogeneous.

Options
-------
### Hypothesis:
- Group 1 &ne; Group 2: Two-sided alternative hypothesis that the population means are equal.
- Group 1 &gt Group 2: One-sided alternative hypothesis that the population mean of Group 1 is larger than the population mean of Group 2.
- Group 1 &lt; Group 2: One-sided alternative hypothesis that the population mean of Group 1 is smaller than the population mean of Group 2.

### Equality of Variances
- Assume equal: Assume that the variances of the two groups are equal. The pooled variance is used as an estimate of the population variance.
- No assumption: Do not assume that the variances of the two groups are equal. The degrees of freedom will be computed using the Welch approximation.
- Report both: Report results for both: Assuming and not assuming equality of variances.

### Missing Values
 - Exclude cases analysis by analysis: TBA
 - Exclude cases listwise: TBA
 
Output
-------

### Independent Samples T-Test:
- t: t-value.
- df: Degrees of freedom.
- p: p-value.

Example
-------
### Data set: 
- Gender Differences in Talkativeness

### Input: 
- The null hypothesis that the average number of words spoken per day is the same for women and men is tested against the one-sided alternative hypothesis that the average 
number of words spoken per day is higher for women than for men.

### Output: 
- The null hypothesis that the average number of words spoken per day is the same for women and men cannot be rejected against the one-sided alternative hypothesis that the average 
number of words spoken per day is higher for women than for men, t(77)=-0.135, p=0.447 (variances are assumed to be equal); t(64.02)=-0.132, p=0.448 (variances are not assumer to be equal)

Additional Options
-------

### Test inequality of variances
- Levene's test for homogeneity of variances.

### Additional Statistics:
- Mean difference: Difference in sample means.
- Effect Size: Cohen's d measure of effect size.
- Confidence interval: Confidence interval for the difference in population means
  - Interval: Coverage of the confidence interval in percentages.
- Descriptives: Sample size, sample mean, sample standard deviation, standard error of the mean.

Additional Output
-------

### Independent Samples T-test:
- Mean difference: Difference in sample means.
- SE Difference: Standard error of the difference in means.
- Cohen's d: Cohen's d measure of effect size.
- x% Confidence Interval: Lower and upper bound of the x% confidence interval for 
the difference in population means.

### Descriptives:
- N: Sample size.
- Mean: Sample mean.
- SD: Sample standard deviation.
- SE: Standard error of the mean.

References
-------
 - Moore, D.S., McCabe, G.P., Craig, B.A. (2012). Introduction to the Practice of Statistics (7th ed.). New York, NY: W.H. Freeman and Company.
 - Whitlock, M.C. & Schluter, D. (2015). The Analysis of Biological Data (2nd ed.). Greenwood Village, Colorado: Roberts and Company Publishers.
