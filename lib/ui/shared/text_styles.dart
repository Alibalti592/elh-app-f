import 'package:flutter/material.dart';
import 'package:elh/common/theme.dart';

const subHeaderStyle = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
    color: Color.fromRGBO(55, 65, 81, 1));
const titleStyle = TextStyle(
    fontSize: 19.0,
    color: Color.fromRGBO(55, 65, 81, 1),
    fontWeight: FontWeight.w900);
const inTitleStyle = TextStyle(
    fontSize: 16.0,
    color: Color.fromRGBO(55, 65, 81, 1),
    fontWeight: FontWeight.w900);
const headerText = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 18,
    color: Colors.white,
    fontFamily: 'inter');
const headerTextWhite = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 17,
    color: Colors.white,
    fontFamily: 'inter');
const linkStyle = TextStyle(fontSize: 15, color: primaryColor);
const linkStyleBold =
    TextStyle(fontSize: 15, color: primaryColor, fontWeight: FontWeight.w700);
const textDescription =
    TextStyle(color: Color.fromRGBO(55, 65, 81, 1), fontSize: 14);
const labelSmallStyle = TextStyle(
  fontFamily: 'Karla',
  fontWeight: FontWeight.w600,
  color: Color.fromRGBO(55, 65, 81, 1),
  fontSize: 12.0,
);
const labelSmallStyleB = TextStyle(
  fontFamily: 'inter',
  fontWeight: FontWeight.w600,
  color: Color.fromRGBO(55, 65, 81, 1),
  fontSize: 13.0,
);
const noResultStyle = TextStyle(
  fontFamily: 'inter',
  fontWeight: FontWeight.w600,
  color: Color.fromRGBO(55, 65, 81, 1),
  fontSize: 15.0,
);
const noResultStyleDark = TextStyle(
  fontFamily: 'inter',
  fontWeight: FontWeight.w600,
  color: Color.fromRGBO(55, 65, 81, 1),
  fontSize: 15.0,
);

class GradientText extends StatelessWidget {
  GradientText(
    this.text, {
    required this.gradient,
  });

  final String text;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(
        text,
        style: TextStyle(
          // The color must be set to white for this to work
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
  }
}
