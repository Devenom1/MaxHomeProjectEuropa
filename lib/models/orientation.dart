
class Orientation {
  final String cardinalAbbr;
  final String cardinalName;
  final String symbol;
  final int rotation;
  final double turns;

  const Orientation(this.cardinalAbbr, this.cardinalName, this.symbol, this.rotation, this.turns);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Orientation &&
        other.cardinalAbbr == cardinalAbbr &&
        other.cardinalName == cardinalName &&
        other.symbol == symbol &&
        other.rotation == rotation &&
        other.turns == turns;
  }

  @override
  int get hashCode =>
      cardinalAbbr.hashCode ^
      cardinalName.hashCode ^
      symbol.hashCode ^
      rotation.hashCode ^
      turns.hashCode;
}