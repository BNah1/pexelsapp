import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pexelsapp/widget/preview_page.dart';
import '../model/image.dart';
import '../repository/repository.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Repository repo = Repository();
  final ScrollController scrollController = ScrollController();
  final ScrollController gridScrollController = ScrollController(); // Separate controller for the grid
  final TextEditingController textEditingController = TextEditingController();
  late Future<List<Images>> imagesList;
  int pageNumber = 1;
  final List<String> categories = [
    'University',
    'Technology',
    'Game',
    'Movie',
    'VietNam',
  ];

  @override
  void initState() {
    super.initState();
    imagesList = repo.getImagesList(pageNumber: pageNumber);
    scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      pageNumber++;
      imagesList = repo.getImagesList(pageNumber: pageNumber);
      setState(() {});
    }
  }

  @override
  void dispose() {
    textEditingController.dispose();
    scrollController.dispose();
    gridScrollController.dispose(); // Dispose the grid controller
    super.dispose();
  }

  void getImagesBySearch({required String query}) {
    imagesList = repo.getImagesBySearch(query: query);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Pexels', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.blue, fontSize: 22)),
            Text(' App', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.orange, fontSize: 15)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        controller: scrollController,
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: textEditingController,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(left: 25),
                  labelText: 'Search',
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.grey, width: 2),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.grey, width: 2),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      getImagesBySearch(query: textEditingController.text);
                    },
                    icon: const Icon(Icons.search),
                  ),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]')),
                ],
                onSubmitted: (value) {
                  getImagesBySearch(query: value);
                },
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              height: 40,
              child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      getImagesBySearch(query: categories[index]);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey, width: 1),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                          child: Center(
                            child: Text(categories[index]),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            FutureBuilder<List<Images>>(
              future: imagesList,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Something went wrong'),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                imagesList = repo.getImagesList(pageNumber: pageNumber);
                              });
                            },
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: MasonryGridView.count(
                      controller: gridScrollController, // Use the separate grid controller
                      itemCount: snapshot.data?.length ?? 0,
                      shrinkWrap: true,
                      mainAxisSpacing: 5,
                      crossAxisSpacing: 5,
                      crossAxisCount: 2,
                      itemBuilder: (context, index) {
                        double height = (index % 10 + 1) * 100;
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PreviewPage(
                                  imageId: snapshot.data![index].imageID,
                                  imageUrl: snapshot.data![index].imagePotraitPath,
                                ),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(
                              fit: BoxFit.cover,
                              height: height > 300 ? 300 : height,
                              imageUrl: snapshot.data![index].imagePotraitPath,
                              errorWidget: (context, url, error) => const Icon(Icons.error),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
