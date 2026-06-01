import 'dart:math';

import 'package:hire_nest_jobs/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentIndex = 0;
  String candidateName = '';
  int refreshKey = 0;

  final CollectionReference jobVacancy = FirebaseFirestore.instance.collection(
    "Job Vacancy",
  );
  final CollectionReference recruitersDetails = FirebaseFirestore.instance
      .collection("Recruiters");

  Future fetchCandidateName() async {
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection("Candidates")
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .get();
      if (doc.exists) {
        setState(() {
          candidateName = doc['fullName'] ?? '';
        });
      } else {
        setState(() {
          candidateName = '';
        });
      }
    } catch (e) {
      setState(() {
        candidateName = '';
      });
    }
  }

  refreshRecruiters() {
    setState(() {
      refreshKey++;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchCandidateName();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softGrey,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.04),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        candidateName.isNotEmpty
                            ? "Welcome, $candidateName"
                            : "Welcome",
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          color: AppColors.darkSlateBlue,
                          fontWeight: FontWeight.w700,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.01,
                      ),
                      Text(
                        "Let's build your dream career together.",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.darkSlateBlue.withAlpha(204),
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, 'search');
                    },
                    icon: Icon(Icons.search, color: AppColors.darkSlateBlue),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              Divider(
                color: AppColors.mutedLavender.withAlpha(100),
                thickness: 1.2,
                indent: 20,
                endIndent: 20,
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Suggested Recruiters",
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkSlateBlue,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      refreshRecruiters();
                    },
                    icon: Icon(Icons.refresh),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              StreamBuilder(
                key: ValueKey(refreshKey),
                stream: recruitersDetails.snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) {
                    return Text("No recruiters found.");
                  }
                  final random = Random();
                  final recruiters = docs.toList()..shuffle(random);
                  final selected = recruiters.take(4).toList();
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = 2;
                      final spacing = 12.0;
                      final itemWidth =
                          (constraints.maxWidth -
                              ((crossAxisCount - 1) * spacing)) /
                          crossAxisCount;
                      final itemHeight = 160;
                      // approximate height
                      final aspectRatio = itemWidth / itemHeight;
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: selected.length,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: spacing,
                          mainAxisSpacing: spacing,
                          childAspectRatio: aspectRatio,
                        ),
                        itemBuilder: (context, index) {
                          final snap = selected[index].data() as Map;
                          final recruitersId = selected[index].id;
                          return GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                'recruiters_profile',
                                arguments: {'profileId': recruitersId},
                              );
                            },
                            child: Card(
                              color: AppColors.softPurple.withAlpha(180),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 12,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withAlpha(30),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        LineIcons.buildingAlt,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(height: 6),

                                    // Company Name
                                    Text(
                                      snap['companyName'] ?? '',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),

                                    // Headline
                                    Text(
                                      snap['headline'] ?? '',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white.withAlpha(210),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),

                                    // Divider
                                    const SizedBox(height: 4),
                                    Container(
                                      height: 1,
                                      width: 30,
                                      color: Colors.white.withAlpha(51),
                                    ),
                                    const SizedBox(height: 4),

                                    // Industry
                                    Text(
                                      snap['industry'] ?? '',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white.withAlpha(180),
                                        fontSize: 10,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),

                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              Text(
                
                "Recent Vacancies",
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkSlateBlue,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              StreamBuilder(
                stream:
                    jobVacancy
                        .orderBy('timestamp', descending: true)
                        .limit(3)
                        .snapshots(),
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
