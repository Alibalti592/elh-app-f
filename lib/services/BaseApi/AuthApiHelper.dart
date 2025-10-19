import 'package:http/http.dart' as http; // <-- use package:http here
import 'package:path/path.dart' as p;
import 'package:elh/locator.dart';
import 'package:elh/services/AuthenticationService.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/BaseApi/BaseApiHelper.dart';

class AuthApiHelper {
  final BaseApiHelper _baseApiHelper = locator<BaseApiHelper>();
  final AuthenticationService _authenticationService =
      locator<AuthenticationService>();

  getUserToken() async {
    String token = await _authenticationService.getUserToken();
    return token;
  }

  Future<ApiResponse> get(String url) async {
    String token = await this.getUserToken();
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Authorization': "Bearer $token"
    };
    return _baseApiHelper.get(url, requestHeaders);
  }

  Future<ApiResponse> post(String url, body, {type = 'json'}) async {
    String token = await this.getUserToken();
    Map<String, String> requestHeaders = {
      'Content-type': 'application/$type',
      'Authorization': "Bearer $token"
    };
    return _baseApiHelper.post(url, requestHeaders, body);
  }

  Future<ApiResponse> postMultipart(
    String url, {
    Map<String, String>? fields,
    String? filePath, // optional single file
    List<String> filePaths = const [], // optional multiple files
    String fileFieldName = 'file', // Symfony: $request->files->get('file')
    String multiFilesFieldName = 'attachments[]',
    bool public = false,
  }) async {
    final token = await getUserToken();
    final headers = {'Authorization': 'Bearer $token'}; // no Content-Type

    final files = <http.MultipartFile>[];

    if (filePath != null) {
      files.add(await http.MultipartFile.fromPath(
        fileFieldName,
        filePath,
        filename: p.basename(filePath),
      ));
    }

    for (final path in filePaths) {
      files.add(await http.MultipartFile.fromPath(
        multiFilesFieldName,
        path,
        filename: p.basename(path),
      ));
    }

    return _baseApiHelper.postMultipart(
      url,
      headers,
      fields: fields,
      files: files,
      public: public,
    );
  }
}
