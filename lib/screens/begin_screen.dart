import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_movie_shop/model/carousel_model.dart';
import 'package:flutter_movie_shop/model/movie_model.dart';
import 'package:flutter_movie_shop/model/star_model.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';

import '../const/url.dart';
import 'detail_screen.dart';

class BeginScreen extends StatefulWidget {
  const BeginScreen({super.key});

  @override
  State<BeginScreen> createState() => _BeginScreenState();
}

class _BeginScreenState extends State<BeginScreen> {
  List<CarouselModel> carouselList = [];
  List<MovieModel> movieList1 = [];
  List<MovieModel> movieList2 = [];
  List<StarModel> starList = [];

  bool carousel = false;
  bool movie = false;
  bool star = false;

  callCarouselApi() async {
    final url = Uri.parse('$movieUrl=pageviewmovie');
    carousel = true;
    final Response _response = await get(url);
    carousel = false;
    if (_response.statusCode == 200) {
      final data = jsonDecode(_response.body);

      for (int i = 0; i < data.length; i++) {
        setState(() {
          carouselList.add(
            CarouselModel(
              id: data[i]['id'],
              imgSlide: data[i]['img_slide'],
              name: data[i]['name'],
            ),
          );
        });
      }
    }
  }

  callMovie1Api(String inputUrl, List<MovieModel> movieList) async {
    final url = Uri.parse('$movieUrl=$inputUrl');
    movie = true;
    final Response response = await get(url);
    movie = false;
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      for (int i = 0; i < data.length; i++) {
        setState(() {
          movieList.add(
            MovieModel(
              id: data[i]['id'],
              name: data[i]['name'],
              desc: data[i]['description'],
              saleSakht: data[i]['saleSakht'],
              price: data[i]['price'],
              imageUrl: data[i]['image_url'],
              keshvar: data[i]['keshvar'],
              zaman: data[i]['zaman'],
            ),
          );
        });
      }
    }
  }

  callStarApi() async {
    final url = Uri.parse('$movieUrl=stars');
    star = true;
    final Response response = await get(url);
    star = false;
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      for (int i = 0; i < data.length; i++) {
        setState(() {
          starList.add(
            StarModel(
              id: data[i]['id'],
              name: data[i]['name'],
              pic: data[i]['pic'],
            ),
          );
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    callCarouselApi();
    callMovie1Api('movie1', movieList1);
    callMovie1Api('movie2', movieList2);
    callStarApi();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            carousel
                ? LoadingWidget(width: width)
                : CarouselWidget(carouselList: carouselList, width: width),
            movie
                ? LoadingWidget(width: width)
                : MovieSection(
                    width: width,
                    movieModel: movieList1,
                    title: 'پرفروش ترین',
                  ),
            const SizedBox(height: 10),
            star ? LoadingWidget(width: width) : StarMovieSection(starList: starList),
            movie
                ? LoadingWidget(width: width)
                : MovieSection(
                    width: width,
                    movieModel: movieList2,
                    title: 'تازه ترین',
                  ),
          ],
        ),
      ),
    );
  }
}

class StarMovieSection extends StatelessWidget {
  const StarMovieSection({
    super.key,
    required this.starList,
  });

  final List<StarModel> starList;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 155,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: starList.length,
        itemBuilder: (context, index) {
          return StartItem(starList: starList, index: index);
        },
      ),
    );
  }
}

class StartItem extends StatelessWidget {
  const StartItem({
    super.key,
    required this.starList, required this.index,
  });

  final List<StarModel> starList;
  final int index;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Column(
        children: [
          Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(250),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(250),
              child: FadeInImage(
                placeholder: const AssetImage('assets/images/logo.png'),
                image: NetworkImage(starList[index].pic),
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Text(
            starList[index].name,
            style: const TextStyle(fontFamily: 'bold'),
          )
        ],
      ),
    );
  }
}

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({
    super.key,
    required this.width,
  });

  final double width;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 200,
        child: SpinKitFadingFour(
          color: Colors.deepPurpleAccent,
          size: width * 0.15,
        ),
      ),
    );
  }
}

class MovieSection extends StatelessWidget {
  const MovieSection({
    super.key,
    required this.width,
    required this.movieModel,
    required this.title,
  });

  final double width;
  final List<MovieModel> movieModel;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontFamily: 'bold', fontSize: 20),
              ),
              const Text(
                'بیشتر >',
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontFamily: 'bold', fontSize: 16),
              )
            ],
          ),
        ),
        SizedBox(
          width: width,
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: movieModel.length,
            itemBuilder: (context, index) {
              final helper = movieModel[index];
              return MovieItems(helper: helper);
            },
          ),
        ),
      ],
    );
  }
}

class MovieItems extends StatelessWidget {
  const MovieItems({
    super.key,
    required this.helper,
  });

  final MovieModel helper;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 175,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DetailScreen(id: helper.id),
            ),
          );
        },
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0, right: 8, left: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: FadeInImage(
                    placeholder: const AssetImage('assets/images/logo.png'),
                    image: NetworkImage(helper.imageUrl),
                    width: 150,
                    height: 160,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  helper.name,
                  maxLines: 1,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'bold',
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  helper.price + ',000 تومان',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontFamily: 'bold', color: Colors.green),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CarouselWidget extends StatelessWidget {
  const CarouselWidget({
    super.key,
    required this.carouselList,
    required this.width,
  });

  final List<CarouselModel> carouselList;
  final double width;

  @override
  Widget build(BuildContext context) {
    return CarouselSlider.builder(
      itemCount: carouselList.length,
      itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) => Stack(
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 5,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                carouselList[itemIndex].imgSlide,
                width: width,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            bottom: 25,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(7.5),
              ),
              child: Text(
                carouselList[itemIndex].name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'bold',
                ),
              ),
            ),
          )
        ],
      ),
      options: CarouselOptions(
        autoPlay: true,
        enlargeCenterPage: true,
        viewportFraction: 0.95,
      ),
    );
  }
}
