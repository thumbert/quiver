### Operations with timeseries

#### Create a timeseries

Occasionally it is useful to directly create timeseries. 

**hourly_schedule** Create an hourly timeseries

```
hourly_schedule(10, tz='UTC')
hourly_schedule(50, tz='America/New_York', bucket='Peak')
```

**daily_schedule** Create a daily timeseries

```
daily_schedule(10, tz='UTC')
```

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


