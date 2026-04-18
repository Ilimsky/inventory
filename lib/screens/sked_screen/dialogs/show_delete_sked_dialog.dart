import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/sked_provider.dart';

void showDeleteSkedDialog(BuildContext context, int skedId) {
  final skedProvider = Provider.of<SkedProvider>(context, listen: false);

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Удалить отчет'),
      content: Text('Вы уверены, что хотите удалить этот отчет?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Отмена'),
        ),
        TextButton(
          onPressed: () {
            skedProvider.deleteSked(skedId);
            Navigator.pop(context);
          },
          child: Text('Удалить', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}