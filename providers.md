# Notes using Riverpod for state management


Use `ref.watch(provider)` **in the build method** to capture the new state.

Use `ref.read(provider).state = newValue` to set the state of the provider 
to a `newValue`.  This should not be done in the build method directly but 
in the `onSubmitted`, `onTap`, `onEnter`, `onExit`, etc. methods.

Use `ref.listen(provider, (previous,current){...})` **in the build method** to 
respond to a change in state.  For example if `current=='Hot'` 
show a red widget, if `current=='Cold'` show a blue widget.

### Providers can be combined 

You can achieve nesting by referring to other providers directly.  For example 
given two providers `providerOfCell1`, `providerOfCell2` you can calculate the 
sum of the two cells with another provider
```dart
final providerOfTotal = StateProvider<num>((ref) => ref.watch(providerOfCell1) + 
    ref.watch(providerOfCell2));
```

