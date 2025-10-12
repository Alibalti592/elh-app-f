import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:elh/common/theme.dart';

class InputDistance {
  TextEditingController distanceTextController = new TextEditingController();
  ValueNotifier<String> distanceUnit = ValueNotifier<String>('km');
  num? distanceByUnit;
  ValueNotifier<int> distanceInmeters = ValueNotifier<int>(0); //value of object
  FocusNode focusNode = new FocusNode();

  void setDistance(distanceString) {
    if(distanceString == null || distanceString == 0) {
      distanceString =  "";
    } else {
      if(this.distanceUnit.value == 'm') {
        this.distanceInmeters.value = int.parse(distanceString);
      } else {
        this.distanceInmeters.value = int.parse(distanceString)*1000;
      }
    }
  }

  initilialiseDistance(initialValue) {
    this.distanceInmeters.value = initialValue;
  }

  changeDistanceUnit(unit) {
    this.distanceUnit.value = unit;
  }

  Widget getWidget(valueToSet) {
    this.initilialiseDistance(valueToSet);
    return Container(
      height: 58,
      child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(top:0),
              child: ValueListenableBuilder<int>(
                builder: (BuildContext context, int distanceInmeters, Widget? child) {
                  return TextField(
                    maxLines: 1,
                    controller: distanceTextController,
                    // v: this.distanceInmeters.value > 0 ? this.distanceInmeters.value.toString() : "",
                    autofocus: false,
                    onChanged:(distanceString) {
                      this.setDistance(distanceString);
                      valueToSet = this.distanceInmeters.value;
                    },
                    onEditingComplete: () {
                      valueToSet = this.distanceInmeters.value;
                      focusNode.unfocus();
                    },
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    focusNode: focusNode,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: white,
                        labelText: "Distance"),
                  );
                },
                valueListenable: this.distanceInmeters,
            )),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                color: bgLight,
                margin: EdgeInsets.symmetric(vertical: 2, horizontal: 2), //border
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                child: ValueListenableBuilder<String>(
                builder: (BuildContext context, String distanceUnit, Widget? child) {
                return DropdownButton(
                    value: distanceUnit,
                    icon: Icon(Icons.arrow_downward, color: fontGrey,),
                    iconSize: 12,
                    elevation:26,
                    style: TextStyle(color: Colors.black),
                    underline: Container(
                      height: 0,
                    ),
                    onChanged: (unit) { // string param
                      this.changeDistanceUnit(unit);
                    },
                    items: [
                      DropdownMenuItem(value: 'km', child: Text('km')),
                      DropdownMenuItem(value: 'm', child: Text('m')),
                    ]);
                  },
                  valueListenable: this.distanceUnit,
                ),
              ),
            )
          ]
      ),
    );
  }
}