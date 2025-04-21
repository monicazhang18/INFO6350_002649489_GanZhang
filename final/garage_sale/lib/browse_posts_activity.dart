import 'package:flutter/material.dart';
import 'package:garage_sale/new_post_activity.dart';
import 'package:garage_sale/posts_detail_activity.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:garage_sale/product.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth

class BrowsePostsActivity extends StatefulWidget {
  const BrowsePostsActivity({Key? key}) : super(key: key);

  @override
  _BrowsePostsActivityState createState() => _BrowsePostsActivityState();
}

class _BrowsePostsActivityState extends State<BrowsePostsActivity> {
  final List<Product> _posts = [];
  bool _isLoading = true; // Add a loading state

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final ref = FirebaseDatabase.instance.ref('product');

      ref.onValue.listen((DatabaseEvent event) {
        setState(() {
          _isLoading = true; // Show loading again when data changes
        });
        DataSnapshot snapshot = event.snapshot;
        if (snapshot.exists && snapshot.value != null) {
          final Map<dynamic, dynamic> products = snapshot.value as Map;
          final List<Product> newPosts = [];
          products.forEach((key, value) {
            final name = value['product_name']?.toString() ?? 'Uknown';
            final description = value['product_desc']?.toString() ?? '';
            final price = value['product_price']?.toString() ?? '0';
            final imageUrl =
                value['product_img_1']?.toString() ?? ''; //Get image url.
            final imageUrl_1 =
                value['product_img_2']?.toString() ?? ''; //Get image url.
            final imageUrl_2 =
                value['product_img_3']?.toString() ?? ''; //Get image url.
            final imageUrl_3 =
                value['product_img_4']?.toString() ?? ''; //Get image url.
            newPosts.add(
              Product(
                title: name,
                description: description,
                price: price,
                imageUrl: imageUrl,
                imageUrl_1: imageUrl_1,
                imageUrl_2: imageUrl_2,
                imageUrl_3: imageUrl_3,
              ),
            );
          });
          setState(() {
            _posts.clear();
            _posts.addAll(newPosts);
            _isLoading = false;
          });
        } else {
          print('商品数据为空');
          setState(() {
            _isLoading = false;
          });
        }
      });
    } catch (e) {
      print('数据加载失败: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Posts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Sign out and close the app
              await FirebaseAuth.instance.signOut();
              SystemNavigator.pop();
            },
          ),
          PopupMenuButton<String>(
            onSelected: (String item) {
              // TODO: Implement menu item selection
            },
            itemBuilder: (BuildContext context) {
              return [
                // const PopupMenuItem<String>(
                //   value: 'Settings',
                //   child: Text('Settings'),
                // ),
              ];
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.separated(
                padding: const EdgeInsets.all(6),
                itemCount: _posts.length,
                separatorBuilder:
                    (BuildContext context, int index) =>
                        const SizedBox(height: 6),
                itemBuilder: (BuildContext context, int index) {
                  final product = _posts[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => PostsDetailActivity(post: product),
                        ),
                      );
                    },
                    child: Container(
                      height: 65,
                      color: Colors.deepPurple,
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: SizedBox(
                              width: 45,
                              height: 45,
                              child:
                                  product.imageUrl.isEmpty
                                      ? Image.asset(
                                        'assets/images/placeholder.png', // Use placeholder if no url.
                                        fit: BoxFit.cover,
                                      )
                                      : CachedNetworkImage(
                                        //Use network image and cache.
                                        imageUrl: product.imageUrl,
                                        fit: BoxFit.cover,
                                        placeholder:
                                            (context, url) =>
                                                const CircularProgressIndicator(),
                                        errorWidget:
                                            (context, url, error) =>
                                                const Icon(Icons.error),
                                      ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  product.title,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                Text(
                                  product.description,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Text(
                              '\$${product.price}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NewPostActivity()),
          );
        },
        tooltip: 'Add Post',
        child: const Icon(Icons.add),
      ),
    );
  }
}
