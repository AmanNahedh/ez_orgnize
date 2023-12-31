import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ez_orgnize/Models/usermodeal.dart';
import 'package:ez_orgnize/screans/admin/member_profile.dart';
import 'package:flutter/material.dart';
/*
display a list of members, allow searching,
 and provide options to change the validity of each member
 */
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
    final members = snapshot.docs
        .map((doc) {
          final data = doc.data();
          if (data != null) {
            data['id'] = doc.id;
            return UserModel.fromSnapshot(data);
          } else {
            return null;
          }
        })
        .whereType<UserModel>()
        .toList();
    setState(() {
      allMembers = members;
      displayedMembers = members;
    });
  }
// method is responsible for updating the validity
// status of a member in the Firestore database
  Future<void> changeValidity(String memberId, String validity) async {
    final memberDoc =
        FirebaseFirestore.instance.collection('Users').doc(memberId);
    await memberDoc.update({'Validity': validity});
    fetchMembers(); // Refresh the member list after updating validity
  }
//method is used to filter the list of members
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
        title: const Text('Members'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: searchMembers,
              decoration: const InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: displayedMembers.isEmpty
                ? const Center(
                    child: Text('No members found'),
                  )
                : ListView.builder(
                    itemCount: displayedMembers.length,
                    itemBuilder: (context, index) {
                      final member = displayedMembers[index];
                      return Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        margin: const EdgeInsets.all(8.0),
                        child: ListTile(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  MemberProfile(id: member.id),
                            ),
                          ),
                          title: Text('${member.firstName} ${member.lastName}'),
                          subtitle: Text(member.phoneNumber ?? ''),
                          // ...

                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: TextButton(
                                  onPressed: () => changeValidity(
                                      member.id.toString(), 'admin'),
                                  child: const Text('admin'),
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              // Add some spacing between the buttons
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: TextButton(
                                  onPressed: () => changeValidity(
                                      member.id.toString(), 'TeamLeader'),
                                  child: const Text('Team leader'),
                                ),
                              ),
                            ],
                          ),

// ...
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
