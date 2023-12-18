// ignore_for_file: avoid_print

import "dart:io";

import "package:cli_spinner/cli_spinner.dart";
import "package:path/path.dart";
import "package:process_run/process_run.dart";
import "package:tint/tint.dart";

Future<void> main() async {
  var shell = Shell(verbose: false, commandVerbose: false);
  var spinner = Spinner.type("generating source map".dim(), SpinnerType.dots)..start();
  try {
    var result = await shell.run("where flutter");
    if (result.isEmpty) {
      print("no flutter executable found".yellow());
      return;
    }
    var location = dirname(dirname(result.outLines.first));
    var iconsFile = File(join(location, "packages", "flutter", "lib", "src", "material", "icons.dart"));
    if (!iconsFile.existsSync()) {
      print("unable to locate material icons file".red());
      return;
    }
    var iconsContent = await iconsFile.readAsString();
    var lines = iconsContent.split("\n");
    var iconRegExp = RegExp(r"static const IconData (?<name>[Aa-zZ\-\_]*) = IconData\((?<hex>0[xX][0-9a-fA-F]+), fontFamily: 'MaterialIcons'\)");
    StringBuffer outSource = StringBuffer('import "package:flutter/material.dart";');
    StringBuffer hexMap = StringBuffer("const materialIconsHexMap = {");
    StringBuffer namesMap = StringBuffer("const materialIconsNameMap = {");

    var existingHexes = {};
    for (final line in lines) {
      var match = iconRegExp.firstMatch(line);
      if (match == null) continue;
      var name = match.namedGroup("name");
      var hexGroup = match.namedGroup("hex");
      if (name == null || hexGroup == null) continue;
      var hex = int.tryParse(hexGroup);
      if (hex == null) continue;
      namesMap.write('"$name": const IconData($hex, fontFamily: "MaterialIcons"),');
      if (existingHexes.containsKey(hex)) continue;
      hexMap.write('$hex: const IconData($hex, fontFamily: "MaterialIcons"),');
      existingHexes[hex] = true;
    }
    namesMap.write("};");
    hexMap.write("};");
    outSource.write(namesMap.toString());
    outSource.write(hexMap.toString());
    spinner.updateMessage("fixing and formatting file".dim());
    await File(join("lib/src/gen/material_icons_g.dart")).writeAsString(outSource.toString());
    await shell.run("dart fix --apply lib/src/gen");
    await shell.run("dart format lib/src/gen");
    spinner.stop();
    print("material icons map generated".green());
  } catch (error) {
    spinner.stop();
    print("unable to complete generation $error".red());
  }
}
