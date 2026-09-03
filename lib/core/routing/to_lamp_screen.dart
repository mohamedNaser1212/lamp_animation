import 'package:animate_training/lamp/pull_cord_lamp.dart';
import 'package:flutter/material.dart';

extension ToLampScreen on BuildContext{
  void toLamp(){
   Navigator.push(
      this,
      MaterialPageRoute(builder: (context) => PullCordLamp()),
    );
  }
}