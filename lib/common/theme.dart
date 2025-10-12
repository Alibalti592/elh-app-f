import 'package:flutter/material.dart';
import 'package:elh/common/elh_icons.dart';
import 'package:elh/services/Extension/ColorExtension.dart';
import 'package:elh/ui/widgets/GradientSliderThemeData.dart';

// const Color primaryColor = Color(0xFFB49D7E);
const Color primaryColor = Color(0xFF8F9779); // Olive green (matches button)
const Color primaryColorLight = Color(0xFFDCCFBF); // Beige/cream
const Color primaryColorMiddle = Color(0xFFB5BCA1); // Light olive tint

const Color elhV2Color1 = Color(0xFF8F9779);
const Color elhV2Color2 = Color(0xFFDCCFBF);
const Color elhV2Color3 = Color(0xFFB5BCA1);
const Color elhV2Color4 = Color.fromRGBO(220, 198, 169, 1);

const Color raceColor = Color(0xFF444444);
const Color bgLight = Color(0xFFFFFFFF);
const Color bgLightV2 = Color(0xFFFFFFFF);
const Color bgLightCard = Color(0xFFFFFFFF);
// const Color bgLightV2 = Color(0xffc2bfad);
const Color bgUltraLight = Color(0xFFfbfbfb);
const Color bgDark = Color(0xFF313131);
const Color bgDarken = Color(0xFF292929);
const Color white = Color(0xFFFFFFFF);
const Color bgWhite = white;
const Color fontGrey = Color(0xFF999999);
const Color fontGreyLight = Color(0xFFcfd0d2);
const Color fontGreyTitle = Color(0xffa69f92);
const Color fontGreyDark = Color.fromRGBO(55, 65, 81, 1);
const Color fontDark = Color.fromRGBO(55, 65, 81, 1);
const Color fontDarkPrimary = Color(0xFF72562B);
const Color fontGreyBrown = Color(0xff918d86);
const Color borderGrey = Color(0xFFccd0d5);
const Color bgGrey = Color(0xFFefefef);
const Color successColor = Color(0xFF66bb6a);
const Color greenElh = Color(0xFF8F9779);
const Color errorColor = Color(0xFFFA3E3E);
const textCommu =
    "Créez votre communauté pour échanger, partager des cartes virtuelles et gérer vos dettes et emprunts facilement. "
    "Quand vous ajoutez un prêt, un emprunt ou une amana avec un membre de votre communauté, cela apparaîtra directement sur son tableau de bord."
    "Pour donner un accès privé de votre testament à un ou plusieurs membres de votre communauté, il faudra valider ce partage via la page testament.";

const shadow1 = [
  BoxShadow(
      color: Color.fromARGB(15, 0, 0, 0),
      spreadRadius: 2,
      blurRadius: 6,
      offset: Offset(0, 3)),
];

// FONT STYLE
TextStyle smallText = TextStyle(color: fontGrey, fontSize: 11);

SweepGradient bblinearGradient() {
  return SweepGradient(
    center: const FractionalOffset(0.8, 0.3),
    colors: const [
      Color(0xFFe9e4e0),
      Color(0xFFdad1c8),
      Color(0xFFcbbfaf),
      Color(0xFFc5b9a9),
      Color(0xFFd4c1c5),
    ],
    stops: const <double>[0.0, 0.35, 0.5, 0.75, 1.0],
  );
}

backgroundImageSimple() {
  return const DecorationImage(
      image: AssetImage('assets/images/bg.png'),
      fit: BoxFit.cover,
      opacity: 0.7);
}

LinearGradient bblinearGradientV2() {
  return LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.bottomRight,
      colors: [elhV2Color1, elhV2Color2, elhV2Color3, elhV2Color4]);
}

SliderThemeData elhBaseSliderThemeData() {
  return SliderThemeData(
    thumbColor: Colors.black87,
    valueIndicatorTextStyle: const TextStyle(color: Colors.white),
    valueIndicatorColor: primaryColor,
    trackHeight: 8,
    trackShape: GradientSliderThemeData(
        gradient: bblinearGradientV2(), darkenInactive: false),
  );
}

