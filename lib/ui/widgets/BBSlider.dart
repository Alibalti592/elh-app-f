import 'package:flutter/material.dart';
import 'package:elh/common/theme.dart';
import 'package:elh/ui/widgets/GradientSliderThemeData.dart';

class BBSlider {
//  ('Stress', model.stressLabelOnChange, model.dayInfos.stress, model.dayInfos.labels.stress, model, 'stress', 1, 7)
  static Widget sliderStepData( title, currentLabel, currentValue, labels, model, dataName, minVal, maxVal) {
    return  Column(
      children: [
        Text(title, style: TextStyle(color: fontGrey, fontWeight: FontWeight.bold)),
        Container(
            transform: Matrix4.translationValues(0.0, 8.0, 0.0),
            child: Text(currentLabel, style: TextStyle(color: fontDark))),
        SliderTheme(
          data: SliderThemeData(
            thumbColor: Colors.black87,
            valueIndicatorTextStyle: TextStyle(color: Colors.white),
            valueIndicatorColor: primaryColor,
            trackHeight: 10,
            trackShape: GradientSliderThemeData(gradient: bblinearGradientV2(), darkenInactive: false),
          ),
          child: Slider(
            value: currentValue.toDouble(),
            onChanged: (newValue) {
              model.updateFormData(dataName, newValue);
            },
            divisions: (maxVal - minVal).toInt(),
            min: minVal.toDouble(),
            max: maxVal.toDouble(),
            label: currentLabel,
          ),
        ),
        Container(
          transform: Matrix4.translationValues(0.0, -10.0, 0.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
                children: [
                  Expanded(child: Text(labels[0], style: TextStyle(color: fontGrey, fontSize: 11))),
                  Expanded(child:
                  Text(labels[6], style: TextStyle(color: fontGrey, fontSize: 11), textAlign: TextAlign.right,)),
                ]
            ),
          ),
        ),
      ],
    );
  }
}