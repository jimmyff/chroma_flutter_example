import 'package:flutter/material.dart';
import 'package:http/io_client.dart';
import 'package:lipsum/lipsum.dart' as lipsum;
import 'package:chroma/image_swatch.dart';
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
      home: ImagePalette(),
    );
  }
}

class ImagePalette extends StatefulWidget {
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
  _ImagePaletteState createState() => _ImagePaletteState();
}

class _ImagePaletteState extends State<ImagePalette> {
  Map<List<int>, ImageSwatch> images = {};
  @override
  void initState() {
    super.initState();
    _processExampleImages();
  }

  Future _processExampleImages() async {
    final http = IOClient();
    final futures = <Future>[];
    widget.exampleImageURLs.forEach((url) {
      futures.add(http.get(url).then((response) {
        if (response.statusCode == 200) {
          print('Downloaded $url');
          setState(() {
            images[response.bodyBytes] =
                ImageSwatch.fromJpg(response.bodyBytes);
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
          children: images.keys.map<Widget>((image) {
            var bgColor = Color.fromARGB(
                255,
                getRed(images[image].background),
                getGreen(images[image].background),
                getBlue(images[image].background));

            var fgColor = Color.fromARGB(
                255,
                getRed(images[image].foreground),
                getGreen(images[image].foreground),
                getBlue(images[image].foreground));

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
  ImageSwatch swatch;
  Map<Image, ImageSwatch> images = {};
  @override
  void initState() {
    super.initState();
    _process();
  }

  Future _process() async {
    setState(() {
      swatch = ImageSwatch.fromJpg(widget.jpgBytes, debug: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    var bgColor = Color.fromARGB(255, getRed(swatch.background),
        getGreen(swatch.background), getBlue(swatch.background));

    var fgColor = Color.fromARGB(255, getRed(swatch.foreground),
        getGreen(swatch.foreground), getBlue(swatch.foreground));

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
                      ...swatch.debug.reversed
                          .map((debug) => Container(
                                color: Colors.white,
                                child: Table(columnWidths: {
                                  0: FixedColumnWidth(64)
                                }, children: [
                                  TableRow(children: [
                                    TableCell(child: Container()),
                                    TableCell(
                                        child: Container(
                                            height: 64,
                                            padding: EdgeInsets.all(16),
                                            child: Text(
                                              debug.title,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            )))
                                  ]),
                                  ...debug.colors.keys
                                      .map((color) => TableRow(children: [
                                            TableCell(
                                                child: Container(
                                              color: Color.fromARGB(
                                                  255,
                                                  getRed(color),
                                                  getGreen(color),
                                                  getBlue(color)),
                                              height: 56,
                                            )),
                                            TableCell(
                                                child: Container(
                                                    color: Colors.white,
                                                    child: Text(
                                                      debug.colorDebugText(
                                                          color),
                                                    )))
                                          ]))
                                      .toList(),
                                ]),
                              ))
                          .toList()
                    ],
                  ),
                )));
  }
}
