import 'package:hire_nest_jobs/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController search = TextEditingController();
  List allJobs = [];
  List filteredJobs = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(LineIcons.arrowLeft, color: AppColors.darkSlateBlue),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: AppColors.softGrey,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10.0,right: 10),
              child: SizedBox(
                height: 50,
                child: Card(
                  elevation: 3,
                  shadowColor: Colors.black.withAlpha(40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: TextField(
                    controller: search,
                    autofocus: true,
                    onChanged: (value) => filterJobs(value),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                      hintText: "Search for vacancies...",
                      hintStyle: GoogleFonts.poppins(
                        color: AppColors.darkSlateBlue.withAlpha(150),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: AppColors.mutedLavender),
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppColors.darkSlateBlue,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder(
                stream:
                    FirebaseFirestore.instance
                        .collection('Job Vacancy')
                        .orderBy('timestamp', descending: true)
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
                    return Center(child: Text("No job vacancies found."));
                  }
                  allJobs = snapshot.data!.docs;
                  if (search.text.isEmpty) {
                    filteredJobs = List.from(allJobs);
                  }

                  return ListView.builder(
                    itemCount: filteredJobs.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      final snap = filteredJobs[index];
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
            ),
          ],
        ),
      ),
    );
  }

  void filterJobs(String query) {
    final lowerQuery = query.toLowerCase();
    setState(() {
      filteredJobs =
          allJobs.where((doc) {
            final title = doc['jobTitle'].toString().toLowerCase();
            return title.contains(lowerQuery);
          }).toList();
    });
  }
}
