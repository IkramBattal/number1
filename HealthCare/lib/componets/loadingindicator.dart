import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import '../constants.dart';

void showLoadingDialog({
  @required BuildContext? context,
}) {
  Future.delayed(const Duration(seconds: 0), () {
    showDialog(
        context: context!,
        barrierColor: Colors.transparent,
        barrierDismissible: false,
        builder: (context) {
          return Center(
            child: Material(
              color: Colors.white,
              child: Center(
                child: Container(
                  width: 50,
                  height: 50,
                  child: LoadingIndicator(
                    indicatorType: Indicator.ballGridBeat,
                    colors: _kDefaultRainbowColors,
                    strokeWidth: 4.0,
                  ),
                ),
              ),
            ),
          );
        });
  });
}

List<Color> _kDefaultRainbowColors = const [
  Color(0xFF4CA6A8),
  Color(0x6FFAFAFA),
  Colors.grey,
  Color(0xFF32A4A4),
  Color(0xFF5C9FA1),
  Color(0xFF77A6A6)

];


class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 50,
        height: 50,
        child: LoadingIndicator(
          indicatorType: Indicator.ballGridPulse,
          colors: _kDefaultRainbowColors,
          strokeWidth: 4.0,
        ),
      ),
    );
  }
}

void hideLoadingDialog({@required BuildContext? context}) {
  Navigator.pop(context!, false);
}
