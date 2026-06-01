import 'package:hire_nest_jobs/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';

class JobsSaved extends StatefulWidget {
  const JobsSaved({super.key});

  @override
  State<JobsSaved> createState() => _JobsSavedState();
}

class _JobsSavedState extends State<JobsSaved> {

  final CollectionReference savedVacancies = FirebaseFirestore.instance
      .collection("Saved Vacancies");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softGrey,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(LineIcons.arrowLeft, color: AppColors.darkSlateBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Saved Job Openings",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: AppColors.softPurple,
          ),
        ),
        backgroundColor: AppColors.softGrey,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: StreamBuilder(
            stream: savedVacancies.where('savedBy',isEqualTo: FirebaseAuth.instance.currentUser!.uid).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Something went wrong: ${snapshot.error}'),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('No job vacancies saved.'));
              }
              return Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                  ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final snap = snapshot.data!.docs[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Card(
                          elevation: 3,
                          shadowColor: AppColors.darkSlateBlue.withAlpha(75),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: InkWell(
                              onTap: () {
                                Navigator.pushNamed(context, 'job_saved_view',arguments: {
                                  'jobTitle' : snap['jobTitle'],
                                  'jobDescription' : snap['jobDescription'],
                                  'jobRequirement' :snap['jobRequirement'],
                                  'workplaceType' : snap['workplaceType'],
                                  'jobLocation' : snap['jobLocation'],
                                  'jobType' : snap['jobType'],
                                  'addedBy' : snap['addedBy'],
                                  'companyName' : snap['companyName'],
                                  'jobId' : snap['jobId'],
                                  'id' : snap.id
                                });
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
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
                                          fontSize: 14
                                      ),
                                    ),
                                  ),
                                  Divider(
                                    color: AppColors.mutedLavender.withAlpha(60),
                                    thickness: 0.8,
                                    indent: 10,
                                    endIndent: 10,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          LineIcons.building,
                                          color: AppColors.darkSlateBlue,
                                          size: 20,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          snap['workplaceType'],
                                          style: GoogleFonts.poppins(
                                            color: AppColors.darkSlateBlue,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Spacer(),
                                        Icon(
                                          LineIcons.briefcase,
                                          color: AppColors.darkSlateBlue,
                                          size: 20,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          snap['jobType'],
                                          style: GoogleFonts.poppins(
                                            color: AppColors.darkSlateBlue,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height * 0.01,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            }
          ),
        ),
      ),
    );
  }
}
