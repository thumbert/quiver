### Rolling functions

* **ma** Calculate a moving average

> `ma(x, n)`  Calculate a 'simple' moving average of the last `n` 
> observations.  No special consideration is given if the timeseries 
> 'has gaps'.
> 
> Returns a timeseries
> 
> Parameters
> * `x` a numeric timeseries
> * `n` window length, the number of observations used in the average.  
>   It should be an integer greater than one.
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
>   2021-04 -> 12.25      
>   2021-05 -> 12.75
>```

