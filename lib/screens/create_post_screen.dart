import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stray/services/api_service.dart';
import 'package:tencentcloud_cos_sdk_plugin/cos.dart';
import 'package:tencentcloud_cos_sdk_plugin/pigeon.dart';
import 'package:tencentcloud_cos_sdk_plugin/cos_transfer_manger.dart';
import 'package:crypto/crypto.dart';
import '../providers/stray_provider.dart';
import '../services/auth_service.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _descController = TextEditingController();
  final _locationController = TextEditingController();
  final _pickerController = TextEditingController();
  final ImagePicker _imgPicker = ImagePicker();
  final _apiService = ApiService();

  String? _selectedImageUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final authService = Provider.of<AuthService>(context, listen: false);
    if (authService.currentUser != null) {
      _pickerController.text = authService.currentUser!.name;
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    _locationController.dispose();
    _pickerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('登记新失物'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _createPost,
            child: _isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text(
                    '提交',
                    style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
      body: Consumer<StrayProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Selection
                const Text('拍照或从相册选择', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                // Selected Image Preview
                if (_selectedImageUrl != null) ...[
                  Container(
                    height: 300,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        _selectedImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.error, size: 50, color: Colors.grey),
                          );
                        },
                      ),
                    ),
                  ),
                ] else ...[
                  // Image Upload Button
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _selectImageFromCamera();
                          },
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('拍照'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _selectImageFromGallery();
                          },
                          icon: const Icon(Icons.photo_library),
                          label: const Text('从相册选择'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 16),

                // Desc input
                const Text('物品描述', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: _descController,
                  decoration: InputDecoration(
                    hintText: '输入丢失物品的描述',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  maxLines: 1,
                ),

                const SizedBox(height: 16),

                // Location Input
                const Text('拾取地点', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    hintText: '输入在哪里拾取的',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  maxLines: 3,
                ),

                const SizedBox(height: 16),

                // Picker Input
                const Text('拾取人', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: _pickerController,
                  decoration: InputDecoration(
                    hintText: '输入是谁拾取的',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  maxLines: 2,
                ),

                const SizedBox(height: 32),

                // Create Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _createPost,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('提交', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _selectImageFromCamera() async {
    try {
      final XFile? pickedFile = await _imgPicker.pickImage(source: ImageSource.camera, imageQuality: 80);

      if (pickedFile != null) {
        // Upload to Tencent COS
        await _uploadImageToCOS(File(pickedFile.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error capturing image: $e')));
      }
    }
  }

  Future<void> _selectImageFromGallery() async {
    try {
      final XFile? pickedFile = await _imgPicker.pickImage(source: ImageSource.gallery, imageQuality: 80);

      if (pickedFile != null) {
        // Upload to Tencent COS
        await _uploadImageToCOS(File(pickedFile.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error selecting image from gallery: $e')));
      }
    }
  }

  Future<void> _uploadImageToCOS(File imageFile) async {
    final authService = Provider.of<AuthService>(context, listen: false);

    final credRes = await _apiService.post('tencent/getCredential', {'userId': authService.currentUser!.id});
    if (credRes['code'] != 200) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('获取上传凭证失败')));
      }
      return;
    }

    // 初始化密钥
    SessionQCloudCredentials sessionQCloudCredentials = SessionQCloudCredentials(
      secretId: credRes['data']['tmpSecretId'],
      secretKey: credRes['data']['tmpSecretKey'],
      token: credRes['data']['token'],
      startTime: credRes['data']['expiredTime'] - 3600, // 提前一小时开始使用
      expiredTime: credRes['data']['expiredTime'],
    );

    // 注册 COS 服务
    String region = "ap-shanghai";
    CosXmlServiceConfig serviceConfig = CosXmlServiceConfig(region: region, isDebuggable: true, isHttps: true);
    await Cos().registerDefaultService(serviceConfig);
    TransferConfig transferConfig = TransferConfig(
      forceSimpleUpload: false,
      enableVerification: true,
      divisionForUpload: 4194304, // 设置大于等于 2M 的文件进行分块上传
      sliceSizeForUpload: 1048576, //设置默认分块大小为 1M
    );
    await Cos().registerDefaultTransferManger(serviceConfig, transferConfig);

    // 上传对象
    CosTransferManger transferManager = Cos().getDefaultTransferManger();
    String bucket = "zp-1259132592";
    String fileHash = await _generateFileMD5(imageFile);
    String fileExtension = imageFile.path.split('.').last;
    String cosPath = 'images/$fileHash.$fileExtension';

    await transferManager.upload(
      filePath: imageFile.path,
      bucket,
      cosPath,
      sessionCredentials: sessionQCloudCredentials,
      resultListener: ResultListener(
        // 上传成功回调
        (Map<String?, String?>? header, CosXmlResult? result) {
          if (result?.accessUrl != null && mounted) {
            setState(() {
              _selectedImageUrl = result?.accessUrl;
            });
          }
        },
        // 上传失败回调
        (clientException, serviceException) {
          if (clientException != null) print(clientException);
          if (serviceException != null) print(serviceException);
        },
      ),
    );
  }

  Future<String> _generateFileMD5(File file) async {
    try {
      // Read file as bytes
      List<int> bytes = await file.readAsBytes();

      // Generate MD5 hash
      Digest digest = md5.convert(bytes);

      // Return hash as hex string
      return digest.toString();
    } catch (e) {
      // Fallback to timestamp-based name if MD5 fails
      return DateTime.now().millisecondsSinceEpoch.toString();
    }
  }

  Future<void> _createPost() async {
    if (_selectedImageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请拍照或从相册选取一张照片')));
      return;
    }

    if (_descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请输入物品描述')));
      return;
    }

    if (_locationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请输入拾取地点')));
      return;
    }

    if (_pickerController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请输入拾取人')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<StrayProvider>(context, listen: false);

      await provider.createPost(
        img: _selectedImageUrl!,
        desc: _descController.text.trim(),
        location: _locationController.text.trim(),
        picker: _pickerController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('失物提交成功!'), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('失物提交失败: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
