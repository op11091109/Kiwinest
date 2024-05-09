import 'package:flutter/material.dart';

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
            const SizedBox(width: 50),
            Column(
              children: <Widget>[
                const SizedBox(height: 100),
                Text('암호 알고리즘 선택', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                DropdownButton(
                  value: _selectedalgo,
                  items: _algorithms
                      .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedalgo = value as String?;
                    });
                  },
                ),
                const SizedBox(height: 130),
                Text('키 값 안전성 설정', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Slider(
                  value: _cycleValue,
                  min: 0,
                  max: 100,
                  divisions: 10,
                  activeColor: _cycleValue >= 50 ? Colors.green : Colors.red,
                  onChanged: (newValue) {
                    setState(() {
                      _cycleValue = newValue;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(width: 70),
            Column(
              children: <Widget>[
                const SizedBox(height: 100),
                Text('키 파일 경로', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Container(
                  width: 200,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _filePath != null
                      ? Text(
                    _filePath!.length > maxLength
                        ? 'Path: ${_filePath!.substring(0, maxLength)}...'
                        : 'Path: $_filePath',
                    textAlign: TextAlign.center,
                  )
                      : const SizedBox(),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _pickFile,
                  child: const Text('Browse..'),
                ),
                const SizedBox(height: 100),
                Text('클린업 사이클 설정', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Slider(
                  value: _sliderValue,
                  min: 0,
                  max: 100,
                  divisions: 10,
                  activeColor: _sliderValue >= 50 ? Colors.green : Colors.red,
                  onChanged: (newValue) {
                    setState(() {
                      _sliderValue = newValue;
                    });
                  },
                ),
                const SizedBox(height: 70),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('비밀번호를 잊으셨나요?'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}