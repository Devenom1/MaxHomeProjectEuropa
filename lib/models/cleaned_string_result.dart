
import 'dart:collection';

class CleanedStringResult {
  String originalString;
  HashMap<int, List<String>> removedSequences;
  String cleanedString;

  CleanedStringResult(this.originalString, this.removedSequences, this.cleanedString);
}