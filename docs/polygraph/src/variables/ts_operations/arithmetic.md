### Basic operations

Basic arithmetic of timeseries is implemented.  This section refers to
binary operations like `+` (addition), `-` (subtraction), `*` (multiplication),
and `/` (division).  These binary operations also work when only one side 
of the expression is a timeseries and the other one is a number.

If the two sides are timeseries, they need to have some matching 
intervals for the result to be non-empty because the operation is **only applied** 
to the matching intervals. 

* **Addition** Add two timeseries.  Or, if a number is added to a timeseries, 
  all values of the timeseries are incremented by that number.

* **Subtraction** Subtract two timeseries.  Or, if a number is subtracted from a 
  timeseries, all values of the timeseries are reduced by that number.

* **Multiplication** Multiply two timeseries.  Or, if a number is multiplied 
  to a timeseries, all values of the timeseries are multiplied by that number.

* **Division** Divide two timeseries.  Or, if a timeseries is divided by number, 
  all values of the timeseries are divided by that number.

> **Note** The four arithmetic operators mentioned above operate strictly 
> on matching intervals.  This is often what is needed and can prevent many 
> subtle errors.  There are other 
> instances when a different approach is desired.  For example, 
> if `x` is a timeseries defined on the 5x16 bucket, `y` is a timeseries 
> defined on the 7x8 bucket, and `z` is a timeseries defined on the 2x16H 
> bucket, how to *join* (interleave) the three series?  The regular addition 
> will return an empty timeseries.  You can achieve what you want with the 
> dot-addition operator `.+`.  

* **Dot Addition** Outer join and add two timeseries. 

> **Example**
> If `x` and `y` are the monthly timeseries
>```
> x:                   y:
> 2021-01 -> 10        2021-02 -> 5
> 2021-02 -> 11        2021-03 -> 6
> 2021-03 -> 15        2021-05 -> 7
> 2021-04 -> 13        2021-08 -> 8
> 2021-05 -> 12
>```
> Then the sum `x + y` and the dot sum `x .+ y` are respectively
> ```
> x + y:                    x .+ y: 
> 2021-02 -> 16             2021-01 -> 10 
> 2021-03 -> 21             2021-02 -> 16
> 2021-05 -> 22             2021-03 -> 21
>                           2021-04 -> 13
>                           2021-05 -> 19
>                           2021-08 ->  8
> ```


With the basic operations defined, one can write algebraic expressions 
like this
```
    hub_price + cong_price + loss_factor * hub_price
```
or
```
    node_price - hub_price
```

If `x` is a timeseries, the expression `-x` is another timeseries with all 
values negated. 
