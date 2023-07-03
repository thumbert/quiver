### Rolling functions

* **ma** Calculate a rolling moving average

> `ma(x, n)`  Calculate a rolling moving average of the last `n` 
> observations.  No special consideration is given if the timeseries 
> 'has gaps'.
> 
> Returns a timeseries
> 
> Parameters
> * `x` A numeric timeseries
> * `n` the number of observations used in the average
>
> **Example** If `x` is the monthly timeseries
>```
>   2021-01 -> 10      
>   2021-02 -> 11      
>   2021-03 -> 15      
>   2021-04 -> 13      
>   2021-05 -> 12
>```
> then `ma(x, 4)` is the timeseries
>```
>   2021-04 -> 13      
>   2021-05 -> 12
>```

