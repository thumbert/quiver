

# TODO
## Polygraph
- Define hotkey Ctrl-D to show a table with data underlying 
  the plot
- Not sure how to show the data because it can be of various frequency
- Implement Load/Save functionality for the plot config // What is this?  9/3/2023
- Implement VariableMarksHistoricalView.getAllCurveNames() as a method in the DataService instance
- Figure out what the tabAction field does in polygraph_tab.  Is it used at all anymore?


## Release 2023-09-08
- Polygraph
  - Added PointerInterceptors to the Tab buttons context menus
  - Basic chart settings now work.  Can add title, axis labels, change y axis position
    Plot margins and axis types also work.


## Release 2023-09-04
- Polygraph
  - Implemented read project json file from disk and from DB
  - The new window manager is working.  All window creation is now done from the 
    border of the active window.


## Release 2023-08-09
- Polygraph
  - Work on serde for several variable types. 
  - Fix bug when clicking on different tab and editing the term box, you were getting 
    the variables form Tab1. 
  - Can load basic project from json

## Release 2023-07-22
- More polygraph changes
  - Move the variable add to a separate route.  Should be a better design in 
    the long run. 


## Release 2023-07-23
- More polygraph changes
  - Added hourly_schedule, window, and ma functions.
  - Made the Add variable two-step.  First, make the selection, then populate. 

## Release 2023-05-03
- Many polygraph changes
  - The tab row now has a scrollbar, if they are so many to extend outside the screen
  - Move customization of tab layout in its own widget.  Only setting the canvas size 
    and adding a window is supported.   
  - Can add windows (all the same size for now) to a tab
  - Can delete windows from a tab
  - Added ability to set the size of the canvas for each tab
  - Started to customize the active window plotly display.  Can customize 
    the title, and the legend position.


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