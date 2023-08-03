import 'dart:io';

import 'package:file_manager/controller/file_manager_controller.dart';
import 'package:file_manager/file_manager.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FileManagerController controller = FileManagerController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      body: FileManager(
        controller: controller,
        builder: (BuildContext context, List<FileSystemEntity> snapshot) {
          final List<FileSystemEntity> entities = snapshot;
          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            itemCount: entities.length,
            itemBuilder: (BuildContext context, int index) {
              FileSystemEntity entity = entities[index];
              return Card(
                child: ListTile(
                  leading: FileManager.isFile(entity)
                      ? Icon(Icons.feed_outlined)
                      : Icon(Icons.folder),
                  title: Text(
                    FileManager.basename(entity, showFileExtension: true),
                  ),
                  subtitle: subTitle(entity),
                  onTap: () async {
                    // delete  a folder or file
                    // await entity.delete();

                    // rename a folder or file
                    // await entity.rename("newPath");

                    //check exists or not
                    // await entity.exists();

                    //get data of folder or file
                    // DateTime date = (await entity.stat()).modified;

                    if (FileManager.isDirectory(entity)) {
                      controller.openDirectory(entity);
                    } else {}
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Permission.storage.request();
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (_) => MyHomePage(title: "FIle Manager")),
              (route) => false);
        },
        label: Text("Request File Access Permission"),
      ),
    );
  }

  appBar(BuildContext context) {
    return AppBar(
      actions: [
        IconButton(
          onPressed: () => createFolder(context),
          icon: Icon(
            Icons.create_new_folder_outlined,
          ),
        ),
        IconButton(
          onPressed: () => sort(context),
          icon: Icon(
            Icons.sort_rounded,
          ),
        ),
        IconButton(
          onPressed: () => selectStorage(context),
          icon: Icon(
            Icons.sd_storage_rounded,
          ),
        ),
      ],
      title: ValueListenableBuilder(
        valueListenable: controller.titleNotifier,
        builder: (BuildContext context, String value, Widget? child) {
          return Text(value);
        },
      ),
      leading: IconButton(
        onPressed: () async {
          await controller.goToParentDirectory();
        },
        icon: Icon(
          Icons.arrow_back,
        ),
      ),
    );
  }

  createFolder(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        var folderCreate = TextEditingController();
        return Dialog(
          child: Container(
            padding: EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: TextField(
                    controller: folderCreate,
                  ),
                ),
                ElevatedButton(
                    onPressed: () async {
                      try {
                        await FileManager.createFolder(
                            controller.getCurrentPath, folderCreate.text);
                        controller.setCurrentPath =
                            controller.getCurrentPath + "/" + folderCreate.text;
                        Navigator.pop(context);
                      } catch (e) {
                        Navigator.pop(context);
                      }
                    },
                    child: Text("Create Folders"))
              ],
            ),
          ),
        );
      },
    );
  }

  sort(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        var folderCreate = TextEditingController();
        return Dialog(
          child: Container(
            padding: EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text("Name"),
                  onTap: () {
                    controller.sortBy(SortBy.name);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text("Size"),
                  onTap: () {
                    controller.sortBy(SortBy.size);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text("Date"),
                  onTap: () {
                    controller.sortBy(SortBy.date);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text("Type"),
                  onTap: () {
                    controller.sortBy(SortBy.type);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  selectStorage(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: FutureBuilder<List<Directory>>(
              future: FileManager.getStorageList(),
              builder: (context, snapshot) {
                final List<FileSystemEntity> storgeList = snapshot.data!;
                return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: storgeList
                        .map((e) => ListTile(
                              title: Text("${FileManager.basename(e)}"),
                              onTap: () {
                                controller.openDirectory(e);
                                Navigator.pop(context);
                              },
                            ))
                        .toList());
              }),
        );
      },
    );
  }

  subTitle(FileSystemEntity entity) {
    return FutureBuilder(
      future: entity.stat(),
      builder: (BuildContext context, AsyncSnapshot<FileStat> snapshot) {
        if (snapshot.hasData) {
          if (entity is File) {
            int size = snapshot.data!.size;
            return Text("${FileManager.formatBytes(size)}");
          }
          return Text("${snapshot.data!.modified}");
        } else {
          return Text("");
        }
      },
    );
  }
}
