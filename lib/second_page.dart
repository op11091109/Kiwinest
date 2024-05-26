import 'package:flutter/material.dart';
import 'dart:io';

class SecondPage extends StatefulWidget {
  const SecondPage({Key? key}) : super(key: key);

  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  String? _filePath;
  double _sliderValue = 0.0;
  double _cycleValue = 0.0;
  static const int maxLength = 30;

  final _algorithms = ['RSA'];
  String? _selectedalgo;

  List<Map<String, dynamic>> files = [];

  @override
  void initState() {
    super.initState();
    _selectedalgo = _algorithms[0];
  }

  void _uploadFile() {
    setState(() {
      files.add({
        'location': 'Location',
        'name': 'File Name',
        'status': 'Status',
      });
    });
  }

  Future<void> _pickFile() async {
    // File picking functionality
    // After picking the file, call _encryptFolder function
    _encryptFolder();
  }

  Future<void> _encryptFolder() async {
    String folderPath = '/path/to/your/folder'; // Specify the folder path
    Directory folder = Directory(folderPath);
    if (!await folder.exists()) {
      // Create the folder if it doesn't exist
      await folder.create();
    }
    // Encrypt the folder using selected algorithm and security settings
    // You may need to use external encryption libraries or system commands here
    // Example:
    // Run shell command to encrypt the folder
    // await Process.run('encryption_command', [folderPath]);
    print('Folder encrypted successfully.');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffE0E0E0),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('보안 디렉토리'),
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  color: Colors.white,
                  width: 500,
                  child: DataTable(
                    dataRowColor: MaterialStateProperty.all(Colors.white),
                    columns: const <DataColumn>[
                      DataColumn(label: Text('File Location')),
                      DataColumn(label: Text('File Name')),
                      DataColumn(label: Text('Status')),
                    ],
                    rows: List.generate(
                      files.length,
                          (index) => DataRow(cells: [
                        DataCell(Text(files[index]['location'] ?? '')),
                        DataCell(Text(files[index]['name'] ?? '')),
                        DataCell(Text(files[index]['status'] ?? '')),
                      ]),
                    ),
                  ),
                ),
                const SizedBox(height: 100),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _uploadFile,
                      child: const Text('Fetch'),
                    ),
                    const SizedBox(width: 50),
                    ElevatedButton(
                      onPressed: null,
                      child: const Text('Eject'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}