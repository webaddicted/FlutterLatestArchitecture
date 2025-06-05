import 'package:flutter/material.dart';
import 'package:pingmexx/utils/constant/color_const.dart';

class ProgressDialog extends StatefulWidget {
  late Color backgroundColor;
  late Color color;
  late Color containerColor;
  late double borderRadius;
  late String text;
  late ProgressDialogState progressDialogState;

  ProgressDialog(
      {this.backgroundColor = Colors.black54,
      this.color = Colors.deepPurple,
      this.containerColor = Colors.transparent,
      this.borderRadius = 10.0,
      this.text = ""});

  @override
  createState() => progressDialogState = ProgressDialogState(
      backgroundColor: this.backgroundColor,
      color: this.color,
      containerColor: this.containerColor,
      borderRadius: this.borderRadius,
      text: this.text);

  void hideProgress() {
    progressDialogState.hideProgress();
  }

  void showProgress() {
    progressDialogState.showProgress();
  }

  void showProgressWithText(String title) {
    progressDialogState.showProgressWithText(title);
  }

  static ProgressDialog getProgressDialog(String title) {
    return ProgressDialog(
      backgroundColor: Colors.black12,
      color: ColorConst.appColor,
      containerColor: Colors.transparent,
      borderRadius: 5.0,
      text: title,
    );
  }
}

class ProgressDialogState extends State<ProgressDialog> {
  Color backgroundColor;
  Color color;
  Color containerColor;
  double borderRadius;
  String text;
  bool _opacity = false;

  ProgressDialogState(
      {this.backgroundColor = Colors.black54,
      this.color = Colors.white,
      this.containerColor = Colors.transparent,
      this.borderRadius = 10.0,
      this.text = ""});

  @override
  Widget build(BuildContext context) {
    return Container(
        child: !_opacity
            ? null
            : Opacity(
                opacity: _opacity ? 1.0 : 0.0,
                child: Stack(
                  children: <Widget>[
                   /* new Center(
                      child: new Container(
                        width: 95.0,
                        height: 95.0,
                        decoration: new BoxDecoration(
                            color: containerColor,
                            borderRadius: new BorderRadius.all(
                                new Radius.circular(borderRadius))),
                      ),
                    ),*/
                    Center(
                      child: _getCenterContent(),
                    )
                  ],
                ),
              ));
  }

  Widget _getCenterContent() {
    if (text.isEmpty) {
      return _getCircularProgress();
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _getCircularProgress(),
          Container(
            margin: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
            child: Text(
             // text,
              '',
              style: TextStyle(color: color),
            ),
          )
        ],
      ),
    );
  }

  Widget _getCircularProgress() {
    return CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(color));
  }

  void hideProgress() {
    setState(() {
      _opacity = false;
    });
  }

  void showProgress() {
    setState(() {
      _opacity = true;
    });
  }

  void showProgressWithText(String title) {
    setState(() {
      _opacity = true;
      text = title;
    });
  }
}
