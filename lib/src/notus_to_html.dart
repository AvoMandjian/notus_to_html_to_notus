import 'dart:convert';

import 'package:zefyrka/zefyrka.dart';

import 'models/notus_node.dart';

class NotusToHTML {
  static List<NotusNode> _getJsonLine(var node) {
    String childString = jsonEncode(node.toDelta());
    List<NotusNode> line = List<NotusNode>.from(
        jsonDecode(childString).map((i) => NotusNode.fromJson(i)));
    return line;
  }

  static getHtmlFromNotus(NotusDocument notusDocument) {
    String html = '';
    for (int i = 0; i < notusDocument.root.children.length; i++) {
      List<NotusNode> notusDocLine =
          _getJsonLine(notusDocument.root.children.elementAt(i));
      if (notusDocument.root.children.elementAt(i).runtimeType == LineNode) {
        html = html + _decodeNotusLine(notusDocLine);
      } else if (notusDocument.root.children.elementAt(i).runtimeType ==
          BlockNode) {
        html = html + _decodeNotusBlock(notusDocLine);
      }
    }
    return html.replaceAll('\n', '');
  }

  static _getLineAttributes(NotusNode notusModel) {
    if (notusModel.attributes == null ||
        notusModel.attributes!.color is String ||
        notusModel.attributes!.backgroundColor is String) {
      return ['<p>', '</p>'];
    } else if (notusModel.attributes!.heading == 1) {
      return ['<h1>', '</h1>'];
    } else if (notusModel.attributes!.heading == 2) {
      return ['<h2>', '</h2>'];
    } else if (notusModel.attributes!.heading == 3) {
      return ['<h3>', '</h3>'];
    } else if (notusModel.attributes!.b == true) {
      return ['<b>', '</b>'];
    } else if (notusModel.attributes!.s == true) {
      return ['<s>', '</s>'];
    } else if (notusModel.attributes!.u == true) {
      return ['<u>', '</u>'];
    } else if (notusModel.attributes!.i == true) {
      return ['<i>', '</i>'];
    }
    //  else if (notusModel.attributes!.color is String) {
    //   return [
    //     '<p style="color:${notusModel.attributes!.color}; text-decoration-color:${notusModel.attributes!.color};">',
    //     '</p>'
    //   ];
    // } else if (notusModel.attributes!.backgroundColor is String) {
    //   return [
    //     '<p style="background-color:${notusModel.attributes!.backgroundColor};">',
    //     '</p>'
    //   ];
    // }
  }

  static _getBlockAttributes(NotusNode notusModel) {
    if (notusModel.attributes!.block == 'ul') {
      return ['<ul>', '</ul>'];
    } else if (notusModel.attributes!.block == 'ol') {
      return ['<ol>', '</ol>'];
    }
  }

  static _decodeNotusLine(List<NotusNode> notusDocLine) {
    String html = '';
    List<String> attributes =
        _getLineAttributes(notusDocLine.elementAt(notusDocLine.length - 1));
    html = attributes[0] + _decodeLineChildren(notusDocLine) + attributes[1];
    return html;
  }

  static String _decodeLineChildren(List<NotusNode> notusDocLine) {
    String html = '';
    for (int i = 0; i < notusDocLine.length; i++) {
      if (notusDocLine.elementAt(i).attributes == null) {
        html = html + notusDocLine.elementAt(i).insert!;
      } else {
        String element = notusDocLine.elementAt(i).insert!;
        String? color = notusDocLine.elementAt(i).attributes?.color;
        String? backgroundColor =
            notusDocLine.elementAt(i).attributes?.backgroundColor;
        if (color != null) {
          element =
              '<span style="color:${color}; text-decoration-color:${color};">' +
                  element +
                  '</span>';
        }
        if (backgroundColor != null) {
          element = '<span style="background-color:${backgroundColor};">' +
              element +
              '</span>';
        }
        if (notusDocLine.elementAt(i).attributes!.b == true) {
          element = '<b>' + element + '</b>';
        }
        if (notusDocLine.elementAt(i).attributes!.s == true) {
          element = '<s>' + element + '</s>';
        }
        if (notusDocLine.elementAt(i).attributes!.u == true) {
          element = '<u>' + element + '</u>';
        }
        if (notusDocLine.elementAt(i).attributes!.i == true) {
          element = '<i>' + element + '</i>';
        }
        html = html + element;
      }
    }
    return html;
  }

  static String _decodeNotusBlock(List<NotusNode> notusDocLine) {
    String html = '';
    String childrenHtml = '';
    List<List<NotusNode>> blockLinesList = _splitBlockIntoLines(notusDocLine);

    List<String> attributes =
        _getBlockAttributes(notusDocLine.elementAt(notusDocLine.length - 1));
    for (int i = 0; i < blockLinesList.length; i++) {
      childrenHtml = childrenHtml +
          '<li>' +
          _decodeLineChildren(blockLinesList.elementAt(i)) +
          '</li>';
    }

    html = attributes[0] + childrenHtml + attributes[1];
    return html;
  }

  static _splitBlockIntoLines(List<NotusNode> notusDocLine) {
    List<List<NotusNode>> blockLinesList = [];
    List<int> sublistBreakPoints = [];

    for (int i = 0; i < notusDocLine.length; i++) {
      if (notusDocLine.elementAt(i).insert == '\n') {
        sublistBreakPoints.add(i);
      }
    }

    for (int i = 0; i < sublistBreakPoints.length; i++) {
      if (i == 0) {
        blockLinesList
            .add(notusDocLine.sublist(i, sublistBreakPoints.elementAt(i)));
      } else {
        if (i < sublistBreakPoints.length - 1) {
          blockLinesList.add(notusDocLine.sublist(
              sublistBreakPoints.elementAt(i - 1),
              sublistBreakPoints.elementAt(i)));
        } else {
          blockLinesList.add(notusDocLine.sublist(
              sublistBreakPoints.elementAt(i - 1), notusDocLine.length - 1));
        }
      }
    }
    return blockLinesList;
  }
}
