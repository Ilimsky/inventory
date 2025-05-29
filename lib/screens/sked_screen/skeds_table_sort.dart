import '../../models/Sked.dart';
import '../../providers/SkedProvider.dart';

void handleSort(
    int columnIndex,
    bool ascending,
    SkedProvider skedProvider,
    Function(int, bool) updateState,
    ) {
  switch (columnIndex) {
    case 0:
      _sort<String>((r) => r.skedNumber, columnIndex, ascending, skedProvider, updateState);
      break;
    case 1:
      _sort<DateTime>((r) => r.dateReceived, columnIndex, ascending, skedProvider, updateState);
      break;
    case 2:
      _sort<String>((r) => r.itemName, columnIndex, ascending, skedProvider, updateState);
      break;
  // Добавьте другие case для каждого столбца
  }
}

void _sort<T>(
    Comparable<T> Function(Sked r) getField,
    int columnIndex,
    bool ascending,
    SkedProvider skedProvider,
    Function(int, bool) updateState,
    ) {
  skedProvider.skeds.sort((a, b) {
    final aValue = getField(a);
    final bValue = getField(b);
    return ascending
        ? Comparable.compare(aValue, bValue)
        : Comparable.compare(bValue, aValue);
  });

  updateState(columnIndex, ascending);
}