### Aggregation

A very common operation is to aggregate a series from a high frequency
to a lower frequency, say from an hourly to a monthly series.

There are several functions available to accomplish this.


| Name      | Description        |
|-----------|--------------------|
| toHourly  | Aggregate by hour  |
| toDaily   | Aggregate by day   |
| toMonthly | Aggregate by month |
| toYearly  | Aggregate by year  |



List of supported aggregation functions

| Name   | Description                                           |
|--------|-------------------------------------------------------|
| first  | Return the first element of list of numbers           |
| last   | Return the last element of list of numbers            |
| length | Return the length of list of numbers                  |
| max    | Calculate the largest value of a list of numbers      |
| mean   | Calculate the average value of a list of numbers      |
| min    | Calculate the smallest value of a list of numbers     |
| sd     | Calculate the standard deviation of a list of numbers |


For example, to calculate the monthly mean of a timeseries ``x`` do

>    `toMonthly(x, mean)`

this will create a monthly timeseries.

Available functions

.. _toDaily:

.. js:function:: toDaily(x, function[, bucket])

    Return a daily timeseries constructed by applying the ``function`` to all
    the observations in a day.

    :param TimeSeries<num> x: A numeric timeseries with a higher frequency than daily,
        for example hourly.
    :param function: A function name (does not need to be quoted), for example ``mean``, etc.
    :param bucket: An optional bucket name (does not need to be quoted), for example ``5x16``, etc.
    :returns: A numeric ``TimeSeries``

