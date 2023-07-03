### Relational operators

Basic comparisons between two timeseries or between a timeseries and a numerical 
constant are supported.  For example, if `x` and `y` are timeseries, the 
relational operators `>`, `>=`, `<`, `<=` are defined.  

```
x > 2
x >= y
```

> **Note**  The expression `x > 2` creates a timeseries formed by 
> subsetting `x` for values that are greater than 2.  It does not return 
> a timeseries of `1` or `0` values.  Similarly, the comparison `x > y` 
> will return a timeseries formed by subsetting `x` by retaining only the 
> values in `x` that are greater than `y`,  only on matching intervals.

You can read `x > 2` as retain from `x` all observations with values 
greater than 2.  In the same way `x > y` means retain all observations of `x` 
with values greater than the corresponding `y` value for the same interval.

A related group of functions is `min` and `max` but they have slightly 
different semantics.  See Section
[Mathematical functions](mathematical_functions.md) for details.
