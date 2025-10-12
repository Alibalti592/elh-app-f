import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:elh/locator.dart';
import 'package:elh/models/ChatMessage.dart';
import 'package:elh/models/ChatThread.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/BaseApi/AuthApiHelper.dart';
import 'package:elh/services/UploadService.dart';

class ChatRepository {
  final AuthApiHelper _authApiHelper = locator<AuthApiHelper>();
  UploadService _uploadService = locator<UploadService>();

  Future<ApiResponse> hasMessage() async {
    return _authApiHelper.get('/chat/has-messages');
  }

  Future<ApiResponse> getContacts() async {
    return _authApiHelper.get('/chat/load-threads');
  }

  Future<ApiResponse> getAddThreadOptions() async {
    return _authApiHelper.get('/chat/load-modal-thread-datas');
  }

  Future<ApiResponse> loadUsersToAddOnThread(itemsPerPage, page, thread, searchTerm) async {
    var map = new Map<String, dynamic>();
    map['itemsPerPage'] = itemsPerPage.toString();
    map['page'] = page.toString();
    map['currentPage'] = page.toString();
    if(thread != null) {
      map['thread'] = thread.id.toString();
    }
    map['searchTerm'] = searchTerm;

    return _authApiHelper.post('/chat/thread/load-list-to-add', map, type: 'x-www-form-urlencoded');
  }

  Future<ApiResponse> saveThread(userIds, threadType, Thread? thread) async {
    var map = new Map<String, dynamic>();
    map['userIds'] = json.encode(userIds).toString();
    map['threadType'] = threadType.toString();
    if(thread != null) {
      map['thread'] = thread.id.toString(); //threadId | null
    }
    return _authApiHelper.post('/chat/thread/add-user', map, type: 'x-www-form-urlencoded');
  }

  Future<ApiResponse> saveThreadGroupDatas(Thread thread, imageBase64) async {
    var map = new Map<String, dynamic>();
    map['thread'] = thread.id.toString();
    map['name'] = thread.groupName.toString();
    map['imageBase64'] = imageBase64;
    return _authApiHelper.post('/chat/thread/edit-thread-group', map, type: 'x-www-form-urlencoded');
  }


  Future<ApiResponse>  deleteParticipant(participant, thread) async {
    var map = new Map<String, dynamic>();
    map['thread'] = thread.id.toString();
    map['user'] = participant.id.toString();
    return _authApiHelper.post('/chat/thread/delete-user', map, type: 'x-www-form-urlencoded');
  }



  Future<ApiResponse> getThreadFromId(threadId) async {
    var map = new Map<String, dynamic>();
    map['threadId'] = threadId.toString();
    return _authApiHelper.post('/chat-get-thread-fromid', map, type: 'x-www-form-urlencoded');
  }

  Future<ApiResponse> getThreadSimple(userId) async {
    var map = new Map<String, dynamic>();
    map['user'] = userId.toString();
    return _authApiHelper.post('/chat-load-simple-thread', map, type: 'x-www-form-urlencoded');
  }

  Future<ApiResponse> deleteThread(threadId) async {
    var map = new Map<String, dynamic>();
    map['thread'] = threadId.toString();
    return _authApiHelper.post('/v-thread-delete', map, type: 'x-www-form-urlencoded');
  }

  Future<ApiResponse> leaveThread(threadId) async {
    var map = new Map<String, dynamic>();
    map['thread'] = threadId.toString();
    return _authApiHelper.post('/v-thread-leave-group', map, type: 'x-www-form-urlencoded');
  }

  //******************************* Messages part *****************************/
  Future<ApiResponse> loadLastMessages(threadId, lastMessageId) async {
    String params = "?lastMessageId=$lastMessageId&thread=$threadId";
    return _authApiHelper.get('/chat/load-last-messages$params');
  }

  Future<ApiResponse> loadMessages(threadId, page, loadParticipants) async {
    String params = "?page=$page&thread=$threadId&loadParticipants=$loadParticipants";
    return _authApiHelper.get('/chat/load-thread-messsages$params');
  }

  Future<ApiResponse> addMessage(message, Thread thread, File? file, String? filename ) async {
    var map = new Map<String, dynamic>();
    map['thread'] = thread.id.toString();
    map['text'] = message;
    map['type'] = 'text';
    if(file != null) {
      map['type'] = 'file';
      map['filename'] = filename;
      //"data:image/"+myme+";base64,"+base64Encode(imageFile.readAsBytesSync())
      map['base64'] = _uploadService.convertFileToBase64WithMimeType(file);
    }
    return _authApiHelper.post('/chat/send-messsage', map, type: 'x-www-form-urlencoded');
  }

  Future<ApiResponse>  sendtypingNotification(thread, type) async {
    var map = new Map<String, dynamic>();
    map['thread'] = thread.id.toString();
    map['type'] = type;
    return _authApiHelper.post('/chat/notify-thread', map, type: 'x-www-form-urlencoded');
  }

  Future<ApiResponse> deleteMessage(messageId) async {
    var map = new Map<String, dynamic>();
    map['message'] = messageId.toString();
    return _authApiHelper.post('/v-chat-delete-msg', map, type: 'x-www-form-urlencoded');
  }

  Future<ApiResponse> editMessage(ChatMessage message) async {
    var map = new Map<String, dynamic>();
    map['message'] = json.encode(message.toJson());
    return _authApiHelper.post('/v-chat-edit-messsage', map, type: 'x-www-form-urlencoded');
  }
}