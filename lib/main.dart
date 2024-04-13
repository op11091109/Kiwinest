import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'second_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xff6AE084)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: '문서 / 코드 암호화'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? _filePath;
  double _containerWidth = 500;
  static const int maxLength = 30;

  final _algorithms = ['RSA'];
  String? _selectedalgo;

  double _sliderValue = 0.0;
  double _cycleValue = 0.0;

  List<Map<String, dynamic>> files = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      _selectedalgo = _algorithms[0];
    });
  }

  void _uploadFile() {
    // 파일 업로드 기능 추가
    // 업로드가 완료되면 setState를 호출하여 files 리스트에 새 파일 정보를 추가
    setState(() {
      files.add({
        'location': 'Location',
        'name': 'File Name',
        'status': 'Status',
      });
    });
  }

  void _navigateToSecondPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SecondPage()),
    );
  }

    Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        _filePath = result.files.single.path!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffE0E0E0),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: _navigateToSecondPage,
            icon: Icon(Icons.arrow_forward),
          ),
        ],
      ),
      body: Center(
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    color: Colors.white,
                    width: 500, // 원하는 가로 크기로 지정
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
                          DataCell(Text(files[index]['location'] ?? '')), // null일 경우 빈 문자열을 표시
                          DataCell(Text(files[index]['name'] ?? '')),     // null일 경우 빈 문자열을 표시
                          DataCell(Text(files[index]['status'] ?? '')),   // null일 경우 빈 문자열을 표시
                        ]),
                      ),
                    ),
                  ),
                  const SizedBox(height:100),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: _uploadFile,
                        child: Text('암호화'),
                      ),
                      const SizedBox(width: 50),
                      ElevatedButton(
                        onPressed: null,
                        child: Text('복호화'),
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(width: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: <Widget>[
                      const SizedBox(height: 100),
                      Text('암호 알고리즘 선택', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                            _selectedalgo = value!;
                          });
                        },
                      ),

                      const SizedBox(height: 130),
                      Text('키 값 안전성 설정', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                      Text('키 파일 경로', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      Container(
                        width: 200,
                        padding: EdgeInsets.all(10),
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
                        child: Text('Browse..'),
                      ),

                      const SizedBox(height: 100),
                      Text('클린업 사이클 설정', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                        child: Text('비밀번호를 잊으셨나요?'),
                      ),
                    ],
                  ),
                ],
              ),
            ]
        ),
      ),
    );
  }
}