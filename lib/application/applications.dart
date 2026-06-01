import 'package:hire_nest_jobs/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Applications extends StatefulWidget {
  const Applications({super.key});

  @override
  State<Applications> createState() => _ApplicationsState();
}

class _ApplicationsState extends State<Applications> {
  final CollectionReference jobApplication = FirebaseFirestore.instance
      .collection('Job Application');

  Color statusColor(status) {
    if (status == 'Applied') {
      return Colors.grey;
    } else if (status == 'Under Review') {
      return Colors.amber;
    } else if (status == 'Selected') {
      return Colors.green;
    } else if (status == 'Rejected') {
      return Colors.red;
    } else {
      return AppColors.mutedLavender;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softGrey,
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.04),
              Text(
                "Job Applications",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: AppColors.darkSlateBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                ),
              ),
              Divider(
                color: AppColors.mutedLavender.withAlpha(100),
                thickness: 1.2,
                indent: 20,
                endIndent: 20,
              ),
              StreamBuilder(
                stream:
                    jobApplication
                        .where(
                          'candidateId',
                          isEqualTo: FirebaseAuth.instance.currentUser!.uid,
                        )
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ListView.builder(
                      itemCount: 5,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                            shadowColor: AppColors.darkSlateBlue.withAlpha(75),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                title: Container(
                                  height: 14,
                                  width: 120,
                                  color: Colors.grey.shade300,
                                ),
                                subtitle: Container(
                                  margin: EdgeInsets.only(top: 8),
                                  height: 12,
                                  width: 180,
                                  color: Colors.grey.shade200,
                                ),
                                trailing: Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.04,
                                  width:
                                      MediaQuery.of(context).size.height * 0.15,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }

                  if (snapshot.hasError) {
                    return SizedBox(
                      width: MediaQuery.of(context).size.width*0.5,
                      height: MediaQuery.of(context).size.height*0.5,
                      child: Row(
                        children: [
                          Text('Something went wrong. Please try again.'),
                        ],
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return SizedBox(
                      width: MediaQuery.of(context).size.width*0.5,
                      height: MediaQuery.of(context).size.height*0.5,
                      child: Text(
                        'Looks like you haven’t applied for any jobs yet.',
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final snap = snapshot.data!.docs[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                          shadowColor: AppColors.darkSlateBlue.withAlpha(75),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  'application_view',
                                  arguments: {
                                    'candidateName': snap['candidateName'],
                                    'contactNumber': snap['contactNumber'],
                                    'email': snap['email'],
                                    'status': snap['status'],
                                    'jobId': snap['jobId'],
                                    'companyName': snap['companyName'],
                                    'jobTitle': snap['jobTitle'],
                                    'jobDescription': snap['jobDescription'],
                                    'jobRequirement': snap['jobRequirement'],
                                    'jobType': snap['jobType'],
                                    'jobLocation': snap['jobLocation'],
                                    'workplaceType': snap['workplaceType'],
                                    'addedBy': snap['addedBy'],
                                    'resumeFileName' :snap['resumeFileName'],
                                    'id': snap.id,
                                  },
                                );
                              },
                              title: Text(
                                snap['jobTitle'],
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkSlateBlue,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text(
                                snap['companyName'],
                                style: GoogleFonts.poppins(
                                  color: AppColors.darkSlateBlue.withAlpha(179),
                                  fontSize: 14,
                                ),
                              ),
                              trailing: Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.04,
                                width:
                                    MediaQuery.of(context).size.height * 0.15,
                                decoration: BoxDecoration(
                                  color: statusColor(snap['status']),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    snap['status'],
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            ],
          ),
        ),
      ),
    );
  }
}
