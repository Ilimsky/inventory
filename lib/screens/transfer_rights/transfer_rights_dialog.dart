import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/Department.dart';
import '../../models/Employee.dart';
import '../../models/Sked.dart';
import '../../providers/department_provider.dart';
import '../../providers/employee_provider.dart';
import '../../providers/sked_provider.dart';
import '../../services/api_service.dart';
import 'transfer_act_service.dart';
import 'transfer_reason.dart';
import 'transfer_result.dart';
import 'transfer_rights_service.dart';

Future<void> showTransferRightsDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _TransferRightsDialog(),
  );
}

enum _Step { configure, preview, progress, result }

class _TransferRightsDialog extends StatefulWidget {
  const _TransferRightsDialog();

  @override
  State<_TransferRightsDialog> createState() => _TransferRightsDialogState();
}

class _TransferRightsDialogState extends State<_TransferRightsDialog> {
  Employee? _fromEmployee;
  Employee? _toEmployee;
  Department? _department;
  TransferReason _reason = TransferReason.dismissal;
  final _commentCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  _Step _step = _Step.configure;
  List<Sked> _previewSkeds = [];
  bool _loadingPreview = false;
  String? _previewError;

  int _progressDone = 0;
  int _progressTotal = 0;

  TransferResult? _result;
  bool _printingAct = false;
  String? _printError;



  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  TransferRightsService get _service =>
      TransferRightsService(context.read<ApiService>());

  List<Employee> get _employees =>
      context.read<EmployeeProvider>().employees;

  List<Department> get _departments =>
      context.read<DepartmentProvider>().departments;

  Future<void> _goToPreview() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loadingPreview = true;
      _previewError = null;
      _step = _Step.preview;
    });
    try {
      final skeds = await _service.fetchActiveSkeds(_fromEmployee!.id);
      setState(() {
        _previewSkeds = skeds;
        _loadingPreview = false;
      });
    } catch (e) {
      setState(() {
        _previewError = e.toString();
        _loadingPreview = false;
      });
    }
  }

  // Future<void> _startTransfer() async {
  //   if (_previewSkeds.isEmpty) return;
  //   setState(() {
  //     _step = _Step.progress;
  //     _progressDone = 0;
  //     _progressTotal = _previewSkeds.length;
  //   });
  //
  //   final result = await _service.transferAll(
  //     fromEmployee: _fromEmployee!,
  //     toEmployee: _toEmployee!,
  //     skeds: _previewSkeds,
  //     reason: _reason,
  //     additionalComment: _commentCtrl.text,
  //     onProgress: (done, total) =>
  //         setState(() {
  //           _progressDone = done;
  //           _progressTotal = total;
  //         }),
  //   );
  //
  //   final sp = context.read<SkedProvider>();
  //   final depId = sp.currentDepartmentId;
  //   if (depId != null) {
  //     await sp.fetchSkedsByDepartmentPaged(departmentId: depId);
  //   } else {
  //     await sp.fetchAllSkedsPaged();
  //   }
  //
  //   setState(() {
  //     _result = result;
  //     _step = _Step.result;
  //   });
  // }

  Future<void> _startTransfer() async {
    if (_previewSkeds.isEmpty) return;

    setState(() {
      _step = _Step.progress;
      _progressDone = 0;
      _progressTotal = _previewSkeds.length;
    });

    final skedProvider = context.read<SkedProvider>();
    final toEmployeeId = _toEmployee!.id;

    final result = await _service.transferAll(
      fromEmployee: _fromEmployee!,
      toEmployee: _toEmployee!,
      skeds: _previewSkeds,
      reason: _reason,
      additionalComment: _commentCtrl.text,
      onProgress: (done, total) {
        setState(() {
          _progressDone = done;
          _progressTotal = total;
        });
      },
      onSuccess: (skedId) {
        skedProvider.updateSkedLocally(skedId, employeeId: toEmployeeId);
      },
    );

    setState(() {
      _result = result;
      _step = _Step.result;
    });
  }

  Future<void> _printAct() async {
    setState(() {
      _printingAct = true;
      _printError = null;
    });
    try {
      final transferred = _previewSkeds
          .take(_result!.successCount)
          .toList();
      await TransferActService.printAct(
        skeds: transferred,
        departmentName: _department!.name,
        fromEmployee: _fromEmployee!,
        toEmployee: _toEmployee!,
        reason: _reason,
        allEmployees: _employees,
      );
    } catch (e) {
      setState(() => _printError = 'Ошибка формирования акта: $e');
    } finally {
      setState(() => _printingAct = false);
    }
  }

  void _reset() => setState(() {
        _step = _Step.configure;
        _fromEmployee = null;
        _toEmployee = null;
        _department = null;
        _reason = TransferReason.dismissal;
        _commentCtrl.clear();
        _previewSkeds = [];
        _previewError = null;
        _result = null;
        _printError = null;
      });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints:
            const BoxConstraints(maxWidth: 580, minWidth: 320),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: switch (_step) {
              _Step.configure => _ConfigureStep(
                  key: const ValueKey('configure'),
                  formKey: _formKey,
                  employees: _employees,
                  departments: _departments,
                  fromEmployee: _fromEmployee,
                  toEmployee: _toEmployee,
                  department: _department,
                  reason: _reason,
                  commentController: _commentCtrl,
                  onFromChanged: (e) => setState(() => _fromEmployee = e),
                  onToChanged: (e) => setState(() => _toEmployee = e),
                  onDeptChanged: (d) => setState(() => _department = d),
                  onReasonChanged: (r) => setState(() => _reason = r),
                  onNext: _goToPreview,
                  onCancel: () => Navigator.of(context).pop(),
                ),
              _Step.preview => _PreviewStep(
                  key: const ValueKey('preview'),
                  loading: _loadingPreview,
                  error: _previewError,
                  skeds: _previewSkeds,
                  fromEmployee: _fromEmployee!,
                  toEmployee: _toEmployee!,
                  department: _department!,
                  reason: _reason,
                  onBack: () => setState(() => _step = _Step.configure),
                  onConfirm: _startTransfer,
                ),
              _Step.progress => _ProgressStep(
                  key: const ValueKey('progress'),
                  completed: _progressDone,
                  total: _progressTotal,
                ),
              _Step.result => _ResultStep(
                  key: const ValueKey('result'),
                  result: _result!,
                  printingAct: _printingAct,
                  printError: _printError,
                  onPrintAct: _printAct,
                  onRepeat: _reset,
                  onClose: () => Navigator.of(context).pop(),
                ),
            },
          ),
        ),
      ),
    );
  }
}

