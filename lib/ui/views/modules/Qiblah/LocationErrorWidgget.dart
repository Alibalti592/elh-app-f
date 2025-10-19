import 'package:elh/common/theme.dart';
import 'package:flutter/material.dart';

class LocationErrorWidget extends StatelessWidget {
  final String? error;
  final Function? callback;

  const LocationErrorWidget({Key? key, this.error, this.callback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    const box = SizedBox(height: 32);
    const errorColor = primaryColor;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(
            Icons.location_off,
            size: 150,
            color: errorColor,
          ),
          box,
          Text(
            error!,
            style:
                const TextStyle(color: errorColor, fontWeight: FontWeight.bold),
          ),
          box,
          ElevatedButton(
            style: ButtonStyle(
              visualDensity: VisualDensity.compact,
              foregroundColor: WidgetStateProperty.all<Color>(primaryColor),
              backgroundColor: WidgetStateProperty.all<Color>(primaryColor),
              shape: WidgetStateProperty.all(RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0),
              )),
            ),
            child: const Text(
              "Relancer",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            onPressed: () {
              if (callback != null) callback!();
            },
          )
        ],
      ),
    );
  }
}
