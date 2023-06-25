### Basic operations

Basic arithmetic of timeseries is implemented.  This section refers to
binary operations like `+` (addition), `-` (subtraction), `*` (multiplication),
and `/` (division).  These binary operations also work when only one side 
of the expression is a timeseries and the other one is a number.

If the two sides are timeseries, they need to have some matching 
intervals for the result to be non-empty.

* **Addition** Add two timeseries.  Or, if a number is added to a timeseries, 
  all values of the timeseries are incremented by that number.

* **Subtraction** Subtract two timeseries.  Or, if a number is subtracted from a 
  timeseries, all values of the timeseries are reduced by that number.

* **Multiplication** Multiply two timeseries.  Or, if a number is multiplied 
  to a timeseries, all values of the timeseries are multiplied by that number.

* **Division** Divide two timeseries.  Or, if a timeseries is divided by number, 
  all values of the timeseries are divided by that number.

Then one can write algebraic expressions like this
```
    hub_price + cong_price + loss_factor * hub_price
```
or
```
    node_price - hub_price
```

If `x` is a timeseries, the expression `-x` is another timeseries with all 
values negated. 
