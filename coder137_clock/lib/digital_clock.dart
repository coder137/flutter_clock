// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Constant class
abstract class Constants {
  static const ColorShadow = Colors.orange;
  static const ColorText = Colors.white;
}

enum _Element {
  background,
  text,
  shadow,
}

enum _Color {
  contrast,
  blue,
  blueAccent,
  yellow,
  green,
  red,
  orange,
  blueGrey,
}

final _lightTheme = {
  _Element.background: Color(0xFF81B3FE),
  _Element.text: Constants.ColorText,
  _Element.shadow: Constants.ColorShadow,
};

final _darkTheme = {
  _Element.background: Colors.grey,
  _Element.text: Constants.ColorText,
  // _Element.shadow: Color(0xFF174EA6),
  _Element.shadow: Constants.ColorShadow,
};

/// [DigitalClock]
/// Created a Digital Clock using a minimalistic representation of Nixie Tubes
class DigitalClock extends StatefulWidget {
  const DigitalClock(this.model);

  final ClockModel model;

  @override
  _DigitalClockState createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock> {
  DateTime _dateTime = DateTime.now();
  Timer _timer;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(DigitalClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      // Cause the clock to rebuild when the model changes.
    });
  }

  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();
      // * Update once per minute. If you want to update every second, use the
      // following code.
      // _timer = Timer(
      //   Duration(minutes: 1) -
      //       Duration(seconds: _dateTime.second) -
      //       Duration(milliseconds: _dateTime.millisecond),
      //   _updateTime,
      // );
      // * Update once per second, but make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get the user theme here
    final colors = Theme.of(context).brightness == Brightness.light
        ? _lightTheme
        : _darkTheme;

    // Get the 24 hour / 12 hour format here
    final hour =
        DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
    final minute = DateFormat('mm').format(_dateTime);
    final second = DateFormat('ss').format(_dateTime);

    // DONE, Get current Temperature
    // DONE, Convert to Celcius
    double currentTemperature = widget.model.temperature;
    if (widget.model.unit == TemperatureUnit.fahrenheit) {
      currentTemperature = ((currentTemperature - 32) * 5) / 9;
    }

    // DONE, Get gradient from weather, current temperature and theme
    final dynamicGradient =
        _getGradientFrom(widget.model.weatherCondition, currentTemperature);

    // Defaults
    final fontSize = MediaQuery.of(context).size.width / 6;
    final defaultStyle = TextStyle(
      color: colors[_Element.text],
      fontFamily: 'NixieOne',
      fontSize: fontSize,
      fontWeight: FontWeight.w100,
      shadows: [
        Shadow(
          blurRadius: 5,
          color: colors[_Element.shadow],
        ),
      ],
    );

    final hMsb = hour.codeUnitAt(0) - 0x30;
    final hLsb = hour.codeUnitAt(1) - 0x30;
    final mMsb = minute.codeUnitAt(0) - 0x30;
    final mLsb = minute.codeUnitAt(1) - 0x30;
    final sMsb = second.codeUnitAt(0) - 0x30;
    final sLsb = second.codeUnitAt(1) - 0x30;
    final sizedBoxWidth = const SizedBox(width: 1);

    return Container(
      // color: colors[_Element.background],
      decoration: BoxDecoration(
        gradient: dynamicGradient,
      ),
      child: Center(
        child: DefaultTextStyle(
          style: defaultStyle,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              sizedBoxWidth,
              Flexible(child: NixieTube(position: hMsb)),
              sizedBoxWidth,
              Flexible(child: NixieTube(position: hLsb)),
              Text("."),
              Flexible(child: NixieTube(position: mMsb)),
              sizedBoxWidth,
              Flexible(child: NixieTube(position: mLsb)),
              Text("."),
              Flexible(child: NixieTube(position: sMsb)),
              sizedBoxWidth,
              Flexible(child: NixieTube(position: sLsb)),
              sizedBoxWidth,
            ],
          ),
        ),
      ),
    );
  }

  Gradient _getGradientFrom(
    WeatherCondition weatherCondition,
    double temperatureCelcius,
  ) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final radialRadius = 2.0;
    final lightMap = {
      _Color.contrast: Colors.white,
      _Color.blue: Colors.blue,
      _Color.blueAccent: Colors.blueAccent,
      _Color.yellow: Colors.yellow,
      _Color.green: Colors.green,
      _Color.red: Colors.red,
      _Color.orange: Colors.orange,
      _Color.blueGrey: Colors.blueGrey,
    };

    final darkMap = {
      _Color.contrast: Colors.black,
      _Color.blue: Colors.indigo,
      _Color.blueAccent: Colors.indigoAccent,
      _Color.yellow: Colors.orange,
      _Color.green: Colors.green[900],
      _Color.red: Colors.red[900],
      _Color.orange: Colors.yellow[900],
      _Color.blueGrey: Colors.blueGrey[800],
    };
    final colorMap = isLight ? lightMap : darkMap;

    Gradient gradient;
    switch (weatherCondition) {
      // DONE, Light and Dark Mode
      case WeatherCondition.cloudy:
        final mainColor = colorMap[_Color.blue];
        final sideColor = isLight ? Colors.yellow[100] : Colors.orange[100];

        gradient = RadialGradient(
          colors: [
            sideColor,
            mainColor,
            sideColor,
          ],
          radius: radialRadius,
          center: Alignment.topLeft,
        );

        break;
      // DONE, Light and Dark mode
      case WeatherCondition.foggy:
        final colors = [
          colorMap[_Color.contrast],
          colorMap[_Color.blueGrey],
          colorMap[_Color.blue],
        ];

        gradient = RadialGradient(
          colors: colors,
          radius: radialRadius,
          center: Alignment.topLeft,
        );
        break;
      // DONE, Light and Dark Mode
      case WeatherCondition.rainy:
        // DONE, Check for temperature (EASTER EGG)
        final mainColor = isLight ? Colors.blue[200] : Colors.indigo[200];
        if (temperatureCelcius > 25.0) {
          gradient = SweepGradient(
            colors: <Color>[
              mainColor,
              colorMap[_Color.green],
              colorMap[_Color.yellow],
              colorMap[_Color.red],
              mainColor,
            ],
            center: Alignment.topLeft,
            startAngle: 0.5,
            endAngle: 1,
          );
        } else {
          gradient = RadialGradient(
            colors: <Color>[
              colorMap[_Color.contrast],
              mainColor,
              colorMap[_Color.contrast],
            ],
            radius: radialRadius,
            center: Alignment.topLeft,
          );
        }

        break;
      // DONE, Light and Dark Mode
      case WeatherCondition.snowy:
        gradient = SweepGradient(
          colors: <Color>[
            colorMap[_Color.contrast],
            colorMap[_Color.blueGrey],
            colorMap[_Color.blue],
            colorMap[_Color.contrast],
          ],
        );
        break;
      // DONE, light and dark mode
      case WeatherCondition.sunny:
        final middleColor = isLight ? Colors.yellow : Colors.red;

        gradient = RadialGradient(
          colors: <Color>[
            colorMap[_Color.orange],
            middleColor,
            colorMap[_Color.contrast],
          ],
          center: Alignment.topLeft,
          radius: 2,
        );

        break;
      // DONE, Light and Dark Mode
      case WeatherCondition.thunderstorm:
        gradient = LinearGradient(
          colors: <Color>[
            colorMap[_Color.blue],
            colorMap[_Color.blueAccent],
            colorMap[_Color.contrast],
            colorMap[_Color.blueAccent],
            colorMap[_Color.blue],
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        break;
      // DONE, Light and Dark Mode
      case WeatherCondition.windy:
        gradient = LinearGradient(
          colors: <Color>[
            colorMap[_Color.contrast],
            colorMap[_Color.blue],
          ],
        );
        break;
    }
    return gradient;
  }
}

