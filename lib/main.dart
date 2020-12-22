import 'package:flutter/material.dart';
import 'package:http/io_client.dart';
import 'package:lipsum/lipsum.dart' as lipsum;
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
    'https://images.pexels.com/photos/247431/pexels-photo-247431.jpeg?auto=compress&cs=tinysrgb&h=512&w=512',
    'https://images.pexels.com/photos/87403/cheetah-leopard-animal-big-87403.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=512&w=512',
    'https://images.pexels.com/photos/567540/pexels-photo-567540.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=512&w=512',
    'https://images.pexels.com/photos/2361/nature-animal-wolf-wilderness.jpg?auto=compress&cs=tinysrgb&dpr=2&h=512&w=512',
    'https://images.pexels.com/photos/460775/pexels-photo-460775.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=512&w=512',
    'https://images.pexels.com/photos/1059823/pexels-photo-1059823.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=512&w=512',
    'https://images.pexels.com/photos/36846/bald-eagle-adler-bird-of-prey-raptor.jpg?auto=compress&cs=tinysrgb&dpr=2&h=512&w=512',
    'https://images.pexels.com/photos/516541/pexels-photo-516541.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=512&w=512',
    'https://images.pexels.com/photos/1365264/pexels-photo-1365264.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=512&w=512',
    'https://images.pexels.com/photos/3390587/pexels-photo-3390587.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=512&w=512',
    'https://images.pexels.com/photos/2213575/pexels-photo-2213575.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=512&w=512',
    'https://images.pexels.com/photos/3220368/pexels-photo-3220368.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=512&w=512',
  ];

  @override
  _ImagePaletteScreenState createState() => _ImagePaletteScreenState();
}

class _ImagePaletteScreenState extends State<ImagePaletteScreen> {
  Map<List<int>, UiTheme> palettes = {};
  @override
  void initState() {
    super.initState();
    _processExampleImages();
  }

  Future _processExampleImages() async {
    final http = IOClient();
    final futures = <Future>[];
    widget.exampleImageURLs
        // .sublist(2, 5)

        .forEach((url) {
      futures.add(http.get(url).then((response) {
        if (response.statusCode == 200) {
          print('Downloaded $url');
          setState(() {
            palettes[response.bodyBytes] = UiTheme.fromJpg(response.bodyBytes);
          });
        } else
          print('Failed to download image $url #${response.statusCode}');
      }));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Image Palette Examples'),
        ),
        body: PageView(
          children: palettes.keys.map<Widget>((image) {
            var bgColor = Color.fromARGB(
              255,
              (palettes[image].bg.red * 255).toInt(),
              (palettes[image].bg.green * 255).toInt(),
              (palettes[image].bg.blue * 255).toInt(),
            );

            var fgColor = Color.fromARGB(
              255,
              (palettes[image].fg.red * 255).toInt(),
              (palettes[image].fg.green * 255).toInt(),
              (palettes[image].fg.blue * 255).toInt(),
            );

            return Container(
                color: bgColor,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      GestureDetector(
                        child: Image.memory(image),
                        onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    SingleImagePaletteDebug(
                                      jpgBytes: image,
                                    ))),
                      ),
                      Container(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          lipsum.createWord(numWords: 4),
                          style: TextStyle(
                              color: fgColor,
                              fontSize: 22,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          lipsum.createParagraph(),
                          style: TextStyle(color: fgColor, fontSize: 18),
                        ),
                      )
                    ],
                  ),
                ));
          }).toList(),
        ));
  }
}

class SingleImagePaletteDebug extends StatefulWidget {
  final List<int> jpgBytes;

  const SingleImagePaletteDebug({Key key, this.jpgBytes}) : super(key: key);
  @override
  _SingleImagePaletteDebugState createState() =>
      _SingleImagePaletteDebugState();
}

class _SingleImagePaletteDebugState extends State<SingleImagePaletteDebug> {
  UiTheme swatch;
  Map<Image, UiTheme> palettes = {};
  @override
  void initState() {
    super.initState();
    _process();
  }

  Future _process() async {
    setState(() {
      swatch = UiTheme.fromJpg(widget.jpgBytes, debug: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    var bgColor = Color.fromARGB(
      255,
      (swatch.bg.red * 255).toInt(),
      (swatch.bg.green * 255).toInt(),
      (swatch.bg.blue * 255).toInt(),
    );

    var fgColor = Color.fromARGB(
      255,
      (swatch.fg.red * 255).toInt(),
      (swatch.fg.green * 255).toInt(),
      (swatch.fg.blue * 255).toInt(),
    );

    return Scaffold(
        appBar: AppBar(
          title: Text('Single Image Palette Debug'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _process,
          child: Icon(Icons.undo),
        ),
        body: swatch == null
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Container(
                color: bgColor,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Image.memory(widget.jpgBytes),
                      Container(
                        height: 96,
                        padding: EdgeInsets.all(16),
                        child: Center(
                            child: Text(
                          lipsum.createWord(numWords: 3),
                          style: TextStyle(
                              color: fgColor,
                              fontSize: 22,
                              fontWeight: FontWeight.bold),
                        )),
                      ),
                    ],
                  ),
                )));
  }
}
