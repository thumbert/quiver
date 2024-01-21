library models.hourly_shape.settings;

sealed class Settings {
  static String comments = '';
}

class SettingsIndividualDays extends Settings {
  SettingsIndividualDays();
  static const String analysisName = 'Hourly weights by day';
}

class SettingsForMedianByYear extends Settings {
  SettingsForMedianByYear();
  static const String analysisName = 'Median hourly weights by year';
}
