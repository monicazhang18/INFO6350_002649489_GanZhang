import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:garage_sale/product.dart'; // Import CachedNetworkImage

class PostsDetailActivity extends StatefulWidget {
  final Product post;

  const PostsDetailActivity({Key? key, required this.post}) : super(key: key);

  @override
  State<PostsDetailActivity> createState() => _PostsDetailActivityState();
}

// 添加大图查看页面
class FullScreenImagePage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImagePage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent, // 透明背景
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return InteractiveViewer(
            panEnabled: true,
            boundaryMargin: EdgeInsets.zero,
            minScale: 0.1,
            maxScale: 5.0,
            child: Center(
              // 添加Center组件实现居中
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth,
                  maxHeight: constraints.maxHeight,
                ),
                child: _buildImageContent(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageContent() {
    return imageUrl.isEmpty
        ? Image.asset('assets/images/placeholder.png', fit: BoxFit.contain)
        : CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.contain,
          placeholder:
              (context, url) => const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
          errorWidget:
              (context, url, error) =>
                  const Icon(Icons.error, color: Colors.white, size: 40),
        );
  }
}

class _PostsDetailActivityState extends State<PostsDetailActivity> {
  final _pageController = PageController();
  int _currentPosition = 0;
  // Add a images list
  late List<String> _images; // 改为延迟初始化
  @override
  void initState() {
    super.initState();
    //init images
    // 动态初始化图片列表
    _images =
        [
          widget.post.imageUrl,
          widget.post.imageUrl_1,
          widget.post.imageUrl_2,
          widget.post.imageUrl_3,
        ].where((url) => url.isNotEmpty).toList(); // 过滤空字符串

    if (_images.isEmpty) {
      _images.add(''); // 保证至少有一个占位图
    }

    _pageController.addListener(() {
      setState(() {
        _currentPosition = _pageController.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildNetworkImage(String imageUrl) {
    final showPlaceholder = imageUrl.isEmpty;

    return showPlaceholder
        ? Image.asset('assets/images/placeholder.png', fit: BoxFit.cover)
        : CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder:
              (context, url) => Container(
                color: Colors.grey[200],
                child: const Center(child: CircularProgressIndicator()),
              ),
          errorWidget:
              (context, url, error) => Image.asset(
                'assets/images/error_placeholder.png',
                fit: BoxFit.cover,
              ),
        );
  }

  void _openFullScreen(String imageUrl) {
    if (imageUrl.isEmpty) return; // 占位图不打开大图

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenImagePage(imageUrl: imageUrl),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detailed Post Information'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 200,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: _images.length,
                  itemBuilder: (context, index) {
                    final imageUrl = _images[index];
                    return GestureDetector(
                      onTap: () => _openFullScreen(imageUrl),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: _buildNetworkImage(imageUrl),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          if (_images.length > 1)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Center(
                // 添加Center组件实现水平居中
                child: DotsIndicator(
                  dotsCount: _images.length,
                  position: _currentPosition,
                  decorator: const DotsDecorator(
                    color: Colors.grey,
                    activeColor: Colors.black,
                    spacing: EdgeInsets.all(4),
                  ),
                ),
              ),
            ),

          Stack(
            children: [
              // 底层组件（被覆盖的布局）
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity, // 容器宽度
                      height: 60, // 容器高度
                      decoration: BoxDecoration(
                        color: Colors.purple, // 背景颜色
                      ),
                      child: Center(
                        // 居中文本
                        child: Text(
                          widget.post.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    Container(
                      width: double.infinity, // 容器宽度
                      height: 60, // 容器高度
                      decoration: BoxDecoration(
                        color: Colors.purple, // 背景颜色
                      ),
                      child: Center(
                        // 居中文本
                        child: Text(
                          widget.post.description,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    Container(
                      width: double.infinity, // 容器宽度
                      height: 30, // 容器高度
                      decoration: BoxDecoration(
                        color: Colors.yellow, // 背景颜色
                      ),
                    ),
                  ],
                ),
              ),

              // 覆盖在上层的组件
              // 覆盖在上层的组件 (修改为 Positioned)
              Positioned(
                // 关键：指定距离 Stack 底部的距离
                bottom: 10.0,
                // 关键：设置 left 和 right 为 0，让 Positioned 在水平方向填满 Stack
                left: 0,
                right: 0,
                // 使用 Align 或 Center 将实际内容（红色圆圈）在其可用的水平空间内居中
                child: Align(
                  alignment: Alignment.center, // 水平居中
                  child: Container(
                    width: 60, // 直径
                    height: 60, // 直径
                    decoration: BoxDecoration(
                      color: Colors.red, // 红色背景
                      shape: BoxShape.circle, // 圆形
                    ),
                    child: Center(
                      // 保证文字在圆圈内部居中
                      child: Text(
                        '\$${widget.post.price}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // 白色字体
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
