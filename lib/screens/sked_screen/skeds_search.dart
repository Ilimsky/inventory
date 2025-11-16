import 'package:flutter/material.dart';

class SearchSkedsField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const SearchSkedsField({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: 'Поиск',
          hintText: 'Введите текст для поиска',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              controller.clear();
              onChanged('');
            },
          )
              : null,
        ),
        onChanged: onChanged,
      ),
    );
  }
}