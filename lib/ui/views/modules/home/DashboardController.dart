import 'dart:async';
import 'dart:convert';
import 'package:elh/locator.dart';
import 'package:elh/models/BBLocation.dart';
import 'package:elh/models/Obligation.dart';
import 'package:elh/models/Praytime.dart';
import 'package:elh/models/deuildate.dart';
import 'package:elh/models/salat.dart';
import 'package:elh/repository/DetteRepository.dart';
import 'package:elh/repository/DeuilRepository.dart';
import 'package:elh/repository/PriereRepository.dart';
import 'package:elh/repository/SalatRepository.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/ErrorMessageService.dart';
import 'package:elh/services/dateService.dart';
import 'package:elh/store/DashboardStore.dart';
import 'package:elh/store/LocationStore.dart';
import 'package:elh/ui/views/common/BBLocation/BBLocationView.dart';
import 'package:elh/ui/views/modules/Carte/AddCarteSelectTypeView.dart';
import 'package:elh/ui/views/modules/Carte/CarteListView.dart';
import 'package:elh/ui/views/modules/Dette/DetteView.dart';
import 'package:elh/ui/views/modules/Deuil/DeuilView.dart';
import 'package:elh/ui/views/modules/Don/DonView.dart';
import 'package:elh/ui/views/modules/Maraude/MaraudeView.dart';
import 'package:elh/ui/views/modules/Mosque/MosqueView.dart';
import 'package:elh/ui/views/modules/Page/PageContentView.dart';
import 'package:elh/ui/views/modules/Pompe/PompeView.dart';
import 'package:elh/ui/views/modules/Priere/PriereView.dart';
import 'package:elh/ui/views/modules/Qiblah/QiblahView.dart';
import 'package:elh/ui/views/modules/Salat/SalatListView.dart';
import 'package:elh/ui/views/modules/Testament/ListSharedTestamentView.dart';
import 'package:elh/ui/views/modules/Testament/MyTestamentView.dart';
import 'package:elh/ui/views/modules/Testament/Ramadan/JeunView.dart';
import 'package:elh/ui/views/modules/Todo/TodoView.dart';
import 'package:elh/ui/views/modules/dece/DeceListView.dart';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:get/get.dart' hide Transition;

class DashboardController extends FutureViewModel<dynamic> {
  ErrorMessageService _errorMessageService = locator<ErrorMessageService>();
  PriereRepository _priereRepository = locator<PriereRepository>();
  DetteRepository _detteRepository = locator<DetteRepository>();
  SalatRepository _salatRepository = locator<SalatRepository>();
  DeuilRepository _deuilRepository = locator<DeuilRepository>();
  NavigationService _navigationService = locator<NavigationService>();
  DateService _dateService = locator<DateService>();
  LocationStore _locationStore = locator<LocationStore>();
  DialogService _dialogService = locator<DialogService>();
  DashboardStore _dashboardStore = locator<DashboardStore>();
  get dashboardStore => _dashboardStore;
  bool needDefineLocation = false;
  DateTime? date;
  Praytime? praytime;
  Bblocation? searchLocation;
  ValueNotifier<String> nextPrayHour = ValueNotifier<String>("");
  String nextPrayName = '';
  bool isLoading = true;
  bool isLoadingDettes = true;
  bool isLoadingSalats = true;
  bool isLoadingdeuilsdates = true;
  List<Obligation> obligations = [];
  int nbDettes = 0;
  int nbOnms = 0;
  int nbJeds = 0;
  int nbAmanas = 0;
  List<Obligation> jeds = [];
  List<Obligation> onms = [];
  List<Obligation> amanas = [];
  List<Salat> salats = [];
  int? nbSalats;
  int nbDeuils = 0;
  List<DeuilDate> deuilDates = [];
  bool isRealoadingPrays = false;
  bool notifIsOn = true;

  DashboardController() {
    Timer.periodic(Duration(seconds: 1), (Timer t) => setNextPrayHour());
    Timer.periodic(Duration(hours: 2), (Timer t) => loadDatas());
    _dashboardStore.periodicRefreshDashboard();
  }

  @override
  Future<dynamic> futureToRun() => loadDatas();

  Future loadDatas() async {
    this.loadPrays();
    this.setNotifStatus();
  }

  Future refreshDatas() async {
    this.loadDatas();
    _dashboardStore.refreshDashboard();
  }

