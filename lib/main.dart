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
    // Landscape pics
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
      'Pellentesque euismod, arcu auctor dapibus lacinia, ex mauris elementum arcu, consequat euismod urna arcu at ex. Nulla ut est eu risus ultricies tempor. Curabitur ut semper mi. ';
  static String get para2 =>
      'Donec varius, diam a malesuada tincidunt, ante sem gravida lectus, scelerisque scelerisque nulla augue quis ligula. Quisque porttitor sapien nunc, a malesuada justo ornare et. Nullam vel elementum dui.';
}

class _ImagePaletteScreenState extends State<ImagePaletteScreen> {
  Map<List<int>, UiTheme> palettes = {};

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
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text('Image Palette Examples'),
          backgroundColor: Colors.transparent,
        ),
        body: PageView(
          children: palettes.keys.map<Widget>((image) {
            final theme = palettes[image]!;
            var bgColor = Color(theme.dark.toInt());
            var fgColor = Color(theme.light.toInt());

            return Container(
                color: bgColor,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      GestureDetector(
                        child: Image.memory(Uint8List.fromList(image)),
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
                          ImagePaletteScreen.title,
                          style: TextStyle(
                              color: fgColor,
                              fontSize: 22,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          ImagePaletteScreen.para1,
                          style: TextStyle(color: fgColor, fontSize: 18),
                        ),
                      ),
                      Container(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton.icon(
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Color(theme.primary.toInt()))),
                                  onPressed: () {},
                                  icon: Icon(Icons.star),
                                  label: Text('Primary')),
                              ElevatedButton.icon(
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Color(theme.secondary.toInt()))),
                                  onPressed: () {},
                                  icon: Icon(Icons.favorite),
                                  label: Text('Secondary')),
                            ],
                          )),
                      Container(
                        padding: EdgeInsets.all(16),
                        child: Card(
                            color: Color(theme.light.toInt()),
                            child: Container(
                              padding: EdgeInsets.all(16),
                              child: Text(ImagePaletteScreen.para2,
                                  style: TextStyle(
                                    color: Color(theme.dark.toInt()),
                                    fontSize: 18,
                                  )),
                            )),
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

  const SingleImagePaletteDebug({Key? key, required this.jpgBytes})
      : super(key: key);
  @override
  _SingleImagePaletteDebugState createState() =>
      _SingleImagePaletteDebugState();
}

class _SingleImagePaletteDebugState extends State<SingleImagePaletteDebug> {
  late UiTheme swatch;
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
    var bgColor = Color(swatch.dark.toInt());
    var fgColor = Color(swatch.light.toInt());

    return Scaffold(
        backgroundColor: Color(swatch.dark.toInt()),
        appBar: AppBar(
          title: Text('Single Image Palette Debug'),
          backgroundColor: Color(swatch.primary.toInt()),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _process,
          child: Icon(Icons.undo),
          backgroundColor: Color(swatch.primary.toInt()),
        ),
        body: swatch == null
            ? Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Image.memory(Uint8List.fromList(widget.jpgBytes)),
                    Container(
                      padding: EdgeInsets.only(top: 24, bottom: 8),
                      child: Center(
                          child: Text(
                        ImagePaletteScreen.title,
                        style: TextStyle(
                            color: fgColor,
                            fontSize: 22,
                            fontWeight: FontWeight.bold),
                      )),
                    ),
                    Container(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: Text(ImagePaletteScreen.para1,
                              style: TextStyle(
                                color: fgColor,
                                fontSize: 16,
                              )),
                        )),
                    Container(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Color(swatch.primary.toInt()))),
                                onPressed: () {},
                                icon: Icon(Icons.star),
                                label: Text('Primary')),
                            ElevatedButton.icon(
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Color(swatch.secondary.toInt()))),
                                onPressed: () {},
                                icon: Icon(Icons.favorite),
                                label: Text('Secondary')),
                          ],
                        )),
                    Container(
                      padding: EdgeInsets.all(16),
                      child: Card(
                          color: Color(swatch.light.toInt()),
                          child: Container(
                            padding: EdgeInsets.all(16),
                            child: Text(ImagePaletteScreen.para2,
                                style: TextStyle(
                                  color: Color(swatch.dark.toInt()),
                                  fontSize: 16,
                                )),
                          )),
                    ),
                    Container(
                      padding: EdgeInsets.all(16),
                      child: Card(
                          color: Colors.black,
                          child: Container(
                            padding: EdgeInsets.all(16),
                            child: Text(swatch.toHexArray().join(', '),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                )),
                          )),
                    ),
                  ],
                ),
              ));
  }
}
