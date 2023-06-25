Functions
=========

Polygraph functions have a familiar syntax.  A function can have any number of
required **positional** parameters.  These can be followed by **named**
parameters.  Named parameters are optional.

In a function declaration, named parameters are shown inside curly brackets
``{param1, param2, …}``.

For example, for the function ``window(x, {bucket, months, hours})``, parameter
``x`` is a required positional parameter, and the parameters ``bucket``,
``months``, ``hours`` are named and optional.  Some valid calls for this function 
are

```javascript
    window(x, bucket=5x16)
    window(x, bucket=Offpeak, months=[1,2])
```





