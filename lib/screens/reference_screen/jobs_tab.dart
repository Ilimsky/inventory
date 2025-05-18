import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/JobProvider.dart';

class JobsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final jobProvider = Provider.of<JobProvider>(context);

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  final textController = TextEditingController();
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Добавить должность'),
                      content: TextField(controller: textController),
                      actions: [
                        TextButton(
                          onPressed: () {
                            if (textController.text.isNotEmpty) {
                              jobProvider.createJob(textController.text);
                              Navigator.pop(context);
                            }
                          },
                          child: Text('Добавить'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: jobProvider.isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
            itemCount: jobProvider.jobs.length,
            itemBuilder: (context, index) {
              final job = jobProvider.jobs[index];
              return ListTile(
                title: Text(job.name),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        final textController = TextEditingController(text: job.name);
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Редактировать должность'),
                            content: TextField(controller: textController),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  if (textController.text.isNotEmpty) {
                                    jobProvider.updateJob(job.id, textController.text);
                                    Navigator.pop(context);
                                  }
                                },
                                child: Text('Сохранить'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _showDeleteDialog(context, job.id, jobProvider),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, int jobId, JobProvider jobProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Удалить должность'),
        content: Text('Вы уверены, что хотите удалить эту должность?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              jobProvider.deleteJob(jobId);
              Navigator.pop(context);
            },
            child: Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}