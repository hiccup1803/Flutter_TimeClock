import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staffmonitor/bloc/auth/auth_cubit.dart';
import 'package:staffmonitor/page/base_page.dart';

class AuthorizedImageWidget extends StatelessWidget {
  final String? imageUrl;
  final double height;
  final double? width;

  const AuthorizedImageWidget({this.imageUrl, required this.height, this.width, Key? key}) : super(key: key);

  Future<String?> getToken(BuildContext context) async {
    String? token = await BlocProvider.of<AuthCubit>(context).getAccessToken();
    return token;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: getToken(context),
      builder: (BuildContext context, projectSnap) {
        if (projectSnap.connectionState == ConnectionState.none || projectSnap.hasData == false) {
          return Container(
            height: height,
            width: width,
            child: Icon(Icons.image),
          );
        }
        if (projectSnap.data == null)
          return Container(
            height: height,
            width: width,
            child: Icon(Icons.image),
          );
        return Container(
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(4.0)),
          ),
          child: imageUrl != null
              ? ExtendedImage.network(
                  imageUrl!,
                  headers: {'Authorization': "Bearer ${projectSnap.data}"},
                  height: height,
                  cache: true,
                  fit: BoxFit.cover,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.all(Radius.circular(4.0)),
                )
              : Icon(Icons.image),
        );
      },
    );
  }
}
