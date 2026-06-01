import 'package:hire_nest_jobs/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class RecruitersProfile extends StatefulWidget {
  const RecruitersProfile({super.key});

  @override
  State<RecruitersProfile> createState() => _RecruitersProfileState();
}

class _RecruitersProfileState extends State<RecruitersProfile>
    with SingleTickerProviderStateMixin {
  final CollectionReference recruitersDetails = FirebaseFirestore.instance
      .collection("Recruiters");

  late String profileId;
  late TabController _tabController;

  String verified = '';
  Future fetchVerification() async {
    final doc = await FirebaseFirestore.instance
        .collection("Verification")
        .doc(profileId)
        .get();

    if (doc.exists) {
      setState(() {
        verified = doc["verified"] ?? '';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchVerification();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    profileId = args['profileId'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softGrey,
      appBar: AppBar(
        backgroundColor: AppColors.softGrey,
        leading: IconButton(
          icon: Icon(LineIcons.arrowLeft, color: AppColors.darkSlateBlue),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder(
        stream:
            recruitersDetails.where('userId', isEqualTo: profileId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No profile data available."));
          }

          final snap = snapshot.data!.docs.first;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Company Info
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Row(
                        spacing: Checkbox.width,
                        children: [
                          Text(
                            snap['companyName'],
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: AppColors.darkSlateBlue,
                            ),
                          ),
                          verified == 'Verified'
                              ? Icon(
                                  CupertinoIcons.checkmark_shield_fill,
                                  color: AppColors.softPurple,
                                )
                              : Text(''),
                        ],
                      ),
                      subtitle: Text(
                        snap['headline'],
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Text(
                        snap['location'],
                        style: GoogleFonts.poppins(color: Colors.black54),
                      ),
                    ),
                  ],
                ),
              ),
              TabBar(
                controller: _tabController,
                labelColor: AppColors.darkSlateBlue,
                indicatorColor: AppColors.darkSlateBlue,
                tabs: const [Tab(text: 'Overview'), Tab(text: 'Vacancies')],
              ),

              // TabBar View
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Overview Tab
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          sectionTitle("Overview"),
                          sectionContent(snap['about']),
                          sectionTitle("Industry"),
                          sectionContent(snap['industry']),
                          sectionTitle("Contact Details"),
                          contactRow(LineIcons.link, snap['website'], 'https'),
                          contactRow(
                            LineIcons.envelope,
                            snap['email'],
                            'mailto',
                          ),
                          contactRow(
                            LineIcons.phone,
                            snap['contactNumber'],
                            'tel',
                          ),
                        ],
                      ),
                    ),

                    // Vacancies Tab
                    StreamBuilder(
                      stream:
                          FirebaseFirestore.instance
                              .collection('Job Vacancy')
                              .where('addedBy', isEqualTo: profileId)
                              .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Text("Error: ${snapshot.error}"),
                          );
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(child: Text("No vacancies found."));
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListView.builder(
                            itemCount: snapshot.data!.docs.length,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              final snap = snapshot.data!.docs[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                ),
                                child: Card(
                                  elevation: 3,
                                  shadowColor: AppColors.darkSlateBlue
                                      .withAlpha(75),
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
                                            'jobDescription':
                                                snap['jobDescription'],
                                            'jobRequirement':
                                                snap['jobRequirement'],
                                            'workplaceType':
                                                snap['workplaceType'],
                                            'jobLocation': snap['jobLocation'],
                                            'jobType': snap['jobType'],
                                            'addedBy': snap['addedBy'],
                                            'companyName': snap['companyName'],
                                            'id': snap.id,
                                          },
                                        );
                                      },
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ListTile(
                                            contentPadding:
                                                const EdgeInsets.symmetric(
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
                                            color: AppColors.mutedLavender
                                                .withAlpha(60),
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
                                                  color:
                                                      AppColors.darkSlateBlue,
                                                  size: 20,
                                                ),
                                                SizedBox(width: 8),
                                                Text(
                                                  snap['workplaceType'],
                                                  style: GoogleFonts.poppins(
                                                    color:
                                                        AppColors.darkSlateBlue,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                Spacer(),
                                                Icon(
                                                  LineIcons.briefcase,
                                                  color:
                                                      AppColors.darkSlateBlue,
                                                  size: 20,
                                                ),
                                                SizedBox(width: 8),
                                                Text(
                                                  snap['jobType'],
                                                  style: GoogleFonts.poppins(
                                                    color:
                                                        AppColors.darkSlateBlue,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height:
                                                MediaQuery.of(
                                                  context,
                                                ).size.height *
                                                0.01,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget sectionTitle(String title) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Text(
      title,
      style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.bold),
    ),
  );

  Widget sectionContent(String content) =>
      Text(content, style: GoogleFonts.poppins(fontWeight: FontWeight.w500));

  Widget contactRow(IconData icon, String value, String scheme) => Row(
    children: [
      Icon(icon),
      TextButton(
        onPressed: () async {
          final url = Uri(scheme: scheme, path: value);
          if (await canLaunchUrl(url)) {
            launchUrl(url);
          }
        },
        child: Text(value, style: GoogleFonts.poppins()),
      ),
    ],
  );
}
