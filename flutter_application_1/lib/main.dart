import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CsvUploader(),
    );
  }
}

class CsvUploader extends StatefulWidget {
  const CsvUploader({super.key});

  @override
  State<CsvUploader> createState() => _CsvUploaderState();
}

class _CsvUploaderState extends State<CsvUploader> {
  String _csvData = '';
  bool _isLoading = false;

  Future<void> _pickAndUploadFile() async {
    setState(() {
      _isLoading = true;
      _csvData = '';
    });

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);

      if (!file.path.endsWith('.csv')) {
        setState(() {
          _csvData = 'El archivo seleccionado no es un CSV válido.';
          _isLoading = false;
        });
        return;
      }

      try {
        final uri = Uri.parse('http://127.0.0.1:5000/upload');
        final request = http.MultipartRequest('POST', uri)
          ..files.add(await http.MultipartFile.fromPath('file', file.path));

        final response = await request.send();

        if (response.statusCode == 200) {
          final responseData = await response.stream.bytesToString();
          setState(() {
            _csvData = responseData;
          });
        } else {
          setState(() {
            _csvData = 'Error al subir el archivo. Código de estado: ${response.statusCode}';
          });
        }
      } catch (e) {
        setState(() {
          _csvData = 'Error de conexión: ${e.toString()}';
        });
      }
    } else {
      setState(() {
        _csvData = 'No se seleccionó ningún archivo.';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CSV Uploader')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _pickAndUploadFile,
            child: const Text('Subir archivo CSV'),
          ),
          const SizedBox(height: 20),
          if (_isLoading)
            const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Text(_csvData, textAlign: TextAlign.left),
            ),
          ),
        ],
      ),
    );
  }
}
