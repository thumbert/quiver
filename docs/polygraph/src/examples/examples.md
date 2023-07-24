## Examples

### Calculate the monthly average for a bucket 

Let `x` be an hourly price timeseries.

```
x => window(_, bucket='5x16') 
  => toMonthly(_, mean)
```

### Calculate a monthly CDD index

Let `t` be a timeseries of daily temperature for a location.  Then  

```
t => max(_, 65) => toMonthly(_, sum)
```
calculates the monthly CDD index.

### Compare IFerc vs. GDM prices 

Calculate the monthly average of the prices 
```
sj('bla_bla') => toMonthly(_, mean)
```

[//]: # (### Calculate a historic heat-rate)

[//]: # ()
[//]: # (Let `e` be an hourly series for electricity prices.  Let `g` be a )

[//]: # (daily price series for natural gas prices. )

[//]: # ()
[//]: # (```)

[//]: # (e.window&#40;bucket=5x16&#41;)

[//]: # ( .toDaily&#40;mean&#41;)

[//]: # ( )
[//]: # (toDaily&#40;window&#40;e, bucket=5x16&#41;&#41;.withTz&#40;''&#41; )

[//]: # (```)


### Calculate last 10 year Temperature averages and deviations

Let `x` be the daily temperature with enough history.

```
x => window(term='Jan12-Dec22')           # select the last 120 months  
  => splitApply(byMonth, mean)            # calculate monthly average
  => splitApply(byMonthOfYear, mean)      # [(1, m1), (2, m2), ... (12, m12)] 
  => toMonthlyTimeseries                  # add the year and expand in the entire viewport  
```