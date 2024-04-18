import 'package:html/parser.dart';
import 'package:notus_to_html_to_notus/notus_to_html_to_notus.dart';
import 'package:zefyrka/zefyrka.dart';

class HtmlToNotus {
  static NotusDocument getNotusFromHtml(var text) {
    final document = NotusDocument();
    var data = parse(text.toString().replaceAll('\n', '')).body;
    if (data == null) {
      return document;
    }
    if (data.nodes.isEmpty) return document;
    document.replace(0, document.length, '');
    for (int i = 0; i < data.nodes.length; i++) {
      if (data.nodes[i].toString().contains('<html h1>')) {
        LineNode line = LineNode();
        line.add(LeafNode(data.nodes[i].text!.replaceAll('\n', '')));
        line.applyAttribute(NotusAttribute.h1);
        document.root.add(line);
      } else if (data.nodes[i].toString().contains('<html h2>')) {
        LineNode line = LineNode();
        line.add(LeafNode(data.nodes[i].text!.replaceAll('\n', '')));
        line.applyAttribute(NotusAttribute.h2);
        document.root.add(line);
      } else if (data.nodes[i].toString().contains('<html h3>')) {
        LineNode line = LineNode();
        line.add(LeafNode(data.nodes[i].text!.replaceAll('\n', '')));
        line.applyAttribute(NotusAttribute.h3);
        document.root.add(line);
      } else if (data.nodes[i].toString().contains('<html p>')) {
        LineNode line = LineNode();
        line = _formatParagraph(data.nodes[i]);
        document.root.add(line);
      } else if (data.nodes[i].toString().contains('<html ul>')) {
        BlockNode block = BlockNode();
        block = _formatBlock(data.nodes[i], NotusAttribute.block.bulletList);
        document.root.add(block);
      } else if (data.nodes[i].toString().contains('<html ol>')) {
        BlockNode block = BlockNode();
        block = _formatBlock(data.nodes[i], NotusAttribute.block.numberList);
        document.root.add(block);
      }
    }
    return document;
  }

  static _getChildrenAttributes(var node) {
    List<String> attributes = [];
    for (var child in node.children) {
      attributes.addAll(_getChildrenAttributes(child));
    }

    if (node.toString().contains('<html b>')) {
      attributes.add('b');
    } else if (node.toString().contains('<html u>')) {
      attributes.add('u');
    } else if (node.toString().contains('<html a>')) {
      attributes.add('a_tag_href:${node.attributes['href']}');
    } else if (node.toString().contains('<html i>')) {
      attributes.add('i');
    } else if (node.attributes['style'] != null) {
      attributes.add(node.attributes['style']);
    }

    return attributes;
  }

  static _formatParagraph(var line) {
    LineNode lineNode = LineNode();
    for (int j = 0; j < line.nodes.length; j++) {
      LeafNode leaf = LeafNode(line.nodes[j].text);
      List<String> attributes = _getChildrenAttributes(line.nodes[j]);
      for (String attribute in attributes) {
        if (attribute == 'b') {
          leaf.applyAttribute(NotusAttribute.bold);
        }
        try {
          List<String> listOfAttributes = attribute.split(':');
          if (listOfAttributes.first == 'a_tag_href') {
            listOfAttributes.remove('a_tag_href');
            leaf.applyAttribute(
                NotusAttribute.link.fromString(listOfAttributes.join()));
          }
        } catch (_) {}
        if (attribute == 'u') {
          leaf.applyAttribute(NotusAttribute.underline);
        }
        if (attribute == 'i') {
          leaf.applyAttribute(NotusAttribute.italic);
        }
        if (attribute.contains('background-color')) {
          try {
            String hexColor = attribute.split(':').last.replaceAll(';', '');
            leaf.applyAttribute(NotusAttribute.backgroundColor
                .fromInt(UtilFunctions.hexToInt(hexColor)));
          } catch (e) {
            print(e);
          }
        } else if (attribute.contains('color')) {
          try {
            String hexColor = attribute.split(':').last.replaceAll(';', '');
            leaf.applyAttribute(
                NotusAttribute.color.fromInt(UtilFunctions.hexToInt(hexColor)));
          } catch (e) {
            print(e);
          }
        }
      }

      lineNode.add(leaf);
    }
    return lineNode;
  }

  static _formatBlock(var line, NotusAttribute attribute) {
    BlockNode block = BlockNode();
    block.applyAttribute(attribute);
    for (int j = 0; j < line.nodes.length; j++) {
      if (line.nodes[j].toString().contains('<html li>')) {
        LineNode lineNode = LineNode();
        lineNode = _formatParagraph(line.nodes[j]);
        block.add(lineNode);
      }
    }
    return block;
  }
}
