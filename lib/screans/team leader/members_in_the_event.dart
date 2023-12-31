import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ez_orgnize/Models/event_model.dart';
import 'package:ez_orgnize/Models/usermodeal.dart';
import 'package:ez_orgnize/screans/team%20leader/Attendance.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MembersInTheEvent extends StatefulWidget {
  const MembersInTheEvent({Key? key, required this.event}) : super(key: key);
  final Event event;

  @override
  _MembersInTheEventState createState() => _MembersInTheEventState();
}

class _MembersInTheEventState extends State<MembersInTheEvent> {
  var id = FirebaseAuth.instance.currentUser!.uid;
  late List<UserModel> acceptedMembers = [];

  Future<List<UserModel>> fetchAcceptedMembers() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('events')
        .doc(widget.event.eventName)
        .get();

    if (snapshot.exists) {
      final data = snapshot.data();
      if (data != null) {
        final List<dynamic>? membersList = data['Accepted Members'];
        if (membersList != null) {
          acceptedMembers.clear();
          for (final memberId in membersList) {
            final memberSnapshot = await FirebaseFirestore.instance
                .collection('Users')
                .doc(memberId)
                .get();

            if (memberSnapshot.exists) {
              final memberData = memberSnapshot.data();
              if (memberData != null) {
                final UserModel member = UserModel.fromSnapshot(memberData);
                acceptedMembers.add(member);
              }
            }
          }
        }
      }
    }

    return acceptedMembers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Members'),
            Text('${widget.event.eventName} event'),
          ],
        ),
      ),
      body: FutureBuilder<List<UserModel>>(
        future: fetchAcceptedMembers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No members found'),
            );
          } else {
            return ListView.builder(
              itemCount: acceptedMembers.length,
              itemBuilder: (context, index) {
                final member = acceptedMembers[index];
                return ListTile(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => Attendance(
                        id: member.id.toString(),
                        event: widget.event,
                      ),
                    ),
                  ),
                  leading: const Icon(Icons.person),
                  title: Text('${member.firstName} ${member.lastName}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(member.gender ?? ''),
                      Text(member.phoneNumber ?? ''),
                      const Divider(),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
