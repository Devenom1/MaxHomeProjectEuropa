
import 'dart:collection';

import 'package:maxhome_europa/constants.dart';
import 'package:maxhome_europa/models/cleaned_string_result.dart';

extension PathExtensions on String {

  bool isPathOptimised() => !contains(RegExp(Constants.repetitiveMovesRegex));

  CleanedStringResult optimisePath() {
    String returnPath = this;
    HashMap<int, List<String>> removedSequencesMap = HashMap();
    
    final regex = RegExp(Constants.repetitiveMovesRegex);
    int i = 1;
    while(!returnPath.isPathOptimised()) {
      print("Optimising string: $returnPath");
      List<String> removedSequences = regex.allMatches(returnPath).map((match) =>
          match.group(0)).whereType<String>().toList();
      removedSequencesMap[i++] = removedSequences;
      returnPath = returnPath.replaceAll(regex, "");
      print("Optimised string: $returnPath");
    }
    return CleanedStringResult(this, removedSequencesMap, returnPath);
  }

}