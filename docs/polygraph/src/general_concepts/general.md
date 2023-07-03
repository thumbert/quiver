## General concepts

Polygraph organizes work in **projects**.  In general, a **project** has several **tabs**
and each tab can contain several **windows**.  Each window contains one chart displaying
multiple **variables**.  Tabs can be added, deleted and renamed.  A project can be saved
to a database in a given userspace/folder so it can be retrieved later.  Projects can
be loaded from the database.

**Variables** are assigned values from a backend (a database) via various UI components.
Each **variable**
has a unique label associated with it, and of course an associated timeseries data.
Once the **variable** is fetched from the database, it gets cached together with other
variables associated with a particular **tab**.  One can define new variables from existing
ones using a number of built-in functions.  For details on how to define new variables, see
Section .

For Polygraph a timeseries should be thought of as an ordered collection of observations.
Each observation is a pair of a time-interval and a (numerical) value.

> **📝 Note**  The time interval between a start and end moment includes the ``start`` moment 
>    but excludes the ``end`` moment.  Both the start and the end are timestamps in the
>    same timezone.
>
>    An observation is pair of a time interval and a value:
> 
>        [start, end) -> value
>
>    This construct has certain advantages compared to using only a timestamp (like Shooju
>    does.)  It obviates the need to specify a time *convention* for the timestamp.  The
>    user is never in doubt.  And it allows for timeseries that contain observations with
>    different interval length, say daily observations, followed by monthly, quarterly
>    or yearly observations.
>
>    A disadvantage is that this representation uses more memory, but that should not be
>    an issue given that a typical Polygraph project should use less than a hundred of
>    series.

Also, Polygraph by design is taking a lot of care to communicate clearly the timezone
associated with each timeseries.

### Implementation

Polygraph was created with open source software.  The user interface is 
written in [Flutter](https://flutter.dev/).  The charts are done using 
[Plotly](https://plotly.com/javascript/).  This documentation was made using 
[mdBook](https://github.com/rust-lang/mdBook).
