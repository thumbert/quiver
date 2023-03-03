library models.polygraph.variables.variable_selection;

class VariableSelection {
  VariableSelection() {
    categories = <String>[];
  }

  late List<String> categories;

  static final allCategories = <String>{
    'Time',
    'Electricity|Realized',
    'Electricity|Forward',
    'Gas|Realized',
    'Gas|Forward',
    'Cross Commodity|Realized',
    'Cross Commodity|Forward',
    'Shooju',
    'Line',
  };

  /// Add at the end of the category list
  void addCategory(String category) {
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
  List<String> getCategoriesForLevel(int level) {
    return allCategories
        .map((e) => e.split('|'))
        .where((xs) => xs.length > level)
        .map((xs) => xs[level])
        .toSet().toList();
  }

  /// to select categories
  bool isSelectionDone() {
    return allCategories.contains(categories.join('|'));
  }

}