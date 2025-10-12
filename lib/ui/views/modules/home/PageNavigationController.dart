import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:elh/locator.dart';
import 'package:elh/repository/PageRepository.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/ErrorMessageService.dart';
import 'package:elh/store/DashboardStore.dart';
import 'package:elh/ui/views/modules/Carte/AddCarteSelectTypeView.dart';
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
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class PageNavigationController extends FutureViewModel<dynamic> {
  ErrorMessageService _errorMessageService = locator<ErrorMessageService>();
  NavigationService _navigationService = locator<NavigationService>();
  DialogService _dialogService = locator<DialogService>();
  PageRepository _pageRepository = locator<PageRepository>();
  final DashboardStore _dashboardStore = locator<DashboardStore>();
  DashboardStore get dashboardStore => _dashboardStore;
  bool isLoading = true;
  String? content;
  String? videoLink;
  String? image;
  YoutubePlayerController? youtubecontroller;
  late String pageKey;
  bool showDetteInfos = false;

  PageNavigationController(this.pageKey);

  @override
  Future<dynamic> futureToRun() => loadDatas();

  Future loadDatas() async {
    ApiResponse apiResponse =
        await _pageRepository.loadPageContent(this.pageKey);
    if (apiResponse.status == 200) {
      var page = json.decode(apiResponse.data)['page'];
      this.content = page['content'];
      if (page['video'] != null) {
        String? videoId = YoutubePlayer.convertUrlToId(page['video']);
        if (videoId != null) {
          youtubecontroller = YoutubePlayerController(
            initialVideoId: videoId,
            flags: YoutubePlayerFlags(
              autoPlay: false,
              mute: false,
              hideControls: false,
            ),
          );
        }
      }
      this.image = page['image'];
      this.showDetteInfos = json.decode(apiResponse.data)['showDetteInfos'];
      if (this.pageKey == "dette") {
        this.showDetteInfoDialog();
      }
      notifyListeners();
    } else {
      _errorMessageService.errorOnAPICall();
    }
  }

  showDetteInfoDialog() async {
    if (this.showDetteInfos) {
      this._dialogService.showDialog(
          title: "Confidentialité",
          description:
              "Toutes les informations saisies sur Muslim Connect restent confidentielles. Muslim Connect n’a aucun accès ni droit de regard.",
          cancelTitle: "",
          buttonTitle: "Bien lu");
      //user set has see
      ApiResponse apiResponse = await _pageRepository.setHasSeeDetteInfos();
    }
  }

  gotToView(viewname) {
    _dashboardStore.pauseAll();
    var view;
    if (viewname == 'qibla') {
      view = QiblahView();
    } else if (viewname == 'mosque') {
      view = MosqueView();
    } else if (viewname == 'pray') {
      view = PriereView();
    } else if (viewname == 'learn_pray') {
      view = PageContentView(viewname, "Apprendre la prière");
    } else if (viewname == 'ramadan') {
      view = PageContentView(viewname, "Ramadan");
    } else if (viewname == 'learn_salat') {
      view = PageContentView(viewname, "Apprendre Salât Al-Janaza");
    } else if (viewname == 'learn_sourat') {
      view = PageContentView(viewname, "Sourates faciles à apprendre");
    } else if (viewname == 'puit' ||
        viewname == 'offerCoran' ||
        viewname == 'buildMosque' ||
        viewname == 'hajiProcur' ||
        viewname == 'parrain') {
      String textWhatsapp = '';
      String title = "";
      if (viewname == 'puit') {
        textWhatsapp = 'Assalem alaykoum, Je souhaite construire un puit';
        title = 'Construire un puit';
      } else if (viewname == 'offerCoran') {
        textWhatsapp = 'Assalem alaykoum, Je souhaite offrir un Coran';
        title = 'Offrir un Coran';
      } else if (viewname == 'buildMosque') {
        textWhatsapp = 'Assalem alaykoum, Je souhaite construire un mosquée';
        title = 'Construire une mosquée';
      } else if (viewname == 'hajiProcur') {
        textWhatsapp =
            'Assalem alaykoum, Je souhaite faire un Omra/ hajj par procuration';
        title = 'Omra/ hajj par procuration';
      } else if (viewname == 'parrain') {
        textWhatsapp = 'Assalem alaykoum, Je souhaite parrainer un orphelin';
        title = 'Parrainer un orphelin';
        viewname = 'don'; //text de la page don !!
      }
      view = PageContentView(viewname, title, textWhatsapp: textWhatsapp);
    }
    //DETTE part
    else if (viewname == 'jed') {
      view = DetteView('jed');
    } else if (viewname == 'onm') {
      view = DetteView('onm');
    } else if (viewname == 'amana') {
      view = DetteView('amana');
    } else if (viewname == 'testament') {
      view = MyTestamentView();
    } else if (viewname == 'sharedTestamentWithMe') {
      view = ListSharedTestamentView();
    } else if (viewname == 'jeunRamadan') {
      view = JeunView();
    }
    //DON
    else if (viewname == 'don') {
      view = DonView();
    } else if (viewname == 'entraide') {
      view = MaraudeView();
    }
    //deuil
    else if (viewname == 'periode') {
      view = DeuilView();
    } else if (viewname == 'todo') {
      view = TodoView();
    } else if (viewname == 'pompe') {
      view = PompeView();
    } else if (viewname == 'salat') {
      view = SalatListView();
    } else if (viewname == 'dece') {
      view = DeceListView();
    } else if (viewname == 'cartes') {
      view = AddCarteSelectTypeView();
    } else if (viewname == 'bidha') {
      view = PageContentView(viewname, "Bid’ah / Sunnah");
    } else if (viewname == 'prep-salat') {
      view = PageContentView(viewname, "Préparer Salât Al-Janaza");
    } else if (viewname == 'duha') {
      view = PageContentView(viewname, "Invocations Doua");
    } else if (viewname == 'herite') {
      view = PageContentView(viewname, "Héritage");
    }

    _navigationService.navigateToView(view);
  }

  openWhatsap(String text) async {
    String contact = "+33759676631";
    String androidUrl = "whatsapp://send?phone=$contact&text=$text";
    String iosUrl = "https://wa.me/$contact?text=${Uri.parse(text)}";
    if (Platform.isIOS) {
      if (await canLaunchUrl(Uri.parse(iosUrl))) {
        await launchUrl(Uri.parse(iosUrl));
      }
    } else {
      if (await canLaunchUrl(Uri.parse(androidUrl))) {
        await launchUrl(Uri.parse(androidUrl));
      }
    }
  }

  FutureOr<bool> openUrl(url) async {
    Uri _url = Uri.parse(url);
    return launchUrl(_url);
  }

  bool showAddIcon(viewName) {
    if (viewName == 'onm' ||
        viewName == 'jed' ||
        viewName == 'amana' ||
        viewName == 'testament' ||
        viewName == 'sharedTestamentWithMe' ||
        viewName == 'jeunRamadan') {
      return true;
    }
    return false;
  }
}
