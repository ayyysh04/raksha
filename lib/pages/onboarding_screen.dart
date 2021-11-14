import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:raksha/pages/homepage.dart';
import 'package:velocity_x/velocity_x.dart';

class OnBoardingPage extends StatefulWidget {
  @override
  _OnBoardingPageState createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  final introKey = GlobalKey<IntroductionScreenState>();

  void _onIntroEnd(context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => HomePage()),
    );
  }

  Widget _buildFullscrenImage() {
    return Image.asset(
      'assets/fullscreen.jpg',
      fit: BoxFit.cover,
      height: double.infinity,
      width: double.infinity,
      // alignment: Alignment.center,
    );
  }

  Widget _buildImage(String assetName, [double width = 350]) {
    return Image.asset('assets/$assetName', width: width);
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 19.0);

    const pageDecoration = const PageDecoration(
        titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
        bodyTextStyle: bodyStyle,
        pageColor: Colors.white,
        imagePadding: EdgeInsets.zero,
        footerPadding: EdgeInsets.zero,
        titlePadding: EdgeInsets.zero,
        descriptionPadding: EdgeInsets.zero);

    return IntroductionScreen(
      key: introKey,
      globalBackgroundColor: Colors.white,
      pages: [
        PageViewModel(
          title: "Raksha",
          body: "A Women Security App",
          image: _buildImage('img1.jpg'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Call Emergency number in one tap",
          body: "",
          image: _buildImage('img2.jpg'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "SOS message in one Tap",
          body: "",
          image: _buildImage('img3.jpg'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "",
          body: "",
          image: _buildFullscrenImage(),
          decoration: pageDecoration.copyWith(fullScreen: true),
        ),
      ],
      onSkip: () => introKey.currentState?.animateScroll(3),
      done: Container(
          decoration: BoxDecoration(
              color: Vx.amber300,
              border: Border.all(),
              borderRadius: BorderRadius.circular(20)),
          child: "Start".text.size(18).make().pSymmetric(h: 10, v: 10)),
      doneColor: Vx.black,
      onDone: () => _onIntroEnd(context),
      showSkipButton: true,
      showDoneButton: true,
      skipFlex: 0,
      nextFlex: 0,
      skip: 'Skip'.text.color(Vx.black).xl.make(),
      next: const Icon(
        Icons.arrow_forward,
        color: Vx.black,
        size: 35,
      ),
      curve: Curves.fastLinearToSlowEaseIn,
      controlsMargin: const EdgeInsets.all(16),
      controlsPadding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Color(0xFFBDBDBD),
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
    );
  }
}
