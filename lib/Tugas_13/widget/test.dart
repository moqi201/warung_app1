import 'package:flutter/material.dart';
import 'package:warung_app1/Tugas_13/database/db_helper.dart';
import 'package:warung_app1/Tugas_13/model/user_model.dart';

class DeleteUser extends StatefulWidget {
  const DeleteUser({super.key});

  @override
  State<DeleteUser> createState() => _DeleteUserState();
}

class _DeleteUserState extends State<DeleteUser> {
  List<User> userList = [];
  final db = DbHelper(); // pastikan ini sesuai

  @override
  void initState() {
    super.initState();
    getUsers();
  }

  Future<void> getUsers() async {
    final data = await db.getUsers(); // asumsi method ini sudah ada
    setState(() {
      userList = data;
    });
  }

  Future<void> deleteUser(int id) async {
    await db.deleteUser(id); // method delete di DbHelper
    getUsers(); // refresh list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Hapus User")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Total User: ${userList.length}',
              style: TextStyle(fontSize: 20),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: userList.length,
              itemBuilder: (_, index) {
                final user = userList[index];
                return ListTile(
                  title: Text(user.username),
                  subtitle: Text(user.password ?? '-'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => deleteUser(user.id!),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
