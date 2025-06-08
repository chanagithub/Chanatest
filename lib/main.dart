import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // สำหรับการจัดการ JSON

// ****สำคัญ:** แทนที่ด้วย Web App URL ที่คุณได้จาก Google Apps Script
const String googlescripturl = 'https://script.google.com/macros/s/AKfycbykPpXXESPyApgppqMeYnYaaQn1eoZKa4bWo48M2A70C7wqaMXKq9WBtenNaYGCeaaT/exec';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Sheet Sender',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // เพิ่ม TextEditingController สำหรับช่อง ID
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();  // เพิ่มบรรทัดนี้

  Future<void> _sendDataToSheet() async {
    // const String idToSend = '1'; // บรรทัดนี้จะถูกลบออกหรือคอมเมนต์
    final String idToSend = _idController.text; // ดึงค่าจาก TextField แทน
    //const String idToSend = '1'; // ข้อมูล ID ที่ต้องการส่ง
    final String nameToSend = _nameController.text; // ข้อมูล Name ที่ต้องการส่ง

    try {
      // สร้าง URL สำหรับ POST request
      // เราใช้ query parameters เพื่อส่ง action, id, และ name ไปยัง Apps Script
      final uri = Uri.parse(
          '$googlescripturl?action=add&id=$idToSend&name=$nameToSend');

      final response = await http.post(uri);

      if (response.statusCode == 200) {
        // ถอดรหัส JSON response จาก Apps Script
        final result = json.decode(response.body);
        if (result['status'] == 'SUCCESS') {
          _showSnackBar('Data sent successfully: ID=$idToSend, Name=$nameToSend');
        } else {
          _showSnackBar('Failed to send data: ${result['message']}');
        }
      } else {
        _showSnackBar('Error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      _showSnackBar('An error occurred: $e');
    }
  }

  void _showSnackBar(String message) {
    // แสดงข้อความบนหน้าจอชั่วคราว
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Sheet Data Sender'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Press the button below to send data to Google Sheet:',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            // *** เพิ่ม TextFormField ตรงนี้ ***
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0), // เพื่อให้มีระยะห่างจากขอบ
              child: TextFormField(
                controller: _idController, // เชื่อมต่อกับ Controller ที่สร้างไว้
                decoration: const InputDecoration(
                  labelText: 'Enter ID', // ข้อความกำกับช่อง
                  hintText: 'e.g., 12345', // ข้อความแนะนำ
                  border: OutlineInputBorder(), // รูปแบบขอบ
               ),
                keyboardType: TextInputType.number, // กำหนดให้แป้นพิมพ์เป็นตัวเลข (ถ้า ID เป็นตัวเลข)
              ),
             ),
             const SizedBox(height: 20), // เพิ่มช่องว่างระหว่าง TextField กับปุ่ม
             Padding(
             padding: const EdgeInsets.symmetric(horizontal: 32.0),
             child: TextFormField(
               controller: _nameController,
               decoration: const InputDecoration(
                 labelText: 'กรุณาใส่ชื่อ',
                 hintText: 'ex.  John Smith',
                  border: OutlineInputBorder()
                ),
              ),
            ),
            const SizedBox(height: 20),


            ElevatedButton(
              onPressed: _sendDataToSheet, // เรียกใช้ฟังก์ชันเมื่อปุ่มถูกกด
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Send Data'),
            ),
          ],
        ),
      ),
    );
  }
}