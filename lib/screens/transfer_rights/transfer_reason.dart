enum TransferReason {
  dismissal,
  vacation,
  relocation;

  String get label {
    switch (this) {
      case TransferReason.dismissal:
        return 'Увольнение';
      case TransferReason.vacation:
        return 'Отпуск';
      case TransferReason.relocation:
        return 'Перевод';
    }
  }

  String get commentPrefix {
    switch (this) {
      case TransferReason.dismissal:
        return 'Передано в связи с увольнением сотрудника';
      case TransferReason.vacation:
        return 'Передано в связи с отпуском сотрудника';
      case TransferReason.relocation:
        return 'Передано в связи с переводом сотрудника';
    }
  }
}
