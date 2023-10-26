import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_movie_shop/const/url.dart';
import 'package:flutter_movie_shop/model/movie_model.dart';
import 'package:http/http.dart';

import 'begin_screen.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.id});

  final String id;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  MovieModel? movieModel;
  bool isLoading = false;

  callDetailApi(String id) async {
    final url = Uri.parse('$movieUrl=getMovieData&id=$id');
    isLoading = true;
    final Response response = await get(url);
    isLoading = false;
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        movieModel = MovieModel(
          id: data['id'],
          name: data['name'],
          desc: data['description'],
          saleSakht: data['saleSakht'],
          price: data['price'],
          imageUrl: data['image_url'],
          keshvar: data['keshvar'],
          zaman: data['zaman'],
        );
      });
    }
  }

  @override
  void initState() {
    super.initState();
    callDetailApi(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
      ),
      body: isLoading
          ? LoadingWidget(width: width)
          : SingleChildScrollView(
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(45),
                      bottomRight: Radius.circular(45),
                    ),
                    child: Image.network(
                      movieModel!.imageUrl,
                      width: width,
                      height: 350,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movieModel!.name,
                          style: const TextStyle(
                            fontFamily: 'bold',
                            fontSize: 22,
                          ),
                        ),
                        Text(
                          movieModel!.desc,
                          style: const TextStyle(fontSize: 14),
                        ),
                        SizedBox(height: 10),
                        Container(
                          width: width,
                          child: Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            children: [
                              MovieInfo(
                                value: movieModel!.keshvar,
                                title: 'ساخت',
                              ),
                              MovieInfo(
                                value: movieModel!.price,
                                title: 'هزینه',
                              ),
                              MovieInfo(
                                value: movieModel!.zaman,
                                title: 'مدت',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class MovieInfo extends StatelessWidget {
  const MovieInfo({
    super.key,
    required this.value,
    required this.title,
  });

  final String value;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        alignment: Alignment.center,
        width: 100,
        height: 100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: TextStyle(fontSize: 18, fontFamily: 'bold'),
            ),
            SizedBox(height: 5),
            Text(
              title,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
