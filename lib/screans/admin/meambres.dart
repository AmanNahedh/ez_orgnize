import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ez_orgnize/modeals/usermodeal.dart';
import 'package:ez_orgnize/screans/admin/member_profile.dart';
import 'package:flutter/material.dart';

class Meambers extends StatefulWidget {
  const Meambers({Key? key}) : super(key: key);

  @override
  _MeambersState createState() => _MeambersState();
}

class _MeambersState extends State<Meambers> {
  late List<UserModel> allMembers;
  late List<UserModel> displayedMembers = [];

  @override
  void initState() {
    super.initState();
    fetchMembers();
  }

  Future<void> fetchMembers() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Users')
        .where("Validity", isEqualTo: "organizer")
        .get();
    final members = snapshot.docs.map((doc) {
      final data = doc.data();
      if (data != null) {
        data['id'] = doc.id;
        return UserModel.fromSnapshot(data as Map<String, dynamic>);
      } else {
        return null;
      }
    }).whereType<UserModel>().toList();
    setState(() {
      allMembers = members;
      displayedMembers = members;
    });
  }

  void searchMembers(String query) {
    setState(() {
      displayedMembers = allMembers.where((member) {
        final fullName = '${member.firstName} ${member.lastName}'.toLowerCase();
        return fullName.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Members'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: searchMembers,
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: displayedMembers.isEmpty
                ? Center(
              child: Text('No members found'),
            )
                : ListView.builder(
              itemCount: displayedMembers.length,
              itemBuilder: (context, index) {
                final member = displayedMembers[index];
                return ListTile(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MemberProfile(id: member.id,),
                    ),
                  ),
                  title: Text('${member.firstName} ${member.lastName}'),
                  subtitle: Text(member.phoneNumber ?? ''),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}