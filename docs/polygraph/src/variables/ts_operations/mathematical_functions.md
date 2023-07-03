### Mathematical functions

Assume `x` and `y` are timeseries.  Then

* **min** calculates the min value between two timeseries or a timeseries and a number. 
* **max** calculates the min value between two timeseries or a timeseries and a number. 

The following expressions are valid
```
min(x, y)
min(x, 2)
```
and similarly for `max`. 

> **Note** The expression `min(x, 2)` creates a timeseries with the same 
> domain as `x` and all values less than or equal to 2, that is the 
> function `min` gets applied to all the values of `x`.   The expression 
> `min(x, y)` returns a timeseries on the overlapping intervals with 
> value being the min of `x` and `y`.


