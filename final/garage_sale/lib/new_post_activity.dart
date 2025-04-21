import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:path/path.dart' as path;
import 'package:firebase_storage/firebase_storage.dart';

class NewPostActivity extends StatefulWidget {
  const NewPostActivity({Key? key}) : super(key: key);

  @override
  _NewPostActivityState createState() => _NewPostActivityState();
}

class _NewPostActivityState extends State<NewPostActivity> {
  List<File?> _imageFiles = [null, null, null, null];
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isUploading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Post')),
      body: SingleChildScrollView(
        // 添加滚动视图
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text('Required Ad Information'),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Sale Item Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Sale Item Price',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a price';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Sale Item Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Column(
                  children: [
                    Text('Optional Photo Selection'),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black.withOpacity(0.5),
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [_imagePlaceholder(0)],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _imagePlaceholder(1),
                              _imagePlaceholder(2),
                              _imagePlaceholder(3),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                      onPressed:
                          _isUploading ? null : () => _submitData(context),
                      child:
                          _isUploading
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : const Text('Add'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _imagePlaceholder(int index) {
    return InkWell(
      onTap: () {
        _showImageSourceDialog(context, index);
      },
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Center(
          child:
              _imageFiles[index] == null
                  ? const Icon(Icons.add)
                  : Image.file(_imageFiles[index]!, fit: BoxFit.cover),
        ),
      ),
    );
  }

  void _showImageSourceDialog(BuildContext context, int index) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Choose image source"),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                GestureDetector(
                  child: const Text("Gallery"),
                  onTap: () async {
                    Navigator.of(context).pop();
                    final pickedFile = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                    );
                    if (pickedFile != null) {
                      setState(() {
                        _imageFiles[index] = File(pickedFile.path);
                      });
                    }
                  },
                ),
                const Padding(padding: EdgeInsets.all(8.0)),
                GestureDetector(
                  child: const Text("Camera"),
                  onTap: () async {
                    Navigator.of(context).pop();
                    final pickedFile = await ImagePicker().pickImage(
                      source: ImageSource.camera,
                    );
                    if (pickedFile != null) {
                      setState(() {
                        _imageFiles[index] = File(pickedFile.path);
                      });
                    }
                  },
                ),
                const Padding(padding: EdgeInsets.all(8.0)),
                GestureDetector(
                  child: const Text("Delete"),
                  onTap: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _imageFiles[index] = null;
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _submitData(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isUploading = true;
      });

      try {
        List<String> imageUrls = [];
        for (int i = 0; i < _imageFiles.length; i++) {
          if (_imageFiles[i] != null) {
            String url = await _uploadImageToFirebase(_imageFiles[i]!, i);
            imageUrls.add(url);
          } else {
            imageUrls.add("");
          }
        }

        await _writeProductDataToFirebase(imageUrls);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data submitted successfully')),
        );
        Navigator.pop(context); // Navigate back after successful submission
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to submit data: $e')));
      } finally {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<String> _uploadImageToFirebase(File imageFile, int index) async {
    String fileName = path.basename(imageFile.path);
    Reference firebaseStorageRef = FirebaseStorage.instance.ref().child(
      'product_images/$fileName',
    );
    UploadTask uploadTask = firebaseStorageRef.putFile(imageFile);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => {});
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> _writeProductDataToFirebase(List<String> imageUrls) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref('product').push();
    await ref.set({
      'product_name': _titleController.text,
      'product_price': _priceController.text,
      'product_desc': _descriptionController.text,
      'product_img_1': imageUrls[0],
      'product_img_2': imageUrls[1],
      'product_img_3': imageUrls[2],
      'product_img_4': imageUrls[3],
    });
  }
}
