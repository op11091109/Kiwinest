import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

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
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
              'You have pushed the button this many times:',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}

class SecondPage extends StatefulWidget {
  const SecondPage({Key? key}) : super(key: key);

  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  List<Map<String, dynamic>> files = [];
  int _selectedRowIndex = -1; // 클릭한 행의 인덱스

  @override
  void initState() {
    super.initState();
  }

  void _uploadFile() async {
    // 파일 선택 다이얼로그 열기
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    // 사용자가 파일을 선택한 경우
    if (result != null) {
      // 선택한 파일의 정보 가져오기
      PlatformFile? file = result.files.isNotEmpty ? result.files.first : null;

      if (file != null) {
        // 파일 이름과 바이너리 데이터 가져오기
        String fileName = file.name;
        List<int> fileBytes = file.bytes ?? [];

        // Nest 폴더 경로 가져오기
        Directory appDir = await getApplicationDocumentsDirectory();
        String nestFolderPath = '${appDir.path}/Nest';

        // Nest 폴더가 존재하지 않는 경우 생성
        if (!(await Directory(nestFolderPath).exists())) {
          await Directory(nestFolderPath).create(recursive: true);
        }

        // 목적지 파일 경로
        String destinationPath = '$nestFolderPath/$fileName';

        try {
          // 파일 복사
          await File(destinationPath).writeAsBytes(fileBytes);

          // 파일 정보 추가
          setState(() {
            files.add({
              'location': destinationPath,
              'name': fileName,
              'status': 'Uploaded',
            });
          });
        } catch (e) {
          print('파일 업로드 중 오류 발생: $e');
        }
      }
    }
  }

  void _selectRow(int index) {
    setState(() {
      _selectedRowIndex = index; // 클릭한 행의 인덱스 저장
    });
  }

  void _ejectFile() async {
    if (_selectedRowIndex != -1) {
      // 선택한 행의 파일 정보 가져오기
      Map<String, dynamic> selectedFile = files[_selectedRowIndex];

      // 현재 파일의 위치와 이름 가져오기
      String location = selectedFile['location'];
      String name = selectedFile['name'];

      // 문서 폴더 경로 가져오기
      Directory docDir = await getApplicationDocumentsDirectory();
      String docFolderPath = docDir.path;

      // 목적지 파일 경로
      String destinationPath = '$docFolderPath/$name';

      try {
        // 파일 이동
        await File(location).copy(destinationPath);

        // 파일 삭제
        await File(location).delete();

        // 파일 정보 업데이트
        setState(() {
          files.removeAt(_selectedRowIndex); // 선택한 파일 제거
          _selectedRowIndex = -1; // 선택한 행 초기화
        });

        print('파일이 문서 폴더로 이동되었고, 기존 위치에서 삭제되었습니다.');
      } catch (e) {
        print('파일 이동 및 삭제 중 오류 발생: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffE0E0E0),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Secure folder'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
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
                            (index) => DataRow(
                          color: MaterialStateColor.resolveWith((Set<MaterialState> states) {
                            // 클릭한 행의 색상 변경
                            if (index == _selectedRowIndex) {
                              return Colors.blue.withOpacity(0.3);
                            }
                            return Colors.white;
                          }),
                          onSelectChanged: (selected) {
                            // 행을 클릭하여 선택 상태 변경
                            _selectRow(index);
                          },
                          cells: [
                            DataCell(Text(files[index]['location'] ?? '')),
                            DataCell(Text(files[index]['name'] ?? '')),
                            DataCell(Text(files[index]['status'] ?? '')),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _uploadFile,
                        child: const Text('Fetch'),
                      ),
                      const SizedBox(width: 50),
                      ElevatedButton(
                        onPressed: _ejectFile,
                        child: const Text('Eject'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