  setNotifStatus() async {
    try {
      PermissionStatus status = await Permission.notification.request();
      if (status.isDenied || status.isPermanentlyDenied) {
        this.notifIsOn = false;
      } else {
        this.notifIsOn = true;
      }
      notifyListeners();
    } catch (e) {}
  }

  Future loadDeuil() async {
    ApiResponse apiResponse = await _deuilRepository.loadDeuilDates();
    if (apiResponse.status == 200) {
      try {
        this.deuilDates =
            deuildatesFromJson(json.decode(apiResponse.data)['deuilDates']);
      } catch (e) {
        print(e);
      }
      this.isLoadingdeuilsdates = false;
      notifyListeners();
    } else {
      _errorMessageService.errorOnAPICall();
    }
  }

  Future loadSalats() async {
    this.isLoadingSalats = true;
    notifyListeners();
    ApiResponse apiResponse =
        await _salatRepository.loadSalats(passedOnly: true);
    if (apiResponse.status == 200) {
      try {
        this.salats = salatFromJson(json.decode(apiResponse.data)['salats']);
        this.nbSalats = this.salats.length;
      } catch (e) {
        print(e);
      }
      this.isLoadingSalats = false;
      notifyListeners();
    } else {
      _errorMessageService.errorOnAPICall();
    }
  }

  Future loadDettes({locationString}) async {
    this.isLoadingDettes = true;
    this.obligations = [];
    this.jeds = [];
    this.onms = [];
    this.amanas = [];
    notifyListeners();
    ApiResponse apiResponse =
        await _detteRepository.loadCurrentDettesToRefund();
    if (apiResponse.status == 200) {
      var data = json.decode(apiResponse.data);
      try {
        this.obligations = obligationFromJson(data['obligations']);
        this.nbDettes = this.obligations.length;
        this.obligations.forEach((dette) {
          if (dette.type == 'jed') {
            this.jeds.add(dette);
          } else if (dette.type == 'onm') {
            this.onms.add(dette);
          } else if (dette.type == 'amana') {
            this.amanas.add(dette);
          }
        });
      } catch (e) {}
    } else {
      _errorMessageService.errorOnAPICall();
    }
    this.isLoadingDettes = false;
    notifyListeners();
  }

  bool showQibla = false;

  void toggleQibla() {
    showQibla = !showQibla;
    notifyListeners(); // if using Stacked/Provider/etc.
  }

  void goTo(String viewName) {
    Widget view;

    if (viewName == 'qibla') {
      view = QiblahView();
    } else if (viewName == 'mosque') {
      view = MosqueView();
    } else if (viewName == 'pray') {
      view = PriereView();
    } else if (viewName == 'learn_pray') {
      view = PageContentView(viewName, "Apprendre la prière");
    } else if (viewName == 'ramadan') {
      view = PageContentView(viewName, "Ramadan");
    } else if (viewName == 'learn_salat') {
      view = PageContentView(viewName, "Apprendre Salât Al-Janaza");
    } else if (viewName == 'learn_sourat') {
      view = PageContentView(viewName, "Sourates faciles à apprendre");
    }
    // Special cases with textWhatsapp
    else if (['puit', 'offerCoran', 'buildMosque', 'hajiProcur', 'parrain']
        .contains(viewName)) {
      String textWhatsapp = '';
      String title = '';
      if (viewName == 'puit') {
        textWhatsapp = 'Assalem alaykoum, Je souhaite construire un puit';
        title = 'Construire un puit';
      } else if (viewName == 'offerCoran') {
        textWhatsapp = 'Assalem alaykoum, Je souhaite offrir un Coran';
        title = 'Offrir un Coran';
      } else if (viewName == 'buildMosque') {
        textWhatsapp = 'Assalem alaykoum, Je souhaite construire un mosquée';
        title = 'Construire une mosquée';
      } else if (viewName == 'hajiProcur') {
        textWhatsapp =
            'Assalem alaykoum, Je souhaite faire un Omra/ hajj par procuration';
        title = 'Omra/ hajj par procuration';
      } else if (viewName == 'parrain') {
        textWhatsapp = 'Assalem alaykoum, Je souhaite parrainer un orphelin';
        title = 'Parrainer un orphelin';
        viewName = 'don'; // redirect to 'don' page
      }
      view = PageContentView(viewName, title, textWhatsapp: textWhatsapp);
    }
    // Dette views
    else if (viewName == 'jed') {
      view = DetteView('jed');
    } else if (viewName == 'onm') {
      view = DetteView('onm');
    } else if (viewName == 'amana') {
      view = DetteView('amana');
    } else if (viewName == 'testament') {
      view = MyTestamentView();
    } else if (viewName == 'sharedTestamentWithMe') {
      view = ListSharedTestamentView();
    } else if (viewName == 'jeunRamadan') {
      view = JeunView();
    }
    // Don
    else if (viewName == 'don') {
      view = DonView();
    } else if (viewName == 'entraide') {
      view = MaraudeView();
    }
    // Deuil / other
    else if (viewName == 'periode') {
      view = DeuilView();
    } else if (viewName == 'todo') {
      view = TodoView();
    } else if (viewName == 'pompe') {
      view = PompeView();
    } else if (viewName == 'salat') {
      view = SalatListView();
    } else if (viewName == 'dece') {
      view = DeceListView();
    } else if (viewName == 'cartes') {
      view = AddCarteSelectTypeView();
    } else if (viewName == 'bidha') {
      view = PageContentView(viewName, "Bid’ah / Sunnah");
    } else if (viewName == 'prep-salat') {
      view = PageContentView(viewName, "Préparer Salât Al-Janaza");
    } else if (viewName == 'duha') {
      view = PageContentView(viewName, "Invocations Doua");
    } else if (viewName == 'herite') {
      view = PageContentView(viewName, "Héritage");
    }
    // fallback
    else {
      view = PageContentView(viewName, "Page inconnue");
    }

    // Navigate
    Get.to(() => view);
  }

