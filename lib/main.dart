import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:kiwinest/rsa.dart'; // RSA 클래스를 가져옵니다.
import 'dart:io';
import 'second_page.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await createAppFolder();

  runApp(const MyApp());
}

Future<void> createAppFolder() async {
  // 앱 디렉토리 가져오기
  Directory appDir = await getApplicationDocumentsDirectory();

  // 새로운 폴더 경로 생성
  String newFolderPath = '${appDir.path}/Nest';

  // 폴더가 존재하지 않는 경우에만 폴더 생성
  if (!(await Directory(newFolderPath).exists())) {
    await Directory(newFolderPath).create(recursive: true);
    print('폴더가 생성되었습니다.');
  } else {
    print('이미 폴더가 존재합니다.');
  }
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
  static const int maxLength = 30;

  final _algorithms = ['RSA'];
  String? _selectedalgo;

  double _sliderValue = 0.0;
  double _cycleValue = 0.0;

  List<Map<String, dynamic>> files = [];
  bool _isDecryptionEnabled = false;
  int _selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    setState(() {
      _selectedalgo = _algorithms[0];
    });
  }

  void _uploadFile(String filePath, String status) {
    setState(() {
      files.add({
        'location': filePath,
        'status': status,
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
        _encryptDocument();
      });
    }
  }

  Future<void> _encryptDocument() async {
    if (_filePath == null) {
      print('파일을 선택하세요.');
      return;
    }

    RSA rsa = RSA();
    rsa.generatePQ();
    rsa.generatePublicKey();
    rsa.generatePrivateKey();

    // 암호화된 파일을 저장할 경로
    String encryptedFilePath = _filePath!.replaceAll('.txt', '_encrypted.txt');

    File file = File(_filePath!);
    String content = file.readAsStringSync();

    // 파일을 암호화합니다.
    List<int> encryptedContent = rsa.encryptLine(content);

    // 암호화된 내용을 파일에 저장합니다.
    File encryptedFile = File(encryptedFilePath);
    encryptedFile.writeAsBytesSync(encryptedContent);

    // 파일 업로드 기능 추가
    _uploadFile(encryptedFilePath, 'Encrypted');
  }

  Future<void> _decryptDocument(String filePath) async {
    // 복호화된 파일을 선택하면 원본 파일로 복호화합니다.
    RSA rsa = RSA();
    rsa.generatePQ();
    rsa.generatePublicKey();
    rsa.generatePrivateKey();

    File encryptedFile = File(filePath);
    List<int> encryptedContent = await encryptedFile.readAsBytes();

    // 파일을 복호화합니다.
    String decryptedContent = rsa.decryptLine(encryptedContent);

    // 복호화된 내용을 파일에 저장합니다.
    String decryptedFilePath = filePath.replaceAll('_encrypted.txt', '_decrypted.txt');
    File decryptedFile = File(decryptedFilePath);
    decryptedFile.writeAsStringSync(decryptedContent);

    // 파일 업로드 기능 추가
    _uploadFile(decryptedFilePath, 'Decrypted');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffE0E0E0),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Row(
          children: [
            Text(widget.title),
            SizedBox(width: 8),
            IconButton(
              onPressed: _navigateToSecondPage,
              icon: Icon(Icons.arrow_forward),
            ),
          ],
        ),
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
                      DataColumn(label: Text('Status')),
                    ],
                    rows: List.generate(
                      files.length,
                          (index) => DataRow(cells: [
                        DataCell(
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isDecryptionEnabled = true;
                                _selectedIndex = index; // Store selected index
                              });
                            },
                            child: Text(files[index]['location'] ?? ''),
                          ),
                        ),
                        DataCell(Text(files[index]['status'] ?? '')),
                      ]),
                    ),
                  ),
                ),
                const SizedBox(height: 100),
                ElevatedButton(
                  onPressed: _pickFile,
                  child: Text('암호화'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isDecryptionEnabled ? () {
                    if (_selectedIndex != -1) {
                      _decryptDocument(files[_selectedIndex]['location']);
                    }
                  } : null,
                  child: Text('복호화'),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(_isDecryptionEnabled ? Colors.blue : Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 50),
            Column(
              children: <Widget>[
                const SizedBox(height: 100),
                Text(
                  '암호 알고리즘 선택',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
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
                Text(
                  '키 값 안전성 설정',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
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
                Text(
                  '키 파일 경로',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
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
                Text(
                  '클린업 사이클 설정',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
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
      ),
    );
  }
}