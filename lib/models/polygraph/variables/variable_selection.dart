library models.polygraph.variables.variable_selection;

class VariableSelection {
  VariableSelection() {
    categories = <String>[];
  }

  /// the current selection 
  late List<String> categories;

  // static final allCategories = <String>{
  //   'Time',
  //   'Electricity|Realized',
  //   'Electricity|Forward',
  //   'Gas|Realized',
  //   'Gas|Forward',
  //   'Combo Expression',
  //   'Shooju',
  //   'Grid Line|Horizontal',
  //   'Grid Line|Vertical',
  // };

  static final allCategories = <List<String>>[
    ['Time'],
    ['Electricity', 'Realized'],
    ['Electricity', 'Forward'],
    ['Gas', 'Realized'],
    ['Gas', 'Forward'],
    ['Combo Expression'],
    ['Shooju'],
    ['Line', 'Horizontal'],
    ['Line', 'Vertical'],
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

  /// to select categories
  bool isSelectionDone() {
    return getCategoriesForNextLevel().isEmpty;
  }

}