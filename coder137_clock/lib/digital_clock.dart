// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

enum _Element {
  background,
  text,
  shadow,
}

final _lightTheme = {
  _Element.background: Color(0xFF81B3FE),
  _Element.text: Colors.white,
  _Element.shadow: Colors.orange,
};

final _darkTheme = {
  _Element.background: Colors.grey,
  _Element.text: Colors.white,
  // _Element.shadow: Color(0xFF174EA6),
  _Element.shadow: Colors.orange,
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

    // ! TODO, Add the nixieOne package without need for internet connection (IMPORTANT)
    final defaultStyle = GoogleFonts.nixieOne(
      fontSize: fontSize,
      fontWeight: FontWeight.w100,
    ).copyWith(color: colors[_Element.text], shadows: [
      Shadow(
        blurRadius: 5,
        color: colors[_Element.shadow],
        offset: Offset(0, 0),
      ),
    ]);

    final hMsb = hour.codeUnitAt(0) - 0x30;
    final hLsb = hour.codeUnitAt(1) - 0x30;
    final mMsb = minute.codeUnitAt(0) - 0x30;
    final mLsb = minute.codeUnitAt(1) - 0x30;
    final sMsb = second.codeUnitAt(0) - 0x30;
    final sLsb = second.codeUnitAt(1) - 0x30;

    // TODO, Have a better container background
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
              Flexible(child: NixieTube(position: hMsb)),
              Flexible(child: NixieTube(position: hLsb)),
              Text("."),
              Flexible(child: NixieTube(position: mMsb)),
              Flexible(child: NixieTube(position: mLsb)),
              Text("."),
              Flexible(child: NixieTube(position: sMsb)),
              Flexible(child: NixieTube(position: sLsb)),
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
  final int position;

  NixieTube({
    this.position,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        for (int i = 9; i >= 0; i--) _buildPositioned(context, i.toString()),
        if (this.position != null)
          _buildPositioned(
            context,
            position.toString(),
            color: Colors.red[500],
          )
      ],
    );
  }

  Widget _buildPositioned(BuildContext context, String value, {Color color}) {
    assert(value.length == 1);
    return LayoutBuilder(
      // TODO, Improve this to have a better border background
      builder: (context, constraints) => Container(
        width: constraints.maxWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(25.0),
            bottom: Radius.circular(25.0),
          ),
          border: Border.all(width: 2.0),
        ),
        child: Padding(
          padding: EdgeInsets.all(15.0),
          child: Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color == null ? null : color,
              fontWeight: color == null ? FontWeight.w100 : null,
              shadows: color == null ? null : _buildShadowList(color),
            ),
          ),
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
