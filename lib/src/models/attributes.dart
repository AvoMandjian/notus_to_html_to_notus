class UtilFunctions {
  static String? intToHex(int? i) {
    if (i == null) {
      return null;
    }
    assert(i >= 0 && i <= 0xFFFFFFFF);
    return '#${(i & 0xFFFFFF | 0x1000000).toRadixString(16).substring(1).toUpperCase()}';
  }

  static int hexToInt(String hex) {
    final hexDigits = hex.startsWith('#') ? hex.substring(1) : hex;
    final hexMask = hexDigits.length <= 6 ? 0xFF000000 : 0;
    final hexValue = int.parse(hexDigits, radix: 16);
    assert(hexValue >= 0 && hexValue <= 0xFFFFFFFF);
    return hexValue | hexMask;
  }
}

class Attributes {
  int? heading = 0;
  String? block = '';
  bool? b = false;
  bool? i = false;
  bool? u = false;
  bool? s = false;
  String? a;
  String? color;
  String? backgroundColor;

  /* NotusAttribute.italic
  NotusAttribute.link*/

  Attributes({
    this.heading,
    this.block,
    this.b,
    this.i,
    this.u,
    this.s,
    this.a,
    this.color,
    this.backgroundColor,
  });

  factory Attributes.fromJson(dynamic json) {
    return Attributes(
      heading: json['heading'],
      block: json['block'],
      b: json['b'],
      i: json['i'],
      u: json['u'],
      s: json['s'],
      a: json['a'],
      color: UtilFunctions.intToHex(json['color']),
      backgroundColor: UtilFunctions.intToHex(json['background-color']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'heading': heading,
      'block': block,
      'b': b,
      'i': i,
      'u': u,
      's': s,
      'a': a,
      'color': color,
      'background-color': backgroundColor,
    };
  }
}
