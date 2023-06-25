Polygraph implements a custom parser to facilitate an expressive language geared
towards timeseries analysis.  This allows one to manipulate timeseries
in a natural way using simple arithmetic symbols.

As a teaser, you can write expressions like this
```
    qty * max(elec_price - 7 * ng_price - 3.5, 0)
```
to estimate the profitability of a power plant.  

Alas, things are never this easy 😀 if correctness is a goal!  The 
`ng_price` is likely stored in the database as a daily timeseries in 
the `UTC` time zone, while the `elec_price` is an hourly timeseries in a local 
timezone, say `America/New_York`.  To minimize erroneous results, Polygraph 
does not allow operations with timeseries in different timezones or 
different frequencies.  For the expression above to work, the `ng_price` 
series needs first to be expanded to an hourly timeseries, and shifted to 
account for the *gas day* in the correct timezone. 

Polygraph has several predefined functions useful for timeseries
analysis.  See below for more details.


## Expressions

Polygraph has built-in support for various functions that are useful when manipulating
timeseries.






Combining series
****************

.. js:function:: append(x, y)

    Return a daily timeseries constructed by appending the series ``y`` to
    series ``x``.   If an observation in ``y`` is before any observation in
    ``x``, it is ignored.  If an observation in ``y`` has an interval
    overlapping with an observation in ``x``, the interval gets assigned the
    value from ``y``.  All observations in ``y`` that come after the ones
    in ``x`` become part of the result.

    :param TimeSeries<num> x: A numeric timeseries.
    :param TimeSeries<num> y: A numeric timeseries.
    :returns: A numeric ``TimeSeries``




Rolling functions
*********************

