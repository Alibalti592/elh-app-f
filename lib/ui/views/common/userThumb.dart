import 'package:cached_network_image/cached_network_image.dart';
import 'package:elh/models/userInfos.dart';
import 'package:flutter/material.dart';
import 'package:elh/common/theme.dart';



Widget userThumb(UserInfos userInfos, size) {
  return userThumbDirect(userInfos.photo, "${userInfos.firstname.substring(0,1)}${userInfos.lastname.substring(0,1)}",  size);
}

Widget userThumbDirect(userThumb, userLetters, size, { icon }) {
  bool hasThumb = false;
  if(userThumb != null && userThumb.length > 5) {
    hasThumb = true;
  }
  Widget userImage = hasThumb ? Container(
      width: size,
      height: size,
      decoration: new BoxDecoration(
          shape: BoxShape.circle,
          image: new DecorationImage(
              fit: BoxFit.contain,
              image: CachedNetworkImageProvider(userThumb)
          )
      )) : Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: bgLight
      ),
      child: Center(child: Text(userLetters, style: TextStyle(fontSize: (size / 2))))
  );
  //icon overlay
  if(icon != null) {
    return Stack(
      clipBehavior: Clip.none, //overflow visible
      children: [
        userImage,
      ],
    );
  }
  return userImage;

}

Widget userThumbIconEmpty(userThumb, size, icon, iconSize) {
  return (userThumb != null && userThumb.length > 1) ? Container(
      width: size,
      height: size,
      decoration: new BoxDecoration(
          shape: BoxShape.circle,
          image: new DecorationImage(
              fit: BoxFit.contain,
              image: CachedNetworkImageProvider(userThumb)
          )
      )) : Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: bgLight
      ),
      child: Center(child: Icon(icon, size: iconSize,))
  );
}