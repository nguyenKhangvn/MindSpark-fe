import 'package:flutter/material.dart';
import 'dart:math';

class FlashcardView extends StatefulWidget {
  final String frontText;
  final String backText;

  const FlashcardView(
      {super.key, required this.frontText, required this.backText});

  @override
  State<FlashcardView> createState() => _FlashcardViewState();
}

class _FlashcardViewState extends State<FlashcardView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  void _flipCard() {
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() {
      _isFront = !_isFront;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flipCard,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          // Calculate rotation angle
          final angle = _animation.value * pi;
          final isBackVisible = angle >= pi / 2;

          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // 3D perspective
              ..rotateY(angle),
            alignment: Alignment.center,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              color: Colors.white,
              child: Container(
                width: double.infinity,
                height: 400,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(24),
                // If flipped more than 90 degrees, rotate content back so it's readable
                child: Transform(
                  transform: Matrix4.identity()
                    ..rotateY(isBackVisible ? pi : 0),
                  alignment: Alignment.center,
                  child: Text(
                    isBackVisible ? widget.backText : widget.frontText,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: const Color(0xFF2563EB), // MindSpark Blue
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
