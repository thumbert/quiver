library models.polygraph.variables.variable_selection;


class VariableSelection {
  VariableSelection() {
    categories = <String>[];
  }

  /// the current selection 
  late List<String> categories;

  String get selection => categories.join(',');

  static final allCategories = <List<String>>[
    ['Expression'],
    ['Line', 'Horizontal'],
    ['Line', 'Vertical'],
    ['Marks', 'Prices', 'As of'],
    ['Marks', 'Prices', 'Historical'],
    ['Marks', 'Vols'],
    ['Time'],
    // ['Weather', 'Temperature'],
  ];


  /// Add at the end of the category list
  void selectCategory(String category) {
    categories.add(category);
  }

  /// Remove all levels from this level and above
  void removeFromLevel(int level) {
    if (level < categories.length) {
      categories = categories.sublist(0, level);
    }
  }

  /// Get the categories for this level.
  /// Level 0 is 'Time', 'Electricity', etc.
  List<String> getCategoriesForNextLevel() {
    var level = categories.length;
    var xs = allCategories.where((element) => true);
    for (var i=0; i<level; i++) {
      xs = xs.where((e) => e[i] == categories[i]);
    }
    // var aux = xs.toList();
    // print(aux);
    if (xs.length == 1) return <String>[];  // fully specified
    return xs.map((e) => e[level]).toSet().toList();
  }

  ///
  bool isSelectionDone() {
    return getCategoriesForNextLevel().isEmpty;
  }

}