import 'dart:io';

class FodlerTree {
  final String name;
  final List<FodlerTree> subTree;

  FodlerTree(this.name, this.subTree);

  String deepToString([int deep = 0]) {
    final sb = StringBuffer('${' ' * deep}${name}');
    sb.writeln();
    sb.write(subTree.map((tree) => tree.deepToString(deep + 4)).join());
    return sb.toString();
  }

  @override
  String toString() => deepToString(0);
}

void main(List<String> arguments) {
  if (arguments.isEmpty) {
    print('Need to pass a file');
    return;
  }

  final file = File(arguments.first);
  final lines = file.readAsLinesSync();
  final trees = constructTreeFromLines(lines, deep: 0);
  for (final tree in trees) {
    deepCreateFolder(tree, path: '.');
  }
}

void deepCreateFolder(FodlerTree tree, {String path}) {
  final _path = '$path${Platform.pathSeparator}${tree.name}';
  Directory(_path).createSync(recursive: true);
  for (final _tree in tree.subTree) {
    deepCreateFolder(_tree, path: _path);
  }
}

int numberOfStart(String line) {
  var count = 0;
  while (true) {
    count++;
    if (!line.startsWith('${' ' * count}')) {
      return count - 1;
    }
  }
}

List<FodlerTree> constructTreeFromLines(List<String> lines, {int deep}) {
  final trees = <FodlerTree>[];
  for (var i = 0; i < lines.length; i++) {
    final line = lines.elementAt(i);
    final number = numberOfStart(lines[i]);
    if (number != deep) {
      continue;
    }
    var subTree = <FodlerTree>[];
    if (lines.length > 1 && lines.elementAt(1).startsWith('${' ' * deep}') ||
        lines.length > 1 &&
            lines.elementAt(1).startsWith('${'\t' * (deep ~/ 4)}')) {
      subTree =
          constructTreeFromLines([...lines.sublist(i + 1)], deep: deep + 4);
    }
    trees.add(FodlerTree(line.substring(number), subTree));
  }
  return trees;
}
