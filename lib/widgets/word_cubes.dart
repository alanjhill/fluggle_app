import 'package:fluggle_app/widgets/letter_cube.dart';
import 'package:fluggle_app/constants/constants.dart';
import 'package:fluggle_app/pages/game/game_page.dart';
import 'package:flutter/material.dart';

class WordCubes extends StatefulWidget {
  const WordCubes({Key? key, required this.word, required this.width, required this.spacing, this.wordStatus}) : super(key: key);
  final String word;
  final double width;
  final double spacing;
  final WordStatus? wordStatus;

  @override
  _WordCubesState createState() => _WordCubesState();
}

class _WordCubesState extends State<WordCubes> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late Animation<Color?> _animationValid;
  late Animation<Color?> _animationDuplicate;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
    _animationValid = ColorTween(
      begin: Colors.lightGreenAccent,
      end: kFluggleLetterColor,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    _animationDuplicate = ColorTween(
      begin: Colors.red,
      end: kFluggleLetterColor,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant WordCubes oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.wordStatus == WordStatus.invalid) {
      _animationController.forward();
    } else if (widget.wordStatus == WordStatus.valid) {
      _animationController.forward();
    } else if (widget.wordStatus == WordStatus.duplicate) {
      _animationController.forward();
    } else {
      _animationController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    double cubeSize = widget.width / 8.0;
    if (widget.word.length > 8) {
      cubeSize = widget.width / widget.word.length;
    }
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          for (String letter in widget.word.split(""))
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                debugPrint('${_animationController.value}');
                return LetterCube(
                  letter: letter,
                  size: _getCubeSize(size: cubeSize - widget.spacing),
                  textColor: _getTextColor(),
                );
              },
            )
        ],
      ),
    );
  }

  double _getCubeSize({required double size}) {
    if (widget.wordStatus == WordStatus.invalid) {
      var s = size * (1 - _animationController.value);
      debugPrint('size: $s');
      return s;
    } else {
      var s = size;
      debugPrint('size: $s');
      return size;
    }
  }

  Color _getTextColor() {
    if (widget.wordStatus == WordStatus.valid) {
      return _animationValid.value!;
    } else if (widget.wordStatus == WordStatus.invalid) {
      return Colors.red;
    } else if (widget.wordStatus == WordStatus.duplicate) {
      return _animationDuplicate.value!;
    } else {
      return kFluggleLetterColor;
    }
  }
}
