import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/sked_provider.dart';

void showWriteOffDialog(BuildContext context, int skedId) {
  final reasonController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Списание имущества'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Укажите причину списания:'),
            SizedBox(height: 10),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Причина списания',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Отмена'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              if (reasonController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Введите причину списания')),
                );
                return;
              }

              try {
                final skedProvider = Provider.of<SkedProvider>(context, listen: false);
                await skedProvider.writeOffSked(
                  skedId: skedId,
                  writeOffReason: reasonController.text,
                );
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Ошибка при списании: $e')),
                );
              }
            },
            child: Text('Списать', style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    },
  );
}