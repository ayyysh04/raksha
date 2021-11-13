import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:raksha/Utils/home/customer_painter/circle_painter.dart';
import 'package:raksha/Utils/home/customer_painter/curve_wave.dart';
import 'package:velocity_x/velocity_x.dart';

class EmergencyButton extends StatefulWidget {
  const EmergencyButton(
      {Key? key,
      this.size = 80.0,
      required this.onPressed,
      required this.child,
      required this.alerted,
      required this.message})
      : super(key: key);
  final double size;
  final Color color = Vx.red500;
  final Image child;
  final ValueChanged<bool> onPressed;
  final bool? alerted;
  final String message;
  @override
  _EmergencyButtonState createState() => _EmergencyButtonState();
}

class _EmergencyButtonState extends State<EmergencyButton>
    with TickerProviderStateMixin {
  AnimationController? _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Widget _button() {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.size),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: <Color>[
                widget.color,
                Color.lerp(widget.color, Colors.black, .05)!
              ],
            ),
          ),
          child: ScaleTransition(
              scale: Tween(begin: 0.95, end: 1.0).animate(
                CurvedAnimation(
                  parent: _controller!,
                  curve: CurveWave(),
                ),
              ),
              child: widget.child.p(15)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
            painter: CirclePainter(
              _controller!,
              color: widget.color,
            ),
            child: SizedBox(
              width: widget.size * 3,
              height: widget.size * 3,
              child: GestureDetector(
                child: _button(),
                onTap: () {
                  if (widget.alerted == null || widget.alerted == false)
                    widget.onPressed(false);
                  else
                    widget.onPressed(true);
                },
              ),
            )),
        Positioned(
            top: 170,
            child: widget.message.text
                .fontFamily(GoogleFonts.poppins().fontFamily!)
                .lg
                .center
                .color(Vx.black)
                .make())
      ],
    );
  }
}
