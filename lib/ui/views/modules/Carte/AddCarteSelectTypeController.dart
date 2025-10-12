import 'package:elh/locator.dart';
import 'package:elh/models/carte.dart';
import 'package:elh/ui/views/modules/Carte/AddCarteView.dart';
import 'package:elh/ui/views/modules/Carte/CarteListView.dart';
import 'package:elh/ui/views/modules/Salat/AddSalataView.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class AddCarteSelectTypeController extends BaseViewModel {
  NavigationService _navigationService = locator<NavigationService>();
  String? carteType;



  selectType(type) {
    if(type == 'salat') {
      _navigationService.navigateToView(AddSalatView(fromView: 'carteList'));
    } else {
      Carte newCarte = new Carte( type: type, afiliation: 'father', firstname: '', lastname: '', dateDisplay: '', afiliationLabel: '', content: '', canEdit: true);
      if(type == 'searchdette') {
        newCarte.onmyname = 'toother';
      }
      _navigationService.navigateToView(AddCarteView(carte: newCarte));
    }
  }

  goToList() {
    _navigationService.navigateToView(CarteListView());
  }
}