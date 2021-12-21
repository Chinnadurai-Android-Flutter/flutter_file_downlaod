import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  final String pdfURL =
      "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf";
  final String fileName = "dummy.pdf";
  final Dio dio = Dio();

  String progress = "-";

  @override
  void initState() {
    super.initState();
  }

  Future<Directory?> getDownloadDirectory() async {
    if (Platform.isAndroid) {
      return await getExternalStorageDirectory();
    }
    return await getApplicationDocumentsDirectory();
  }

  void onReceiveProgress(int received, int total) {
    if (total != -1) {
      setState(() {
        progress = (received / total * 100).toStringAsFixed(0) + "%";
      });
    }
  }

  Future<void> startDownload(String savePath) async {
    debugPrint('path---> $savePath');
    Response? response;
    try {
      response = await dio.download(pdfURL, savePath,
          onReceiveProgress: onReceiveProgress);
    } catch (ex) {
      debugPrint('Erro--> ${ex.toString()}');
    } finally {
      response!.statusCode == 200
          ? debugPrint(
              'File has been downloaded successfully! \nSavedPath$savePath}')
          : debugPrint('There was an error while downloading the file.');
    }
  }

  Future<void> download() async {
    final dir = await getDownloadDirectory();
    final savePath = path.join(dir!.path, fileName);
    await startDownload(savePath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Download progress:',
            ),
            Text(
              '$progress',
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: download,
        tooltip: 'Download',
        child: Icon(Icons.file_download),
      ),
    );
  }
}
