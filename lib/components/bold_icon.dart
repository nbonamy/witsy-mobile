import 'package:flutter/cupertino.dart';

class BoldIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color? color;

  const BoldIcon({
    super.key,
    required this.icon,
    this.size = 18,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontSize: size,
        fontWeight: FontWeight.w900,
        color: color,
        fontFamily: icon.fontFamily,
        package: icon.fontPackage,
      ),
    );
  }
}