// ── Шаг 1: Настройка ──────────────────────────────────────────────────────────

class _ConfigureStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final List<Employee> employees;
  final List<Department> departments;
  final Employee? fromEmployee;
  final Employee? toEmployee;
  final Department? department;
  final TransferReason reason;
  final TextEditingController commentController;
  final ValueChanged<Employee?> onFromChanged;
  final ValueChanged<Employee?> onToChanged;
  final ValueChanged<Department?> onDeptChanged;
  final ValueChanged<TransferReason> onReasonChanged;
  final VoidCallback onNext;
  final VoidCallback onCancel;

  const _ConfigureStep({
    super.key,
    required this.formKey,
    required this.employees,
    required this.departments,
    required this.fromEmployee,
    required this.toEmployee,
    required this.department,
    required this.reason,
    required this.commentController,
    required this.onFromChanged,
    required this.onToChanged,
    required this.onDeptChanged,
    required this.onReasonChanged,
    required this.onNext,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.swap_horiz_rounded, size: 22),
            const SizedBox(width: 8),
            Text(
              'Передача материальных ценностей',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ]),
          const SizedBox(height: 4),
          Text(
            'Все активные МЦ передающего будут переоформлены на принимающего.',
            style: theme.textTheme.bodySmall?.copyWith(
                color:
                    theme.colorScheme.onSurface.withOpacity(.55)),
          ),
          const Divider(height: 24),

          // Основание
          Text('Основание', style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: TransferReason.values
                .map((r) => ChoiceChip(
                      label: Text(r.label),
                      selected: r == reason,
                      onSelected: (_) => onReasonChanged(r),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),

          // Филиал — ОБЯЗАТЕЛЬНЫЙ
          DropdownButtonFormField<Department>(
            value: department,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Филиал *',
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            hint: const Text('Выберите филиал'),
            items: departments
                .map((d) => DropdownMenuItem(
                      value: d,
                      child:
                          Text(d.name, overflow: TextOverflow.ellipsis),
                    ))
                .toList(),
            onChanged: onDeptChanged,
            validator: (v) => v == null ? 'Укажите филиал' : null,
          ),
          const SizedBox(height: 12),

          // Передающий
          _EmployeeDropdown(
            label: 'Передающий сотрудник *',
            hint: 'Выберите сотрудника',
            value: fromEmployee,
            employees: employees,
            excludeId: toEmployee?.id,
            onChanged: onFromChanged,
            validator: (v) =>
                v == null ? 'Выберите передающего' : null,
          ),
          const SizedBox(height: 12),

          // Принимающий
          _EmployeeDropdown(
            label: 'Принимающий сотрудник *',
            hint: 'Выберите сотрудника',
            value: toEmployee,
            employees: employees,
            excludeId: fromEmployee?.id,
            onChanged: onToChanged,
            validator: (v) =>
                v == null ? 'Выберите принимающего' : null,
          ),
          const SizedBox(height: 12),

          // Комментарий
          TextFormField(
            controller: commentController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Дополнительный комментарий (необязательно)',
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                  onPressed: onCancel,
                  child: const Text('Отмена')),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: onNext,
                icon: const Icon(Icons.arrow_forward_rounded,
                    size: 18),
                label: const Text('Далее'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Шаг 2: Превью ─────────────────────────────────────────────────────────────

class _PreviewStep extends StatelessWidget {
  final bool loading;
  final String? error;
  final List<Sked> skeds;
  final Employee fromEmployee;
  final Employee toEmployee;
  final Department department;
  final TransferReason reason;
  final VoidCallback onBack;
  final VoidCallback onConfirm;

  const _PreviewStep({
    super.key,
    required this.loading,
    required this.error,
    required this.skeds,
    required this.fromEmployee,
    required this.toEmployee,
    required this.department,
    required this.reason,
    required this.onBack,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Предварительный просмотр',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            _InfoChip(
                icon: Icons.business_rounded,
                label: department.name,
                color: cs.primary),
            _InfoChip(
                icon: Icons.person_rounded,
                label: fromEmployee.name,
                color: cs.secondary),
            _InfoChip(
                icon: Icons.arrow_forward_rounded,
                label: toEmployee.name,
                color: cs.tertiary),
            _InfoChip(
                icon: Icons.label_outline_rounded,
                label: reason.label,
                color: cs.outline),
          ],
        ),
        const Divider(height: 20),

        if (loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (error != null)
          _ErrorCard(message: error!)
        else if (skeds.isEmpty)
          _EmptyCard(employeeName: fromEmployee.name)
        else ...[
          Text('Будет передано МЦ: ${skeds.length}',
              style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 240),
            child: _SkedPreviewList(skeds: skeds),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cs.errorContainer.withOpacity(.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: cs.error.withOpacity(.4), width: .8),
            ),
            child: Row(children: [
              Icon(Icons.warning_amber_rounded,
                  color: cs.error, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Действие необратимо. После подтверждения '
                  'будет сформирован акт приёма-передачи.',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: cs.error),
                ),
              ),
            ]),
          ),
        ],

        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
                onPressed: onBack, child: const Text('Назад')),
            const SizedBox(width: 8),
            if (!loading && error == null && skeds.isNotEmpty)
              FilledButton.icon(
                onPressed: onConfirm,
                icon:
                    const Icon(Icons.done_all_rounded, size: 18),
                label: Text('Передать ${skeds.length} МЦ'),
                style: FilledButton.styleFrom(
                    backgroundColor: cs.error),
              ),
          ],
        ),
      ],
    );
  }
}

