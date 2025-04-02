import 'package:flutter/material.dart';
import 'package:maxhome_europa/extensions/string_extensions.dart';
import 'package:maxhome_europa/models/cleaned_string_result.dart';

class OptimizePathDialog extends StatefulWidget {
  final String currentPath;
  final Function(String) onOptimize;
  final Function onCancel;

  const OptimizePathDialog({
    super.key,
    required this.currentPath,
    required this.onOptimize,
    required this.onCancel,
  });

  @override
  State<OptimizePathDialog> createState() => _OptimizePathDialogState();
}

class _OptimizePathDialogState extends State<OptimizePathDialog> {
  //bool _includeAdvancedOptimization = false;

  String optimisedStringMessage = "These are the strings removed";

  Widget removedSequencesTextWidget(List<String> removedSequences) {
    return SelectableText.rich(
      TextSpan(
       children: [
         for (int i = 0; i < removedSequences.length; i++) ...[
           TextSpan(text: removedSequences[i], style: TextStyle(color: Colors.redAccent)),
           if (i != removedSequences.length - 1) TextSpan(text: ", "),
         ]
       ]
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    CleanedStringResult cleanedStringResult = widget.currentPath.optimisePath();
    for (var (_, match) in cleanedStringResult.removedSequences.entries.indexed) {
      optimisedStringMessage += "\n";
      optimisedStringMessage += "Run ${match.key}: ${match.value.join(',')}";
    }

    Table runTable = Table(
      defaultColumnWidth: IntrinsicColumnWidth(),
      border: TableBorder(
          top: BorderSide(),
          bottom: BorderSide(),
          left: BorderSide(),
          right: BorderSide(),
        horizontalInside: BorderSide()
      ),
      children: cleanedStringResult.removedSequences.entries
          .map((rs) =>
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.all(4),
              child: Text("Run ${rs.key}"),
            ),
            SizedBox(width: 16),
            Padding(
              padding: const EdgeInsets.all(4),
              child: removedSequencesTextWidget(rs.value),
            )
          ]
        )
      ).toList(),
    );

    return AlertDialog(
      title: const Text('Optimize Path'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current path length: ${widget.currentPath.length} steps',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            'Optimised path length: ${cleanedStringResult.cleanedString.length} steps',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SelectableText.rich(
            TextSpan(
              children: [
                TextSpan(text: 'Optimizing will remove the unwanted turns that will lead you to the same position. '),
                TextSpan(text: '\n\nThis is your original path '),
                TextSpan(
                    text: cleanedStringResult.originalString,
                    style: TextStyle(
                        color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 16
                    ),
                ),
                TextSpan(text: "\n\nYour new string is now: "),
                if (cleanedStringResult.cleanedString.isEmpty)
                  TextSpan(
                      text: "Empty",
                      style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                  ),
                if (cleanedStringResult.cleanedString.isNotEmpty)
                  TextSpan(
                    text: cleanedStringResult.cleanedString,
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                  ),
              ]
            )
          ),
          const SizedBox(height: 16),
          Text(
            "The following unwanted turns can me removed after ${cleanedStringResult.removedSequences.length} run${(cleanedStringResult.removedSequences.length > 1) ? "s." : "."}",
          ),
          const SizedBox(height: 8),
          runTable,
          const SizedBox(height: 36),
          Text(
            "NOTE: You can ignore optimisation if you want the robot to go in circles to explore!",
            style: TextStyle(fontSize: 12),
          ),
          /*CheckboxListTile(
            title: const Text('Use advanced optimization'),
            subtitle: const Text('May take longer but produce better results'),
            value: _includeAdvancedOptimization,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            onChanged: (value) {
              setState(() {
                _includeAdvancedOptimization = value ?? false;
              });
            },
          ),*/
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onCancel.call();
            Navigator.of(context).pop();
          },
          child: const Text('IGNORE'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            widget.onOptimize(widget.currentPath.optimisePath().cleanedString);
          },
          child: const Text('OPTIMIZE'),
        ),
      ],
    );
  }

}