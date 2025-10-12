import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:elh/locator.dart';
import 'package:elh/repository/PageRepository.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/ErrorMessageService.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class PageContentController extends FutureViewModel<dynamic> {
  ErrorMessageService _errorMessageService = locator<ErrorMessageService>();
  NavigationService _navigationService = locator<NavigationService>();
  DialogService _dialogService = locator<DialogService>();
  PageRepository _pageRepository = locator<PageRepository>();
  bool isLoading = true;
  String? content;
  String? videoLink;
  String? image;
  YoutubePlayerController? youtubecontroller;
  late String pageKey;
  bool showDetteInfos = false;

  PageContentController(this.pageKey);

  @override
  Future<dynamic> futureToRun() => loadDatas();

  Future loadDatas() async {
    this.isLoading = true;
    notifyListeners();
    ApiResponse apiResponse = await _pageRepository.loadPageContent(this.pageKey);
    if (apiResponse.status == 200) {
      var page = json.decode(apiResponse.data)['page'];
      this.content = page['content'];
      if(page['video'] != null) {
        String? videoId = YoutubePlayer.convertUrlToId(page['video']);
        if(videoId != null) {
          this.youtubecontroller = YoutubePlayerController(
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
      this.isLoading = false;
      notifyListeners();
    } else {
      _errorMessageService.errorOnAPICall();
      this.isLoading = false;
      notifyListeners();
    }

  }

  FutureOr<bool> openUrl(url) async {
    Uri _url = Uri.parse(url);
    return launchUrl(_url);
  }

  openWhatsap(text) async {
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

  showContactezNous() {
    return this.pageKey != 'learn_pray' && this.pageKey != 'learn_salat';
  }
  
}