### Operations with timeseries

#### Create a timeseries

Occasionally it is useful to directly create timeseries. 

Use **`hourlySchedule`** to create an hourly timeseries

> `hourlySchedule(fill, {bucket, months})`
> 
> Create an hourly timeseries for the time window specified in the 
> associated Polygraph tab.  All values of the created timeseries 
> are set to `fill`.  The domain of the timeseries is the 
> viewport of the window.
> 
> Parameters
> * `fill` the value for all hours
> * `bucket` A bucket name (quoted), for example ``5x16``, etc.  For a list
>   of valid bucket names see Section [Buckets](../../energy_concepts/buckets.md)
> * `months` A list of months separated by commas inside brackets, for example
>   ``[4, 5, 10, 11]``, a numeric range start-end, for example `6-9`, or a
>   combination of the two, for example `[1, 3, 5-7, 10-11]`.  Accepted month
>   values are between 1 and 12.
> 
> Examples
>
>   `hourlySchedule(10)`
> 
>   `hourlySchedule(50, bucket='Peak')`
>
>   `hourlySchedule(50, bucket='Peak', months=[1,2])`

**daily_schedule** Create a daily timeseries

```
dailySchedule(10)
```

#### Diff

Calculate 

#### Lag

Lag a timeseries.  If `x` is a timeseries, 

```
lag(x, n)
```
creates another timeseries with the values shifted backwards by `n` 
observations.  

> **Note** applying a shift to a timeseries only make sense when all the 
> observations are of the same duration, and when there are no gaps in the 
> data.  
> 
> **Example** 
> If `x` is the monthly timeseries
>```
>   2021-01 -> 10
>   2021-02 -> 11
>   2021-03 -> 15
>   2021-04 -> 13
>   2021-05 -> 12
>```
> `lag(x, 3)` creates the timeseries
> ```
>   2021-04 -> 10
>   2021-05 -> 11
> ```

To calculate a first order difference, do `x - lag(x,1)`.


#### Resample

Use `resample` to go from a low-frequency timeseries to a higher frequency 
one. 

The required parameter `duration` is a string in the ISO 8601 format. For 
a complete format specification, see 
[ISO 8601](https://en.wikipedia.org/wiki/ISO_8601#Durations).  

```
resample(x, duration='P1D')
```


