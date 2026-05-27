import 'package:flutter/material.dart';
import '../services/home_service.dart';
import '../message/contacts/contacts_page.dart';
import '../login/login_page.dart';
import '../services/auth_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _homeService = MockHomeService.instance;
  late Future<List<String>> _slidesFuture;
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _slidesFuture = _homeService.fetchSliderImages();
    _productsFuture = _homeService.fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.message),
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => ContactsPage())),
          ),
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(
                  MockAuthService.instance.currentUser()?.name ?? 'Guest',
                ),
                accountEmail: Text(
                  MockAuthService.instance.currentUser()?.email ?? '',
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: NetworkImage(
                    MockAuthService.instance.currentUser()?.avatarUrl ??
                        'https://i.pravatar.cc/100',
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('My Profile'),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Setting'),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('About'),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
              const Spacer(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () async {
                  await MockAuthService.instance.logout();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _slidesFuture = _homeService.fetchSliderImages();
            _productsFuture = _homeService.fetchProducts();
          });
          await Future.wait([_slidesFuture, _productsFuture]);
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: FutureBuilder<List<String>>(
                future: _slidesFuture,
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final slides = snap.data ?? [];
                  return SizedBox(
                    height: 200,
                    child: PageView.builder(
                      itemCount: slides.length,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            slides[index],
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Products grid
            SliverPadding(
              padding: const EdgeInsets.all(8.0),
              sliver: FutureBuilder<List<Product>>(
                future: _productsFuture,
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return SliverToBoxAdapter(
                      child: SizedBox(
                        height: 200,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    );
                  }

                  final products = snap.data ?? [];
                  return SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          childAspectRatio: 0.78,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final p = products[index];
                      return _ProductTile(product: p);
                    }, childCount: products.length),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  final Product product;

  const _ProductTile({required this.product});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 1,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                child: Image.network(product.imageUrl, fit: BoxFit.cover),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                product.title,
                style: const TextStyle(fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