// ── Шаг 3: Прогресс ───────────────────────────────────────────────────────────

class _ProgressStep extends StatelessWidget {
  final int completed;
  final int total;

  const _ProgressStep(
      {super.key, required this.completed, required this.total});

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : completed / total;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.sync_rounded, size: 40),
          const SizedBox(height: 16),
          Text('Передача МЦ...',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 24),
          LinearProgressIndicator(value: pct, minHeight: 6),
          const SizedBox(height: 12),
          Text('$completed / $total',
              style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

// ── Шаг 4: Результат + Акт ────────────────────────────────────────────────────

class _ResultStep extends StatelessWidget {
  final TransferResult result;
  final bool printingAct;
  final String? printError;
  final VoidCallback onPrintAct;
  final VoidCallback onRepeat;
  final VoidCallback onClose;

  const _ResultStep({
    super.key,
    required this.result,
    required this.printingAct,
    required this.printError,
    required this.onPrintAct,
    required this.onRepeat,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final (icon, color, title) = result.isFullSuccess
        ? (Icons.check_circle_rounded, cs.primary, 'Передача завершена')
        : result.isPartialSuccess
            ? (Icons.warning_amber_rounded, cs.tertiary,
                'Частичная передача')
            : (Icons.error_rounded, cs.error, 'Ошибка передачи');

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(width: 10),
          Text(title,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
        ]),
        const Divider(height: 20),

        Row(children: [
          _StatChip(
              label: 'Всего',
              value: result.totalSkeds.toString(),
              color: cs.outline),
          const SizedBox(width: 8),
          _StatChip(
              label: 'Успешно',
              value: result.successCount.toString(),
              color: cs.primary),
          if (result.failedCount > 0) ...[
            const SizedBox(width: 8),
            _StatChip(
                label: 'Ошибок',
                value: result.failedCount.toString(),
                color: cs.error),
          ],
        ]),

        if (result.errors.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text('Не удалось передать:',
              style: theme.textTheme.labelLarge),
          const SizedBox(height: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 120),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: result.errors.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 8),
              itemBuilder: (_, i) => Text(result.errors[i],
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: cs.error)),
            ),
          ),
        ],

        // ── Секция акта ────────────────────────────────────────────
        if (result.successCount > 0) ...[
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 10),
          Row(children: [
            Icon(Icons.description_outlined,
                size: 18, color: cs.primary),
            const SizedBox(width: 8),
            Text('Акт приёма-передачи',
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 4),
          Row(children: [
            Icon(Icons.calendar_today_outlined,
                size: 14,
                color:
                    theme.colorScheme.onSurface.withOpacity(.45)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Поле «Дата» в акте оставлено пустым — '
                'заполняется вручную при подписании сторонами.',
                style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface
                        .withOpacity(.55)),
              ),
            ),
          ]),
          const SizedBox(height: 10),

          if (printError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _ErrorCard(message: printError!),
            ),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: printingAct ? null : onPrintAct,
              icon: printingAct
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2))
                  : const Icon(Icons.print_rounded, size: 18),
              label: Text(printingAct
                  ? 'Формирование акта...'
                  : 'Распечатать акт приёма-передачи'),
            ),
          ),
        ],

        const SizedBox(height: 20),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          if (!result.isFullSuccess)
            TextButton.icon(
              onPressed: onRepeat,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Повторить'),
            ),
          const SizedBox(width: 8),
          FilledButton(
              onPressed: onClose,
              child: const Text('Закрыть')),
        ]),
      ],
    );
  }
}

