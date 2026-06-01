import 'package:hire_nest_jobs/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';

class Job extends StatefulWidget {
  const Job({super.key});

  @override
  State<Job> createState() => _JobState();
}

class _JobState extends State<Job> {
  final CollectionReference jobVacancy = FirebaseFirestore.instance.collection(
    "Job Vacancy",
  );

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
                "Job Openings",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: AppColors.darkSlateBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                ),
              ),
              Divider(
                color: AppColors.mutedLavender.withAlpha(80),
                thickness: 1,
                indent: 20,
                endIndent: 20,
              ),
              StreamBuilder(
                stream: jobVacancy.snapshots(),
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
                    return Center(
                      child: Text('Something went wrong: ${snapshot.error}'),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No job vacancies found.'));
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
                          elevation: 3,
                          shadowColor: AppColors.darkSlateBlue.withAlpha(75),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: InkWell(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  'job_view',
                                  arguments: {
                                    'jobTitle': snap['jobTitle'],
                                    'jobDescription': snap['jobDescription'],
                                    'jobRequirement': snap['jobRequirement'],
                                    'workplaceType': snap['workplaceType'],
                                    'jobLocation': snap['jobLocation'],
                                    'jobType': snap['jobType'],
                                    'addedBy': snap['addedBy'],
                                    'companyName': snap['companyName'],
                                    'id': snap.id,
                                  },
                                );
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
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
                                        color: AppColors.darkSlateBlue
                                            .withAlpha(179),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  Divider(
                                    color: AppColors.mutedLavender.withAlpha(
                                      60,
                                    ),
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
                                    height:
                                        MediaQuery.of(context).size.height *
                                        0.01,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            ],
          ),
        ),
      ),
    );
  }
}
