import 'package:elh/ui/shared/BBLoader.dart';
import 'package:elh/ui/shared/text_styles.dart';
import 'package:elh/ui/shared/ui_helpers.dart';
import 'package:elh/ui/views/common/BBLocation/BBLocationController.dart';
import 'package:flutter/material.dart';
import 'package:elh/common/theme.dart';
import 'package:stacked/stacked.dart';

class BBLocationView extends StatefulWidget {
  bool fullAdress = false;
  BBLocationView({fullAdress = false}) {
    this.fullAdress = fullAdress;
  }
  @override
  BBLocationViewState createState() => BBLocationViewState(this.fullAdress);
}

class BBLocationViewState extends State<BBLocationView> {
  late bool fullAdress;
  BBLocationViewState(fullAdress) {
      this.fullAdress = fullAdress;
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<BBLocationController>.reactive(
        builder: (context, controller, child) => Scaffold(
            backgroundColor:  bgLightV2,
            appBar: AppBar(
              leading: IconButton(
                  icon: Icon(Icons.close, color: Colors.black),
                  onPressed: () async {
                    Navigator.of(context).pop('donothing');
                }),
              title: Text('', style: headerText),
              backgroundColor: bgLightV2,
              actions: [

              ],
            ),
            body: controller.isLoading ? Center(child: BBloader()) : SafeArea(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // GooglePlaceAutoCompleteTextField(
                      //   textEditingController: controller.searchController,
                      //   googleAPIKey: "AIzaSyDCZyWaI1lcnISnQFx01GeFOj5FE_oQFy4",
                      //   boxDecoration: BoxDecoration(
                      //     color: Colors.white,
                      //     border: Border.all(width: 1, color: Colors.white),
                      //     borderRadius: BorderRadius.circular(30)
                      //   ),
                      //   inputDecoration: InputDecoration(
                      //     hintText: "Recherchez votre adresse",
                      //     border: InputBorder.none,
                      //     enabledBorder: InputBorder.none,
                      //     focusedBorder: InputBorder.none,
                      //     errorBorder: InputBorder.none,
                      //     disabledBorder: InputBorder.none,
                      //     fillColor: Colors.white,
                      //
                      //   ),
                      //   debounceTime: 900,
                      //   isLatLngRequired: true,
                      //   getPlaceDetailWithLatLng: (Prediction prediction) {
                      //     print(prediction.terms);
                      //   },
                      //   itemClick: (Prediction prediction) {
                      //     controller.searchController.text = prediction.description ?? "";
                      //     controller.searchController.selection = TextSelection.fromPosition(
                      //         TextPosition(offset: prediction.description?.length ?? 0));
                      //   },
                      //   seperatedBuilder: Divider(),
                      //   containerHorizontalPadding: 10,
                      //   itemBuilder: (context, index, Prediction prediction) {
                      //     return Container(
                      //       padding: EdgeInsets.all(10),
                      //       child: Row(
                      //         children: [
                      //           Icon(Icons.location_on),
                      //           SizedBox(
                      //             width: 7,
                      //           ),
                      //           Expanded(child: Text("${prediction.description ?? ""}"))
                      //         ],
                      //       ),
                      //     );
                      //   },
                      //   isCrossBtnShown: true,
                      //   // default 600 ms ,
                      // ),

                      Container(
                        padding: const EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 5) ,
                        decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(15)), color: Colors.white
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(controller.searchTypeLabel(), textAlign: TextAlign.left, style: labelSmallStyle),
                            UIHelper.verticalSpace(10),
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(Radius.circular(15))
                              ),
                              child: TextFormField(
                                  style: TextStyle(color: fontDark),
                                  controller: controller.searchController,
                                  focusNode: controller.focusNode,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.all(10.0),
                                    fillColor: white,
                                    filled: true,
                                    hintText: "Recherche...",
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(color: bgLight),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: bgLight),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    hintStyle: TextStyle(color: fontGreyLight),
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        if(!controller.isLoading) {
                                          controller.searchAdress();
                                        }
                                      },
                                      icon: Icon(
                                        Icons.search,
                                        color: fontGreyLight,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  onFieldSubmitted: (String search) {
                                    controller.searchAdress();
                                  },
                                  onChanged: (String search) {
                                    //controller.searchAdress();
                                  }),
                            ),
                            _buildSelectCurrentPositionButton(controller),
                          ],
                        ),
                      ),
                      UIHelper.verticalSpace(5),
                      ValueListenableBuilder<bool>(
                        builder: (BuildContext context, bool isSearching, Widget? child) {
                          return isSearching ? Container(
                              margin: const EdgeInsets.symmetric(vertical: 30),
                              child: BBloader()
                          ) : _resultsList(controller);
                        },
                        valueListenable: controller.isSearching,
                      ),

                    ],
                  ),
                )
            )),
        viewModelBuilder: () => BBLocationController(fullAdress)
    );
  }

  Widget _buildSelectCurrentPositionButton(BBLocationController controller) {
    return Container(
      margin: const EdgeInsets.only(top: 5),
      child: TextButton(
        onPressed: (() async {
          controller.determinePosition();
        }),
        child: Row(children: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: ValueListenableBuilder<bool>(
              builder: (BuildContext context, bool currentLocationLoading, Widget? child) {
                return currentLocationLoading ?
                SizedBox( width:15, height:15, child: CircularProgressIndicator(color: fontGreyLight, strokeWidth: 2)) : Icon(
                  Icons.location_searching,
                  color: fontGreyLight,
                  size: 18,
                );
              },
              valueListenable: controller.currentLocationLoading,
            )
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width - 120,
            child: Text("Utiliser ma postition",
              style: TextStyle(
                  color: fontDark,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  overflow: TextOverflow.ellipsis),
              maxLines: 1,
            ),
          ),
        ]),
      ),
    );
  }

  Widget _resultsList(BBLocationController controller) {
    if(controller.locations.isEmpty) {
      return Container();
    }
    return Expanded(
      child: Container(
        padding: const EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 5) ,
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(15))
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sélectionnez votre adresse', textAlign: TextAlign.left, style: labelSmallStyle),
            UIHelper.verticalSpace(10),
            Expanded(
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: controller.locations.length,
                  itemBuilder: (context, index) {
                    final items = controller.locations.isEmpty ? controller.history : controller.locations;
                    return ListTile(
                      dense: true,
                      visualDensity: VisualDensity(vertical: -3),
                      minVerticalPadding: 5,
                      contentPadding: EdgeInsets.zero,
                      title: Container(
                        padding: const EdgeInsets.only(top: 8, bottom: 8, left: 10),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(items[index].displayLabel, style: TextStyle(color: fontDark, fontSize: 15),),
                            Text( "${items[index].country}", style: TextStyle(color: fontGrey, fontSize: 12)),
                          ],
                        ),
                      ),
                      onTap: ()  async {
                        controller.selectLocation(items[index], context);
                      },
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }
}