Shader textLinearGradient = const LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [primaryColorLight, primaryColorMiddle, primaryColor],
).createShader(Rect.fromCircle(
  center: Offset(16, -50),
  radius: 16 / 3,
));

Color darken(Color color, [double amount = .1]) {
  assert(amount >= 0 && amount <= 1);

  final hsl = HSLColor.fromColor(color);
  final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

  return hslDark.toColor();
}

Color lighten(Color color, [double amount = .1]) {
  assert(amount >= 0 && amount <= 1);

  final hsl = HSLColor.fromColor(color);
  final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

  return hslLight.toColor();
}

// FORM
InputDecoration bbInputDecoration(name) {
  return InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide:
            const BorderSide(color: Color.fromRGBO(229, 231, 235, 1), width: 2),
      ),
      labelStyle: const TextStyle(color: Color.fromRGBO(55, 65, 81, 1)),
      focusColor: fontGreyDark,
      floatingLabelStyle: TextStyle(
          color: fontGreyDark, backgroundColor: Colors.white.withOpacity(0.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      filled: true,
      fillColor: white,
      labelText: name);
}

List<Color> gradientColors = [
  Color.fromRGBO(220, 198, 169, 1.0), // light beige
  Color.fromRGBO(143, 151, 121, 1.0), // olive green
];

final appTheme = ThemeData(
  useMaterial3: false,
  primaryColor: primaryColor,
  primaryColorLight: primaryColorLight,
  fontFamily: 'inter',
  scaffoldBackgroundColor: Colors.white,
  primarySwatch: Colors.grey,
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: greenElh,
    foregroundColor: Colors.white,
    elevation: 3,
  ),
  switchTheme: SwitchThemeData(
    thumbColor: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
      if (states.contains(MaterialState.selected)) {
        return Colors.lightGreen[100];
      }
      if (states.contains(MaterialState.disabled)) {
        return Colors.grey[100];
      }
      return Colors.red[100];
    }),
    trackColor: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
      if (states.contains(MaterialState.selected)) {
        return Colors.lightGreen[400];
      }
      if (states.contains(MaterialState.disabled)) {
        return Colors.grey;
      }
      return Colors.red[400];
    }),
  ),
  appBarTheme: AppBarTheme(
    elevation: 0,
    backgroundColor: Colors.transparent, // ✅ transparent to show gradient
    foregroundColor: Colors.black,
    iconTheme: const IconThemeData(color: Colors.black),
    actionsIconTheme: const IconThemeData(color: Colors.black),
    titleTextStyle: const TextStyle(
      fontFamily: 'inter',
      fontWeight: FontWeight.w600,
      fontSize: 18,
      color: Colors.black,
    ),
  ),
  iconTheme: const IconThemeData(color: Colors.black),
  navigationDrawerTheme: NavigationDrawerThemeData(
    iconTheme: MaterialStateProperty.all(
      const IconThemeData(color: Colors.black),
    ),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    border: OutlineInputBorder(
      borderSide: BorderSide(color: bgGrey, width: 2),
      borderRadius: BorderRadius.all(Radius.circular(2)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(2.0)),
      borderSide: BorderSide(color: bgGrey, width: 2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(2.0)),
      borderSide: BorderSide(color: primaryColor, width: 2),
    ),
    filled: true,
    fillColor: white,
  ),
  textTheme: const TextTheme(
    labelLarge: TextStyle(
      fontFamily: 'inter',
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: Colors.black,
    ),
    displayLarge: TextStyle(
      fontFamily: 'inter',
      fontSize: 27,
      fontWeight: FontWeight.w700,
      color: Colors.black,
    ),
    displayMedium: TextStyle(
      fontFamily: 'HelveticaNeu',
      fontWeight: FontWeight.w700,
      fontSize: 24,
      color: Colors.black,
    ),
    titleLarge: TextStyle(color: Colors.black),
  ),
);
