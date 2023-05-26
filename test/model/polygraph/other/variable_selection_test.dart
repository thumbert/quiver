


// group('Variable selection test', () {
//   test('get categories', () {
//     var vs = VariableSelection();
//     var cat0 = vs.getCategoriesForNextLevel();
//     expect(cat0.length, cat0.toSet().length); // should be unique
//     expect(cat0.contains('Time'), true);
//     expect(cat0.contains('Electricity'), true);
//     expect(cat0.contains('Gas'), true);
//     expect(vs.isSelectionDone(), false);
//
//     // add one
//     vs.selectCategory('Electricity');
//     var cat1 = vs.getCategoriesForNextLevel();
//     expect(cat1, ['Realized', 'Forward']);
//     expect(vs.isSelectionDone(), false);
//
//     // and another
//     vs.selectCategory('Realized');
//     var cat2 = vs.getCategoriesForNextLevel();
//     expect(cat2.isEmpty, true);
//     expect(vs.isSelectionDone(), true);
//
//     // remove level 1
//     vs.removeFromLevel(1);
//     expect(vs.categories, ['Electricity']);
//
//     // add another one, remove from level 0
//     vs.selectCategory('Forward');
//     vs.removeFromLevel(0);
//     expect(vs.isSelectionDone(), false);
//     expect(vs.getCategoriesForNextLevel().contains('Time'), true);
//   });
//   test('get categories level 1', () {
//     var vs = VariableSelection();
//     expect(vs.getCategoriesForNextLevel().contains('Time'), true);
//     vs.selectCategory('Grid Line');
//     expect(vs.getCategoriesForNextLevel(), ['Horizontal', 'Vertical']);
//   });
// });
