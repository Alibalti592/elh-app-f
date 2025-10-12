import 'package:flutter/material.dart';
import 'package:flutter_placeholder_textlines/flutter_placeholder_textlines.dart';
import 'package:elh/common/theme.dart';

/// Contains useful functions to reduce boilerplate code
class UIHelper {
  // Vertical spacing constants. Adjust to your liking.
  static const double _VerticalSpaceSmall = 10.0;
  static const double _VerticalSpaceMedium = 20.0;
  static const double _VerticalSpaceLarge = 60.0;

  // Vertical spacing constants. Adjust to your liking.
  static const double _HorizontalSpaceSmall = 10.0;
  static const double _HorizontalSpaceMedium = 20.0;
  static const double HorizontalSpaceLarge = 60.0;

  /// Returns a vertical space with height set to [_VerticalSpaceSmall]
  static Widget verticalSpaceSmall() {
    return verticalSpace(_VerticalSpaceSmall);
  }

  /// Returns a vertical space with height set to [_VerticalSpaceMedium]
  static Widget verticalSpaceMedium() {
    return verticalSpace(_VerticalSpaceMedium);
  }

  /// Returns a vertical space with height set to [_VerticalSpaceLarge]
  static Widget verticalSpaceLarge() {
    return verticalSpace(_VerticalSpaceLarge);
  }

  /// Returns a vertical space equal to the [height] supplied
  static Widget verticalSpace(double height) {
    return Container(height: height);
  }

  /// Returns a vertical space with height set to [_HorizontalSpaceSmall]
  static Widget horizontalSpaceSmall() {
    return horizontalSpace(_HorizontalSpaceSmall);
  }

  /// Returns a vertical space with height set to [_HorizontalSpaceMedium]
  static Widget horizontalSpaceMedium() {
    return horizontalSpace(_HorizontalSpaceMedium);
  }

  /// Returns a vertical space with height set to [HorizontalSpaceLarge]
  static Widget horizontalSpaceLarge() {
    return horizontalSpace(HorizontalSpaceLarge);
  }

  /// Returns a vertical space equal to the [width] supplied
  static Widget horizontalSpace(double width) {
    return Container(width: width);
  }

  static Widget listSeperatorTitle(text, horizontalPadding, verticalPadding) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding, vertical: verticalPadding),
      child: Center(
        // centers the child
        child: Text(
          text,
          textAlign: TextAlign.center, // ensure the text itself is centered
          style: const TextStyle(
            color: fontGrey,
          ),
        ),
      ),
    );
  }

  static Widget titleBordered(text, horizontalPadding, verticalPadding,
      {icon, fontSize = 15.0}) {
    return Container(
      margin: EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: bgGrey, width: 2))),
      padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding, vertical: verticalPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          icon != null
              ? Container(
                  child: Icon(icon),
                  margin: EdgeInsets.only(right: 8),
                )
              : Container(),
          Text(text,
              style: TextStyle(
                  color: fontDark,
                  fontWeight: FontWeight.bold,
                  fontSize: fontSize))
        ],
      ),
    );
  }

  static Widget dotNotif(show, rightPosition, topPosisition) {
    return show
        ? Positioned(
            right: rightPosition,
            top: topPosisition,
            child: new Container(
              padding: EdgeInsets.all(1),
              decoration: new BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: white, width: 1)),
              constraints: BoxConstraints(
                minWidth: 12,
                minHeight: 12,
              ),
            ),
          )
        : Container();
  }

  static Widget lineLoaders(number, height) {
    return Container(
      child: Center(
        child: PlaceholderLines(
          count: number,
          animate: true,
          lineHeight: height.toDouble(),
          color: Color(0xFFC9C9C9),
        ),
      ),
    );
  }

  static Widget h1(text) {
    return Text(text,
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold));
  }

  static Widget h3(text) {
    return Text(text,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold));
  }
}
