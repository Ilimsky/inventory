import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/Sked.dart';
import '../../../services/auth_service.dart';

Future<String?> showWriteOffDialog(BuildContext context, int skedId) async {
  final authService = Provider.of<AuthService>(context, listen: false);

  // Проверка прав доступа
  if (!authService.isSuperAdmin) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Доступ запрещен: списание доступно только супер-администраторам')),
    );
    return null;
  }

  final reasonController = TextEditingController();

  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('Списать актив'),
      content: TextField(
        controller: reasonController,
        decoration: InputDecoration(
            labelText: 'Причина списания',
            hintText: 'Например: Износ, поломка, утрата...'
        ),
        maxLines: 3,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text('Отмена'),
        ),
        TextButton(
          onPressed: () {
            if (reasonController.text.isNotEmpty) {
              Navigator.pop(ctx, reasonController.text);
            }
          },
          child: Text('Списать'),
        ),
      ],
    ),
  );
}