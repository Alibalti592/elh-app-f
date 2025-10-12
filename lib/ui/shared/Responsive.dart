import 'package:flutter/material.dart';

/// Permet de définir une taille en %, Container(height: Responsive.width(80, context), width: Responsive.width(50, context)); => 80%, 50%
class Responsive{
  static width(double p,BuildContext context, {offset= 0})
  {
    return (MediaQuery.of(context).size.width - offset)*(p/100);
  }
  static height(double p,BuildContext context)
  {
    return MediaQuery.of(context).size.height*(p/100);
  }
}