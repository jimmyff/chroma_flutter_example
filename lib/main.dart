import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:chroma/chroma.dart';
import 'package:image/image.dart' hide Color, Image;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chroma Example',
      home: ImagePaletteScreen(),
    );
  }
}

class ImagePaletteScreen extends StatefulWidget {
  final exampleImageURLs = [
    // // Landscape pics
    'https://images.pexels.com/photos/247431/pexels-photo-247431.jpeg?auto=compress&cs=tinysrgb&h=512&w=512',
    'https://images.pexels.com/photos/567540/pexels-photo-567540.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=512&w=512',
    'https://images.pexels.com/photos/460775/pexels-photo-460775.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=512&w=512',
    'https://images.pexels.com/photos/516541/pexels-photo-516541.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=512&w=512',
    'https://images.pexels.com/photos/3220368/pexels-photo-3220368.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=512&w=512',
    'https://images.pexels.com/photos/3293148/pexels-photo-3293148.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=512&w=512',
    'https://images.pexels.com/photos/4457409/pexels-photo-4457409.jpeg?auto=compress&cs=tinysrgb&h=512&w=512',
    'https://images.pexels.com/photos/2662116/pexels-photo-2662116.jpeg?auto=compress&cs=tinysrgb&h=512&w=512',
    'https://images.pexels.com/photos/60342/pexels-photo-60342.jpeg?auto=compress&cs=tinysrgb&h=512&w=512',

    // Portrait pics
    // 'https://images.pexels.com/photos/2213575/pexels-photo-2213575.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=512&w=512',
    // 'https://images.pexels.com/photos/3390587/pexels-photo-3390587.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=512&w=512',
    // 'https://images.pexels.com/photos/1365264/pexels-photo-1365264.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=512&w=512',
    // 'https://images.pexels.com/photos/36846/bald-eagle-adler-bird-of-prey-raptor.jpg?auto=compress&cs=tinysrgb&dpr=2&h=512&w=512',
    // 'https://images.pexels.com/photos/1059823/pexels-photo-1059823.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=512&w=512',
    // 'https://images.pexels.com/photos/2361/nature-animal-wolf-wilderness.jpg?auto=compress&cs=tinysrgb&dpr=2&h=512&w=512',
    // 'https://images.pexels.com/photos/87403/cheetah-leopard-animal-big-87403.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=512&w=512',
  ];

  @override
  _ImagePaletteScreenState createState() => _ImagePaletteScreenState();

  static String get title => 'Lorem ipsum dolor sit';
  static String get para1 =>
      'Pellentesque euismod, arcu auctor dapibus lacinia, ex mauris elementum arcu. ';
  static String get para2 =>
      'Donec varius, diam a malesuada tincidunt, ante sem gravida lectus, scelerisque scelerisque nulla augue quis ligula. Quisque porttitor sapien nunc, a malesuada justo ornare et. Nullam vel elementum dui.';
}

class _ImagePaletteScreenState extends State<ImagePaletteScreen> {
  Map<Uint8List, List<List<ColorRgb>>> palettes = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _processExampleImages();
  }

  Future _processExampleImages() async {
    final client = http.Client();
    ;
    final futures = <Future>[];
    widget.exampleImageURLs
        // .sublist(2, 5)

        .forEach((url) {
      futures.add(client.get(Uri.parse(url)).then((response) {
        print('HTTP GET $url #${response.statusCode}');
        if (response.statusCode == 200) {
          setState(() {
            palettes[response.bodyBytes] =
                UiTheme.fromJpg(response.bodyBytes, 5);
          });
        } else
          print('Failed to download image $url #${response.statusCode}');
      }));
    });
    await Future.wait(futures);
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text('Image Palette Examples'),
          backgroundColor: Colors.transparent,
        ),
        body: loading
            ? Container(
                child: Center(
                child: CircularProgressIndicator.adaptive(),
              ))
            : PageView(
                children: palettes.keys.map<Widget>((image) {
                  final theme = palettes[image]!;

                  return Container(
                      child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Image.memory(
                          Uint8List.fromList(image),
                        ),
                        ...theme.map<Widget>((List<ColorRgb> theme) {
//
                          final primary = Color(theme[0].toInt());
                          final secondary = Color(theme[1].toInt());
                          return Container(
                              color: primary,
                              child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(16),
                                      child: Text(
                                        ImagePaletteScreen.title,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(16),
                                      child: Text(
                                        ImagePaletteScreen.para1,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 18),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(16),
                                      child: ElevatedButton.icon(
                                          style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all(
                                                      secondary)),
                                          onPressed: () {},
                                          icon: Icon(Icons.favorite),
                                          label: Text('Secondary')),
                                    ),
                                  ]));
                        }),
                      ],
                    ),
                  ));
                }).toList(),
              ));
  }
}
