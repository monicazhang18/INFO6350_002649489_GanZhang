import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hero Animations Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MainMenu(),
    );
  }
}

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hero Animations Menu')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('1. Standard Hero'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StandardHeroPage()),
            ),
          ),
          ListTile(
            title: const Text('2. Radial Hero'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RadialHeroPage()),
            ),
          ),
          ListTile(
            title: const Text('3. Multiple Hero Tags'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MultiHeroPage()),
            ),
          ),
          ListTile(
            title: const Text('4. Animated Curve Hero'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CurveHeroPage()),
            ),
          ),
          ListTile(
            title: const Text('5. Custom Transform Hero'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CustomHeroPage()),
            ),
          ),
        ],
      ),
    );
  }
}

//------------------------------------------------------------------------------
// 1. Standard Hero Animation
//------------------------------------------------------------------------------
class StandardHeroPage extends StatelessWidget {
  const StandardHeroPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Standard Hero')),
      body: Center(
        child: GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HeroDetailPage()),
          ),
          child: Hero(
            tag: 'standard',
            child: Image.asset('images/lake.jpg', width: 100),
          ),
        ),
      ),
    );
  }
}

class HeroDetailPage extends StatelessWidget {
  const HeroDetailPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hero Detail')),
      body: Center(
        child: Hero(
          tag: 'standard',
          child: Image.asset('images/lake.jpg', width: 300),
        ),
      ),
    );
  }
}

//------------------------------------------------------------------------------
// 2. Radial Hero Animation
//------------------------------------------------------------------------------
class RadialHeroPage extends StatelessWidget {
  const RadialHeroPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Radial Hero')),
      body: Center(
        child: GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RadialDetailPage()),
          ),
          child: Hero(
            tag: 'radial',
            createRectTween: (begin, end) =>
                MaterialRectCenterArcTween(begin: begin, end: end),
            child: RadialExpansion(
              maxRadius: 50,
              child: Image.asset('images/lake.jpg', fit: BoxFit.cover),
            ),
          ),
        ),
      ),
    );
  }
}

class RadialDetailPage extends StatelessWidget {
  const RadialDetailPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Radial Detail')),
      body: Center(
        child: Hero(
          tag: 'radial',
          createRectTween: (begin, end) =>
              MaterialRectCenterArcTween(begin: begin, end: end),
          child: Image.asset(
            'images/lake.jpg',
            width: 300,
            height: 300,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

/// 官方 RadialExpansion：
/// 用 SizedBox 定义起始半径，再 ClipOval 裁圆形
class RadialExpansion extends StatelessWidget {
  final double maxRadius;
  final Widget child;
  const RadialExpansion({
    super.key,
    required this.maxRadius,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox(
        width: maxRadius * 2,
        height: maxRadius * 2,
        child: child,
      ),
    );
  }
}

//------------------------------------------------------------------------------
// 3. Multiple Hero Tags
//------------------------------------------------------------------------------
class MultiHeroPage extends StatelessWidget {
  const MultiHeroPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Multiple Heroes')),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(3, (index) {
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => MultiDetailPage(index: index)),
            ),
            child: Hero(
              tag: 'multi$index',
              child: Image.asset('images/lake.jpg', width: 80),
            ),
          );
        }),
      ),
    );
  }
}

class MultiDetailPage extends StatelessWidget {
  final int index;
  const MultiDetailPage({required this.index, super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Hero $index Detail')),
      body: Center(
        child: Hero(
          tag: 'multi$index',
          child: Image.asset('images/lake.jpg', width: 300),
        ),
      ),
    );
  }
}

//------------------------------------------------------------------------------
// 4. Animated Curve Hero
//------------------------------------------------------------------------------
class CurveHeroPage extends StatelessWidget {
  const CurveHeroPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Animated Curve')),
      body: Center(
        child: GestureDetector(
          onTap: () => Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(seconds: 1),
              pageBuilder: (_, __, ___) => const CurveDetailPage(),
            ),
          ),
          child: Hero(
            tag: 'curve',
            flightShuttleBuilder: (context, animation, direction, from, to) {
              return ScaleTransition(scale: animation, child: from.widget);
            },
            child: Image.asset('images/lake.jpg', width: 100),
          ),
        ),
      ),
    );
  }
}

class CurveDetailPage extends StatelessWidget {
  const CurveDetailPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Curve Detail')),
      body: Center(
        child: Hero(
          tag: 'curve',
          child: Image.asset('images/lake.jpg', width: 300),
        ),
      ),
    );
  }
}

//------------------------------------------------------------------------------
// 5. Custom Transform Hero
//------------------------------------------------------------------------------
class CustomHeroPage extends StatelessWidget {
  const CustomHeroPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Custom Transform Hero')),
      body: Center(
        child: GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CustomDetailPage()),
          ),
          child: Hero(
            tag: 'custom',
            child: Transform.rotate(
              angle: 0.3,
              child: Image.asset('images/lake.jpg', width: 100),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomDetailPage extends StatelessWidget {
  const CustomDetailPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Custom Detail')),
      body: Center(
        child: Hero(
          tag: 'custom',
          child: Transform.rotate(
            angle: 0,
            child: Image.asset('images/lake.jpg', width: 300),
          ),
        ),
      ),
    );
  }
}