// ── Вспомогательные виджеты ───────────────────────────────────────────────────

class _EmployeeDropdown extends StatelessWidget {
  final String label;
  final String hint;
  final Employee? value;
  final List<Employee> employees;
  final int? excludeId;
  final ValueChanged<Employee?> onChanged;
  final FormFieldValidator<Employee>? validator;

  const _EmployeeDropdown({
    required this.label,
    required this.hint,
    required this.value,
    required this.employees,
    required this.onChanged,
    this.excludeId,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final filtered =
        employees.where((e) => e.id != excludeId).toList();
    return DropdownButtonFormField<Employee>(
      value: value,
      hint: Text(hint),
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      items: filtered
          .map((e) => DropdownMenuItem(
                value: e,
                child: Text(e.name,
                    overflow: TextOverflow.ellipsis),
              ))
          .toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip(
      {required this.icon,
      required this.label,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(fontSize: 12, color: color),
            overflow: TextOverflow.ellipsis),
      ]),
    );
  }
}

class _SkedPreviewList extends StatelessWidget {
  final List<Sked> skeds;
  const _SkedPreviewList({required this.skeds});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: skeds.length,
      itemBuilder: (_, i) {
        final s = skeds[i];
        return ListTile(
          dense: true,
          visualDensity: VisualDensity.compact,
          leading: Text('${i + 1}',
              style: Theme.of(context).textTheme.bodySmall),
          title:
              Text(s.itemName, overflow: TextOverflow.ellipsis),
          subtitle: Text(
            '${s.skedNumber.isNotEmpty ? s.skedNumber : "—"}  ·  ${s.place}',
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text('${s.count} ${s.measure}',
              style: Theme.of(context).textTheme.bodySmall),
        );
      },
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: cs.errorContainer,
          borderRadius: BorderRadius.circular(8)),
      child: Row(children: [
        Icon(Icons.error_outline_rounded, color: cs.error),
        const SizedBox(width: 8),
        Expanded(
            child: Text(message,
                style:
                    TextStyle(color: cs.onErrorContainer))),
      ]),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String employeeName;
  const _EmptyCard({required this.employeeName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(children: [
          const Icon(Icons.inbox_rounded, size: 40),
          const SizedBox(height: 8),
          Text(
            'У сотрудника «$employeeName»\nнет активных МЦ для передачи.',
            textAlign: TextAlign.center,
          ),
        ]),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatChip(
      {required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: color)),
          Text(label,
              style: TextStyle(
                  fontSize: 11, color: color.withOpacity(.8))),
        ],
      ),
    );
  }
}
