import 'package:hire_nest_jobs/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';

class ExperienceView extends StatefulWidget {
  const ExperienceView({super.key});

  @override
  State<ExperienceView> createState() => _ExperienceViewState();
}

class _ExperienceViewState extends State<ExperienceView> {

  final CollectionReference experience = FirebaseFirestore.instance.collection(
    "Experience",
  );

  late String addedBy;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    addedBy = args['addedBy'];
  }

  Future delete(id)async{
    try{
      experience.doc(id).delete();
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Can't delete, please try again."),backgroundColor: Colors.red,));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softGrey,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: AppColors.softPurple),
        ),
        backgroundColor: AppColors.softGrey,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: StreamBuilder(
          stream: experience.where('addedBy',isEqualTo: addedBy).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text("AN ERROR OCCURRED.PLEASE REFRESH THE PAGE"),
              );
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text("NO PROFILE DATA FOUND"));
            }
            return ListView.builder(
              physics: BouncingScrollPhysics(),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final snap = snapshot.data!.docs[index];
                return Card(
                  color: AppColors.softGrey,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    title: Text(
                      "${snap['jobTitle']} at ${snap['companyName']}",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: AppColors.softPurple,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Started Date: ${snap['startDate']}',
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Ended Date (or expected): ${snap['endDate']}',
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Job Type: ${snap['jobType']}',
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Workplace Type: ${snap['locationType']}',
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                            ),
                            SizedBox(height: 15),
                            Text(
                              snap['description'],
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                            ),
                            SizedBox(height: 10),
                            Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 12,
                              runSpacing: 8,
                              children: [
                                Icon(LineIcons.gem, size: 20, color: AppColors.darkSlateBlue),
                                SizedBox(width: 5),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.7,
                                  child: Text(
                                    snap['skills'],
                                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                                    softWrap: true,
                                  ),
                                ),
                              ],
                            ),
                            Divider(color: AppColors.darkSlateBlue.withAlpha(100)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, 'experience_edit',arguments: {
                                      'jobTitle' : snap['jobTitle'],
                                      'companyName' : snap['companyName'],
                                      'startDate' : snap['startDate'],
                                      'endDate' : snap['endDate'],
                                      'jobType' : snap['jobType'],
                                      'description' : snap['description'],
                                      'locationType' : snap['locationType'],
                                      'skills' : snap['skills'],
                                      'id' : snap.id
                                    });
                                  },
                                  icon: Icon(LineIcons.edit, color: AppColors.darkSlateBlue),
                                ),
                                IconButton(
                                  onPressed: () {
                                    delete(snap.id);
                                  },
                                  icon: Icon(CupertinoIcons.delete_solid, color: Colors.red.withAlpha(180)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        ),
      ),
    );
  }
}
