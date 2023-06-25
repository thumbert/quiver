## Examples

### Calculate last 10 year Temperature averages and deviations

Let `x` be the daily temperature with enough history.

```
x => window(term='Jan12-Dec22', tz='UTC') # select the last 120 months  
  => splitApply(byMonth, mean)            # calculate monthly average
  => splitApply(byMonthOfYear, mean)      # [(1, m1), (2, m2), ... (12, m12)] 
  => toMonthlyTimeseries                  # add the year and expand in the entire viewport  
```
