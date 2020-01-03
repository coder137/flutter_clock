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

/// A basic digital clock.
///
/// You can do better than this!
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
    final colors = Theme.of(context).brightness == Brightness.light
        ? _lightTheme
        : _darkTheme;
    final hour =
        DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
    final minute = DateFormat('mm').format(_dateTime);
    final second = DateFormat('ss').format(_dateTime);

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
          offset: Offset(0, 0),
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
      color: colors[_Element.background],
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
}

/// [NixieTube]
/// Creates a one character NixieTube
class NixieTube extends StatelessWidget {
  static const NixieColorHighlight = Colors.red;
  static const NixieColorRadialCenter = Colors.orange;
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
        top: Radius.circular(25.0),
        bottom: Radius.circular(25.0),
      ),
      border: Border.all(width: 2.0),
      boxShadow: [
        BoxShadow(
          color: Constants.ColorShadow,
          blurRadius: 10.0,
          offset: Offset(0, 0),
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
