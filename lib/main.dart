import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'api_service.dart'; // API 요청을 위한 서비스 파일 가져오기

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: UploadHomePage(),
    );
  }
}

class UploadHomePage extends StatefulWidget {
  const UploadHomePage({super.key});

  @override
  State<UploadHomePage> createState() => _UploadHomePageState();
}

class _UploadHomePageState extends State<UploadHomePage> {
  final ImagePicker _picker = ImagePicker();
  final List<Map<String, dynamic>> _ootdImages = [];
  final List<Map<String, dynamic>> _orderImages = [];
  final ApiService _apiService = ApiService();

  final List<Map<String, String>> _brands = [
    {'name': 'MUSINSA', 'image': 'assets/musinsa.png'},
    {'name': 'ZIGZAG', 'image': 'assets/zigzag.png'},
    {'name': '29CM', 'image': 'assets/29cm.png'},
    {'name': 'ABLY', 'image': 'assets/ably.png'},
  ];
  final Map<String, bool> _brandSelection = {
    'MUSINSA': false,
    'ZIGZAG': false,
    '29CM': false,
    'ABLY': false,
  };

  bool _isSaving = false;
  String _saveMessage = '';

  Future<void> _saveData(String userId, String imageUrl, Map<String, dynamic> attributes) async {
    if (attributes['categoryName'] == null ||
        attributes['subcategoryName'] == null ||
        attributes['customName'] == null ||
        attributes['attributes'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('저장 실패: 필수 데이터가 누락되었습니다.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
      _saveMessage = '저장 중...';
    });

    final requestData = {
      "userId": userId,
      "fullS3url": imageUrl,
      "vector": [0.1, 0.2, 0.3],
      "closet": [
        {
          "categoryName": attributes['categoryName'],
          "subcategories": [
            {
              "name": attributes['subcategoryName'],
              "items": [
                {
                  "customName": attributes['customName'],
                  "attributes": attributes['attributes'],
                  "s3Url": attributes['s3Url'],
                  "quantity": attributes['quantity'] ?? 1,
                  "status": attributes['status'] ?? 0
                }
              ]
            }
          ]
        }
      ]
    };

    debugPrint('전송 데이터: ${requestData.toString()}');

    var result = await _apiService.postData('simpledb/add', requestData);

    if (result['success']) {
      debugPrint('응답 메시지: ${result['data']}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장됨: ${result['data']}')),
      );
      setState(() {
        _saveMessage = '저장됨: ${result['data']}';
      });
    } else {
      debugPrint('응답 메시지: ${result['error']}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장 실패: ${result['error']}')),
      );
      setState(() {
        _saveMessage = '저장 실패: ${result['error']}';
      });
    }

    setState(() {
      _isSaving = false;
    });
  }

  Widget _buildColorDropdown(Map<String, dynamic> data) {
    final List<Map<String, dynamic>> colorOptions = [
      {'name': '민트', 'color': Color(0xFFcfffe5)},
      {'name': '화이트', 'color': Colors.white},
      {'name': '베이지', 'color': Color(0xFFF5F5DC)},
      {'name': '카키', 'color': Colors.green[700]},
      {'name': '그레이', 'color': Colors.grey},
      {'name': '실버', 'color': Colors.grey[300]},
      {'name': '스카이블루', 'color': Colors.lightBlue[200]},
      {'name': '브라운', 'color': Colors.brown},
      {'name': '핑크', 'color': Colors.pink},
      {'name': '블랙', 'color': Colors.black},
      {'name': '그린', 'color': Colors.green},
      {'name': '오렌지', 'color': Colors.orange},
      {'name': '블루', 'color': Colors.blue},
      {'name': '네이비', 'color': Colors.blue[900]},
      {'name': '레드', 'color': Colors.red},
      {'name': '와인', 'color': Color(0xFF800020)},
      {'name': '옐로우', 'color': Colors.yellow},
      {'name': '퍼플', 'color': Colors.purple},
      {'name': '라벤더', 'color': Color(0xFFE6E6FA)},
      {'name': '골드', 'color': Color(0xFFFFD700)},
      {'name': '네온', 'color': Color(0xFF39FF14)}
    ];

    data['selectedColor'] ??= colorOptions.first['name'];

    return DropdownButton<String>(
      value: data['selectedColor'],
      items: colorOptions.map((colorOption) {
        return DropdownMenuItem<String>(
          value: colorOption['name'],
          child: Row(
            children: [
              Container(
                width: 15,
                height: 15,
                margin: const EdgeInsets.only(right: 8.0),
                decoration: BoxDecoration(
                  color: colorOption['color'],
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 0.5),
                ),
              ),
              Text(colorOption['name']),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          data['selectedColor'] = value!;
        });
      },
    );
  }

  Widget _buildBrandIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: _brands.map((brand) {
        return Column(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _brandSelection[brand['name']!] = !_brandSelection[brand['name']]!;
                  final message = _brandSelection[brand['name']]!
                      ? '${brand['name']} 을(를) 선택했습니다.'
                      : '${brand['name']} 을(를) 해제했습니다.';
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(message)),
                  );
                });
              },
              child: CircleAvatar(
                backgroundImage: AssetImage(brand['image']!),
                backgroundColor: _brandSelection[brand['name']]! ? Colors.blue : Colors.grey[300],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              brand['name']!,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildEditableBox(Map<String, dynamic> data, String userId, int index) {
    final List<String> categoryOptions = ['상의', '하의', '아우터', '원피스'];
    final List<String> subcategoryOptions = ['티셔츠', '니트웨어', '셔츠', '후드티', '청바지', '팬츠', '스커트', '조거팬츠', '코트', '재킷', '점퍼', '패딩', '가디건', '짚업', '드레스'];
    final List<String> lengthOptions = ['숏', '롱', '미디'];

    data['selectedCategory'] ??= categoryOptions.first;
    data['selectedSubcategory'] ??= subcategoryOptions.first;
    data['selectedLength'] ??= lengthOptions.first;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '아래와 같은 옷이 맞나요? (#${index + 1})',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: DropdownButton<String>(
                  value: data['selectedCategory'],
                  items: categoryOptions.map((category) {
                    return DropdownMenuItem(value: category, child: Text(category));
                  }).toList(),
                  onChanged: (value) {
                    data['selectedCategory'] = value!;
                    setState(() {});
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButton<String>(
                  value: data['selectedSubcategory'],
                  items: subcategoryOptions.map((subcategory) {
                    return DropdownMenuItem(value: subcategory, child: Text(subcategory));
                  }).toList(),
                  onChanged: (value) {
                    data['selectedSubcategory'] = value!;
                    setState(() {});
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildColorDropdown(data),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButton<String>(
                  value: data['selectedLength'],
                  items: lengthOptions.map((length) {
                    return DropdownMenuItem(value: length, child: Text(length));
                  }).toList(),
                  onChanged: (value) {
                    data['selectedLength'] = value!;
                    setState(() {});
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              onPressed: () {
                final updatedData = <String, dynamic>{
                  'categoryName': data['selectedCategory'],
                  'subcategoryName': data['selectedSubcategory'],
                  'customName': '사용자 정의 이름',
                  'attributes': {
                    'color': data['selectedColor'],
                    'length': data['selectedLength'],
                  },
                  's3Url': 'https://example.com/uploaded_image.jpg',
                  'quantity': 1,
                  'status': 0,
                };

                _saveData(
                  userId,
                  'https://example.com/full_image_url.jpg',
                  updatedData,
                );
              },
              child: const Text('저장'),
            ),
          ),
          if (_isSaving) Center(child: Text(_saveMessage)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EvenT', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text(
                '당신의 OOTD를 업로드해주세요',
                style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0, // 가로 여백
                runSpacing: 8.0, // 세로 여백
                children: [
                  ..._ootdImages.map((image) => Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.file(
                        File(image['localPath']),
                        fit: BoxFit.cover,
                      ),
                    ),
                  )),
                  GestureDetector(
                    onTap: () async {
                      final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
                      if (pickedImage != null) {
                        setState(() {
                          _ootdImages.add({'localPath': pickedImage.path});
                        });
                      }
                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.add,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ..._ootdImages.asMap().entries.map((entry) {
                final index = entry.key;
                final image = entry.value;
                return _buildEditableBox(image, 'testUser123', index);
              }),
              const SizedBox(height: 16),
              const Text(
                '주문내역을 캡처해 업로드해주세요',
                style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildBrandIcons(),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8.0, // 가로 여백
                runSpacing: 8.0, // 세로 여백
                children: [
                  ..._orderImages.map((image) => Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.file(
                        File(image['localPath']),
                        fit: BoxFit.cover,
                      ),
                    ),
                  )),
                  GestureDetector(
                    onTap: () async {
                      final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
                      if (pickedImage != null) {
                        setState(() {
                          _orderImages.add({'localPath': pickedImage.path});
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('주문 내역 업로드 완료')),
                        );
                      }
                    },
                    child: Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.add,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
                    ),
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
