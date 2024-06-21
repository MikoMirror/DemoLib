import 'package:flutter/material.dart';
import '../StylizedButton.dart';

class AddBookDialog extends StatelessWidget {
  final Function() onManualAdd;
  final Function() onIsbnScan;

  const AddBookDialog({
    Key? key,
    required this.onManualAdd,
    required this.onIsbnScan,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Book', style: Theme.of(context).textTheme.headlineSmall),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('How would you like to add a book?',
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Flexible(
                  child: StylizedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onManualAdd();
                    },
                    text: 'Write Manual',
                    width: 150,
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: StylizedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onIsbnScan();
                    },
                    text: 'ISBN Scan',
                    width: 150,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
      backgroundColor: Theme.of(context).dialogBackgroundColor,
    );
  }
}