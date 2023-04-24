

# TODO
## Polygraph
- Define hotkey Ctrl-D to show a table with data underlying 
  the plot
- Not sure how to show the data because it can be of various frequency
- Implement Load/Save functionality for the plot config
- Implement multiple tabs and multiple plots per tab. 
- When variable selection is made, the OK button needs to do the widget validation.
- When tabs are added, they can stretch outside the screen.  How to scroll to them?

## Release 2023-04-xx
- Polygraph changes
  - Tabs now have a scrollbar 



## Release 2023-04-23
- Polygraph changes
  - Tabs can now be rearranged into a different position by dragging
  - Deleting Y variables now works
  - Selection widget looks to be the hardest to implement.  Selecting an expression 
    now works.  Horizontal line variable almost works with selection.
  - When new variables are added, match the variable color with the trace 
    on the screen 

## Release 2023-04-14
- Polygraph changes
    - Added tabs and windows.  Right context menus for tabs are working.  Added some tests 
    - Added LMP prices to LocalService
    - Started a major effort to provide a type safe wrappers for plotly elements. 
      Currently, I have layout, axes, titles, etc.  I can use it for serialization too.
    - Some parser improvements, especially for error reporting.
    - Variable summary is now working in a separate window, each variable in a card. 
    - Window caching is now better, don't do a trip to the DB if not *needed*

## Release 2023-03-11
- Work on polygraph. 
- Added color to the Y axis variables, so you can easily
  identify them in the plot.  
- Added a Show/Hide icon for the Y variables.  If hidden, color becomes gray.

## Release 2023-02-20
- Rate board table, highlight NewEnergy offers; test that you can
change utilities, etc. 

## Release 2023-01-20
- Work on polygraph.  Convert to riverpod.  


## Release 2022-12-30
- Rate board example
- Migrated package go_router to 5.x version