import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:kiwinest/rsa.dart'; // RSA 클래스를 가져옵니다.
import 'dart:io';
import 'dart:convert';
import 'second_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await createAppFolder();
  await createRSAKeyFile(); // RSA 키 파일을 생성합니다.

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

    // 폴더를 숨김 처리
    await _hideFolder(newFolderPath);
  } else {
    print('이미 폴더가 존재합니다.');
  }
}
Future<void> _hideFolder(String folderPath) async {
  if (Platform.isWindows) {
    await _hideFolderWindows(folderPath);
  } else if (Platform.isMacOS || Platform.isLinux) {
    await _hideFolderUnix(folderPath);
  } else {
    print('Hiding folders is not supported on this platform.');
  }
}

Future<void> _hideFolderWindows(String folderPath) async {
  try {
    final result = await Process.run('attrib', ['+h', folderPath]);
    if (result.exitCode == 0) {
      print('Folder hidden successfully on Windows.');
    } else {
      print('Failed to hide folder on Windows: ${result.stderr}');
    }
  } catch (e) {
    print('Failed to hide folder on Windows: $e');
  }
}

Future<void> _hideFolderUnix(String folderPath) async {
  final directory = Directory(folderPath);
  final parentDir = directory.parent.path;
  final hiddenFolderPath = '$parentDir/.${directory.uri.pathSegments.last}';

  try {
    await directory.rename(hiddenFolderPath);
    print('Folder hidden successfully on Unix-based system.');
  } catch (e) {
    print('Failed to hide folder on Unix-based system: $e');
  }
}

Future<void> createRSAKeyFile() async {
  // 앱 디렉토리 가져오기
  Directory appDir = await getApplicationDocumentsDirectory();
  String keyFilePath = '${appDir.path}/Nest/rsa_key.txt';

  // 키 파일이 이미 존재하는지 확인
  if (!(await File(keyFilePath).exists())) {
    RSA rsa = RSA();
    rsa.generatePQ();
    rsa.generatePublicKey();
    rsa.generatePrivateKey();

    // 키를 텍스트 파일로 저장
    File keyFile = File(keyFilePath);
    await keyFile.writeAsString(rsa.toKeyString());

    print('RSA 키 파일이 생성되었습니다.');
  } else {
    print('RSA 키 파일이 이미 존재합니다.');
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
      });

      // 파일의 확장자가 txt가 아닌 경우, 해당 파일의 사본을 만들어 txt 파일로 변환합니다.
      if (!_filePath!.toLowerCase().endsWith('.txt')) {
        try {
          // 선택한 파일을 읽어옵니다.
          File originalFile = File(_filePath!);
          List<int> bytes = await originalFile.readAsBytes();

          // 원래 파일의 확장자 저장
          String originalExtension = _filePath!.split('.').last;

          // 파일의 확장자를 변경하여 사본 파일을 생성합니다.
          String txtFilePath = _filePath!.replaceAll(originalExtension, 'txt');
          File txtFile = File(txtFilePath);

          // 파일의 내용을 txt 파일로 작성합니다.
          await txtFile.writeAsBytes(bytes);

          // 파일을 암호화합니다.
          await _encryptDocument(txtFilePath, originalExtension);

          // 암호화된 파일이 생성된 후, 중간에 생성된 txt 파일을 삭제합니다.
          await txtFile.delete();
        } catch (e) {
          print('파일을 처리하는 도중 오류가 발생했습니다: $e');
        }
      } else {
        // txt 파일인 경우 암호화합니다.
        await _encryptDocument(_filePath!, 'txt');
      }
    }
  }

  Future<void> _encryptDocument(String filePath, String originalExtension) async {
    RSA rsa = RSA();
    Directory appDir = await getApplicationDocumentsDirectory();
    String keyFilePath = '${appDir.path}/Nest/rsa_key.txt';
    await rsa.loadKeysFromFile(keyFilePath);

    String encryptedFilePath = filePath.replaceAll('.txt', '_encrypted.$originalExtension');

    File file = File(filePath);
    String content = await file.readAsString(); // 파일 내용을 문자열로 읽기

    List<int> encryptedContent = rsa.encryptLine(content);

    String encryptedData = encryptedContent.join(',');

    File encryptedFile = File(encryptedFilePath);
    await encryptedFile.writeAsString(encryptedData); // 인코딩된 문자열을 파일에 쓰기

    _uploadFile(encryptedFilePath, 'Encrypted');

    _filePath = encryptedFilePath;
  }

  Future<void> _decryptDocument(String filePath) async {
    RSA rsa = RSA();
    Directory appDir = await getApplicationDocumentsDirectory();
    String keyFilePath = '${appDir.path}/Nest/rsa_key.txt';
    await rsa.loadKeysFromFile(keyFilePath);

    File encryptedFile = File(filePath);
    String encryptedContent = await encryptedFile.readAsString(); // 암호화된 문자열 읽기

    List<int> encryptedData = encryptedContent.split(',').map(int.parse).toList(); // 숫자 형태로 저장된 암호화된 데이터 읽기

    String decryptedContent = rsa.decryptLine(encryptedData); // 데이터 복호화

    String decryptedFilePath = filePath.replaceAll('_encrypted', '_decrypted');
    File decryptedFile = File(decryptedFilePath);
    await decryptedFile.writeAsString(decryptedContent);

    _uploadFile(decryptedFilePath, 'Decrypted');

    _filePath = decryptedFilePath;
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
                  '키 파일 생성',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  '키 파일을 분실하였을 때 사용하세요. 이전의 암호화 파일들은 되돌릴 수 없습니다.',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.normal, color: Colors.red),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _pickFile,
                  child: Text('생성'),
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