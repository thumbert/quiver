### Filtering

Filtering (or sub-setting) a timeseries is a very common operation.  There are
two possibilities related to filtering.  One is to select observations with 
intervals from the time domain (filtering the x-axis), or the other, to select 
observations with values that satisfy a given condition (filtering on the 
y-axis.)

To filter the time domain use the function ``window``.  This function takes
a number of named arguments to help you specify your filter.

>`window(x, {bucket, months, hours})`
> 
> Returns a subset of the original timeseries `x` with intervals
>  that satisfy all the constraints specified by the named parameters.
>
> Parameters
>  * `x` The numeric timeseries that will be filtered
>  * `bucket` A bucket name (does not need to be quoted), for example ``5x16``, etc.
>  * `months` A list of months separated by commas inside brackets, for example 
>    ``[4, 5, 10, 11]``, a numeric range start-end, for example `6-9`, or a 
>    combination of the two, for example `[1, 3, 5-7, 10-11]`.  Accepted month 
>    values are between 1 and 12.
>  * `hours` A list of hours separated by commas inside brackets, for example 
>    ``[4, 5, 21, 23]``, a numeric range start-end, for example `6-9`, or a 
>    combination of the two, for example `[0, 3, 5-7, 21-23]`.  Accepted hour 
>    values are between 0 and 23.  
>
> Examples
> 
>   `window(x, bucket=5x16)`
> 
>   `window(x, bucket=Offpeak, months=[1-2, 12])`

To filter the values of a timeseries, one can use simply use conditional expressions.
For example, if `bos` is a timeseries with historical daily temperature in Boston, 
to select only the points with values above 85 F use the expression

>    `bos > 85`

You can then highlight these points with a different color in the chart.