/// [NixieTube]
/// Creates a one character NixieTube
class NixieTube extends StatelessWidget {
  static const NixieColorHighlight = Colors.red;
  static const NixieColorRadialCenter = Colors.orange;
  static const NixieColorShadow = Colors.orange;
  static const NixieColorRadialEnd = Colors.yellow;

  final int position;
  NixieTube({
    this.position,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _buildBoxDecoration(),
      child: Stack(
        children: <Widget>[
          for (int i = 9; i >= 0; i--) _buildPositioned(context, i.toString()),
          if (this.position != null)
            _buildPositioned(
              context,
              position.toString(),
              color: NixieColorHighlight[500],
            )
        ],
      ),
    );
  }

  BoxDecoration _buildBoxDecoration() {
    return BoxDecoration(
      gradient: RadialGradient(
        radius: 1,
        colors: <Color>[
          NixieColorRadialCenter[400],
          NixieColorRadialEnd[50],
        ],
      ),
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(40.0),
        bottom: Radius.circular(25.0),
      ),
      border: Border.all(width: 2.0),
      boxShadow: [
        BoxShadow(
          color: NixieColorShadow,
          blurRadius: 50.0,
        ),
      ],
    );
  }

  Widget _buildPositioned(BuildContext context, String value, {Color color}) {
    assert(value.length == 1);
    return Padding(
      padding: EdgeInsets.all(15.0),
      child: Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color == null ? null : color,
          shadows: color == null ? null : _buildShadowList(color),
        ),
      ),
    );
  }

  List<Shadow> _buildShadowList(Color color) {
    final blurRadius = 10.0;
    final offset = 1.0;
    return [
      Shadow(
        color: color,
        blurRadius: blurRadius,
        offset: Offset(offset, 0),
      ),
      Shadow(
        color: color,
        blurRadius: blurRadius,
        offset: Offset(-offset, 0),
      ),
    ];
  }
}