  Future loadPrays({locationString}) async {
    this.isLoading = true;
    notifyListeners();
    ApiResponse apiResponse =
        await _priereRepository.loadPrieres(date, locationString);
    if (apiResponse.status == 200) {
      try {
        var data = json.decode(apiResponse.data);
        if (data['praytime'] == null) {
          this.needDefineLocation = true;
        } else {
          this.praytime = praytimeFromJson(data['praytime']);
          this.needDefineLocation = false;
        }
      } catch (e) {
        print(e);
      }
      this.setNextPrayHour();
      this.isLoading = false;
      notifyListeners();
    } else {
      _errorMessageService.errorOnAPICall();
    }
  }

  setLocation() {
    _navigationService
        .navigateWithTransition(BBLocationView(),
            transitionStyle: Transition.downToUp,
            duration: Duration(milliseconds: 300))
        ?.then((value) {
      if (value == "setLocation") {
        this.searchLocation = _locationStore.selectedLocation;
        if (this.searchLocation != null) {
          String locationString = json.encode(this.searchLocation!.toJson());
          this.loadPrays(locationString: locationString);
        }
      }
    });
  }

  setNextPrayHour() {
    if (this.praytime == null) {
      this.nextPrayHour.value = '';
      return;
    }
    //get next pray
    int currentTimestamp =
        (DateTime.now().millisecondsSinceEpoch / 1000).round();
    bool issetted = false;
    if (this.praytime != null) {
      this.praytime!.prieres.forEach((priere) {
        int timestonow = priere.timestamp - currentTimestamp;
        if (timestonow > 0 && !issetted) {
          Duration duration = Duration(seconds: timestonow);
          this.nextPrayHour.value = _dateService.hhmmss(duration);
          this.nextPrayName = priere.label;
          issetted = true;
          this.isRealoadingPrays = false;
        }
      });
    }

    if (!issetted && !this.isRealoadingPrays) {
      //si on a depassé last pray, reload prays of tomorrow
      this.isRealoadingPrays = true;
      this.loadPrays();
    }
  }

  goToDette(obligation) {
    _navigationService.navigateToView(DetteView(obligation.type));
  }

  goToCartes() {
    _navigationService.navigateToView(CarteListView(onglet: 'receive'));
  }

  goToDettes(type) {
    _navigationService.navigateToView(DetteView(type));
  }

  goToSalat() {
    _navigationService.navigateToView(SalatListView());
  }

  goToDeuil() {
    _navigationService.navigateToView(DeuilView());
  }

  gotToPrays() {
    _navigationService.navigateToView(PriereView());
  }
}
