## Buckets

Time buckets are a core concept when dealing with electricity 
timeseries.  Several Polygraph functions accept buckets as arguments, 
see for example the function ```window``` used to filter observations 
based on the time interval. 

Polygraph supports the following time buckets.  Bucket names are not 
case-sensitive. 

| Name          | Description                                                    |
|---------------|----------------------------------------------------------------|
| ATC           | All hours                                                      |
| FLAT          | Same as ATC                                                    |
| PEAK          | Monday to Friday excluding NERC holidays, hours beginning 6-22 |
| PEAK_CAISO    | Monday to Friday excluding NERC holidays, hours beginning 6-21 |
| PEAK_ERCOT    | Monday to Friday excluding NERC holidays, hours beginning 7-21 |
| ONPEAK        | Same as PEAK                                                   |
| OFFPEAK       | The standard offpeak bucket, that is hours in 2x16H and 7x8    |
| OFFPEAK_AESO  | The offpeak bucket for AESO, consistent with ICE definitions   |
| OFFPEAK_CAISO | The offpeak bucket for CAISO, consistent with ICE definitions  |
| OFFPEAK_ERCOT | The offpeak bucket for ERCOT, consistent with ICE definitions  |
| WRAP          | Same as OFFPEAK                                                |
| 1x16H         | Sundays and NERC holidays, hours beginning 7-22                |
| 1x16H_CAISO   | Sundays and NERC holidays, hours beginning 6-21                |
| 2x16          | Saturday and Sundays, hours beginning 6-22                     |
| 2x16H         | Saturday, Sundays, and NERC holidays, hours beginning 7-22     |
| 2x16H_ERCOT   | Saturday, Sundays, and NERC holidays, hours beginning 7-21     |
| 5x8           | Monday to Friday, hours beginning 0-6, 23                      |
| 5x16          | Same as PEAK                                                   |
| 5x16_7        | Hour beginning 7 from the 5x16 days                            |
| 5x16_8        | Hour beginning 8 from the 5x16 days                            |
| 5x16_9        | Hour beginning 9 from the 5x16 days                            |
| 5x16_10       | Hour beginning 10 from the 5x16 days                           |
| 5x16_11       | Hour beginning 11 from the 5x16 days                           |
| 5x16_12       | Hour beginning 12 from the 5x16 days                           |
| 5x16_13       | Hour beginning 13 from the 5x16 days                           |
| 5x16_14       | Hour beginning 14 from the 5x16 days                           |
| 5x16_15       | Hour beginning 15 from the 5x16 days                           |
| 5x16_16       | Hour beginning 16 from the 5x16 days                           |
| 5x16_17       | Hour beginning 17 from the 5x16 days                           |
| 5x16_18       | Hour beginning 18 from the 5x16 days                           |
| 5x16_19       | Hour beginning 19 from the 5x16 days                           |
| 5x16_20       | Hour beginning 20 from the 5x16 days                           |
| 5x16_21       | Hour beginning 21 from the 5x16 days                           |
| 5x16_22       | Hour beginning 22 from the 5x16 days                           |
| 6x16          | Monday to Saturday, hours beginning 7-22                       |
| 7x8           | Monday to Sunday, hours beginning 0-6, 23                      |
| 7x8_CAISO     | Monday to Sunday, hours beginning 0-5, 22-23                   |
| 7x8_ERCOT     | Monday to Sunday, hours beginning 0-6, 22-23                   |
| 7x16          | Monday to Sunday, hours beginning 7-22                         |
| 7x16_ERCOT    | Monday to Sunday, hours beginning 7-21                         |
| 7x24          | All hours, same as ATC and FLAT                                |

