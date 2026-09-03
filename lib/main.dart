import 'dart:developer';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Animate Training',
      debugShowCheckedModeBanner: false,
      home: SizingIn(),
    );
  }
}

class SizingIn extends StatefulWidget {
  const SizingIn({super.key});

  @override
  State<SizingIn> createState() => _SizingInState();
}

class _SizingInState extends State<SizingIn> {
  late final X x;

  late final ValueNotifier<double> _controller;

  int? _selected;

  @override
  void initState() {
    super.initState();
    x = X(width: 20, height: 20);
    x.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    x.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          x.setWidth();
          x.setheight();
        },
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // _Animations(),
              //  ChangeNotifierControllerWidget(x: x),

              Expanded(
                child: ListView.separated(
                  itemBuilder:
                      (context, index) => ContainerItem(
                        index: index,
                        selectedIndex: _selected,
                        onChnaged: (selectedIndex) {
                          _selected = selectedIndex;
                          setState(() {});
                        },
                      ),
                  separatorBuilder:
                      (context, index) => const SizedBox(height: 20),
                  itemCount: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ContainerItem extends StatefulWidget {
  final int index;
  final int? selectedIndex;
  final Function(int index) onChnaged;
  const ContainerItem({
    super.key,
    required this.index,
    required this.onChnaged,
    required this.selectedIndex,
  });

  @override
  State<ContainerItem> createState() => _ContainerItemState();
}

class _ContainerItemState extends State<ContainerItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _sizeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _sizeAnimation = Tween<double>(begin: 80, end: 200).animate(_controller);

    _controller.forward();
  }

  bool get _isSelected => widget.selectedIndex == widget.index;
  void _onTap() {
    if (_isSelected) {
      return;
    }
    log('Selected item: ${widget.index}');
    widget.onChnaged(widget.index);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: SlideTransition(
        position: _slideAnimation,
        child: AnimatedBuilder(
          animation: _sizeAnimation,
          builder:
              (context, child) => Container(
                width: _sizeAnimation.value,
                height: _sizeAnimation.value,
                decoration: BoxDecoration(
                  color: _isSelected ? Colors.red : Colors.amberAccent,
                  border: Border.all(
                    color: _isSelected ? Colors.white : Colors.black,
                  ),
                ),
                child: child,
              ),
          child: Text('index:${widget.index}'),
        ),
      ),
    );
  }
}

class ChangeNotifierControllerWidget extends StatelessWidget {
  final X x;
  const ChangeNotifierControllerWidget({super.key, required this.x});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: x.width,
      height: x.height,
      color: Colors.amber,
      child: Center(child: Text('new items')),
    );
  }
}

class X extends ChangeNotifier {
  double width;
  double height;

  X({required this.width, required this.height});

  void setWidth() {
    width = width * 2;
    notifyListeners();
  }

  void setheight() {
    height = height * 2;
    notifyListeners();
  }
}

class _Animations extends StatefulWidget {
  const _Animations({super.key});

  @override
  State<_Animations> createState() => _AnimationsState();
}

class _AnimationsState extends State<_Animations>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _opacity = Tween<double>(begin: 0.5, end: 1).animate(_controller);
    _colorAnimation = ColorTween(
      begin: Colors.white,
      end: Colors.red,
    ).animate(_controller);

    _opacity.addStatusListener((status) {
      if (status.isDismissed) {
        _controller.forward();
      } else if (status.isCompleted) {
        _controller.reverse();
      }
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnimatedSwitcher(
          transitionBuilder:
              (child, animation) =>
                  FadeTransition(opacity: _opacity, child: child),
          duration: Duration(seconds: 2),
          child: Text('data', style: TextStyle(fontSize: 32)),
        ),

        AnimatedBuilder(
          animation: _colorAnimation,
          builder:
              (context, child) => AnimatedContainer(
                color: _colorAnimation.value,
                duration: Duration(seconds: 2),
                child: child,
              ),
          child: Text('conatiner'),
        ),
        AnimatedBuilder(
          animation: _colorAnimation,
          builder:
              (context, child) => AnimatedRotation(
                turns: _opacity.value,
                duration: Duration(seconds: 2),
                child: Text('conatiner'),
              ),
        ),
      ],
    );
  }
}
