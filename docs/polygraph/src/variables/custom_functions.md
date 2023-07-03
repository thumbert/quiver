Functions
=========

Polygraph functions have a familiar syntax.  A function can have any number of
required **positional** parameters.  These can be followed by **named**
parameters.  Named parameters are optional unless in the definition they are 
prefixed by the keyword `required`.

In a function declaration, named parameters are shown inside curly brackets
``{param1, param2, …}``.

For example, for the function ``window(x, {bucket, months, hours})``, parameter
``x`` is a required positional parameter, and the parameters ``bucket``,
``months``, ``hours`` are named and optional.  Some valid calls for this function 
are

```
    window(x, bucket='5x16')
    window(x, bucket='Offpeak', months=[1,2])
```

An example of a **required named** parameter is `tz` from function `hourly_schedule`. 
The parameter `tz` needs to be specified because otherwise the timeseries 
can't be properly defined.  

> **Note** Polygraph does not allow **default values** for parameters.  Having 
> default values for parameters may seem convenient, but in practice it can 
> introduce subtle bugs, and it makes things less explicit.  For an interesting
> discussion regarding named and default values in functions see 
> [link](https://internals.rust-lang.org/t/pre-rfc-named-arguments/16413/146). 





