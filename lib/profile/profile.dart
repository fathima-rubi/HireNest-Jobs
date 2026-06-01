import 'package:hire_nest_jobs/authentication/login.dart';
import 'package:hire_nest_jobs/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  TextEditingController skills = TextEditingController();

  final CollectionReference experience = FirebaseFirestore.instance.collection(
    "Experience",
  );
  final CollectionReference education = FirebaseFirestore.instance.collection(
    "Education",
  );
  final CollectionReference candidatesDetails = FirebaseFirestore.instance
      .collection("Candidates");

  Future signout() async {
    try {
      await FirebaseAuth.instance.signOut();
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      preferences.setBool('isLogged', false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Login()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("An error occurred. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      backgroundColor: AppColors.softGrey,
      appBar: AppBar(
        leading: Builder(
          builder: (context) {
            return IconButton(
              tooltip: "Settings",
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: Icon(LineIcons.cog, color: AppColors.softPurple),
            );
          },
        ),
        backgroundColor: AppColors.softGrey,
      ),
      drawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.5,
        shape: OutlineInputBorder(),
        child: Column(
          children: [
            SizedBox(height: 60),
            ListTile(
              leading: Icon(CupertinoIcons.bookmark),
              title: Text('Saved Vacancies'),
              dense: true,
              visualDensity: VisualDensity(horizontal: 0, vertical: -2),
              onTap: () {
                Navigator.pushNamed(context, 'jobs_saved');
              },
            ),
            ListTile(
              leading: Icon(LineIcons.lock),
              title: Text('Reset Password'),
              dense: true,
              visualDensity: VisualDensity(horizontal: 0, vertical: -2),
              onTap: () {
                Navigator.pushNamed(context, 'reset_password');
              },
            ),
            ListTile(
              leading: Icon(LineIcons.alternateSignOut),
              title: Text('Logout'),
              dense: true,
              visualDensity: VisualDensity(horizontal: 0, vertical: -2),
              onTap: () {
                signout();
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              SizedBox(height: 15),
              StreamBuilder(
                stream: candidatesDetails.doc(userId).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text("AN ERROR OCCURRED.PLEASE REFRESH THE PAGE"),
                    );
                  }
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return Center(child: Text("NO PROFILE DATA FOUND"));
                  }

                  final snap = snapshot.data!;
                  return ListView(
                    shrinkWrap: true,
                    children: [
                      Card(
                        color: AppColors.softGrey,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          title: Text(
                            snap['fullName'],
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: AppColors.darkSlateBlue,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                snap['headline'],
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              // SizedBox(height: 20),
                              Text(
                                snap['location'],
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          trailing: SizedBox(
                            width: 96,
                            child: Row(
                              children: [
                                IconButton(
                                  tooltip: 'Contact Details',
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          alignment: Alignment.topRight,
                                          content: SizedBox(
                                            height:
                                                MediaQuery.of(
                                                  context,
                                                ).size.height *
                                                0.3,
                                            width:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width *
                                                0.04,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                ListTile(
                                                  isThreeLine: true,
                                                  leading: Icon(
                                                    LineIcons.phone,
                                                    color: AppColors.softPurple,
                                                  ),
                                                  title: Flexible(
                                                    child: Text(
                                                      'Phone:',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      softWrap: true,
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                    ),
                                                  ),
                                                  subtitle: Flexible(
                                                    child: Text(
                                                      snap['contactNumber'],
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      softWrap: true,
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                    ),
                                                  ),
                                                  onTap: () async {
                                                    final url = Uri(
                                                      scheme: 'tel',
                                                      path:
                                                          snap['contactNumber'],
                                                    );
                                                    if (await canLaunchUrl(
                                                      url,
                                                    )) {
                                                      launchUrl(url);
                                                    }
                                                  },
                                                ),
                                                ListTile(
                                                  isThreeLine: true,
                                                  leading: Icon(
                                                    LineIcons.envelope,
                                                    color: AppColors.softPurple,
                                                  ),
                                                  title: Flexible(
                                                    child: Text(
                                                      'Email:',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      softWrap: true,
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                    ),
                                                  ),
                                                  subtitle: Flexible(
                                                    child: Text(
                                                      snap['email'],
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      softWrap: true,
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                    ),
                                                  ),
                                                  onTap: () async {
                                                    final url = Uri(
                                                      scheme: 'mailto',
                                                      path: snap['email'],
                                                    );
                                                    if (await canLaunchUrl(
                                                      url,
                                                    )) {
                                                      launchUrl(url);
                                                    } else {
                                                      // Show a user-friendly message
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        const SnackBar(
                                                          content: Text('Could not open email app. Please ensure you have one installed.'),
                                                        ),
                                                      );
                                                    }
                                                  },
                                                ),
                                                ListTile(
                                                  isThreeLine: true,
                                                  leading: Icon(
                                                    LineIcons.globe,
                                                    color: AppColors.softPurple,
                                                  ),
                                                  title: Flexible(
                                                    child: Text(
                                                      'Website:',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      softWrap: true,
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                    ),
                                                  ),
                                                  subtitle: Flexible(
                                                    child: Text(
                                                      snap['website'],
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      softWrap: true,
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                    ),
                                                  ),
                                                  onTap: () async {
                                                    final url = Uri(
                                                      scheme: 'https',
                                                      path: snap['website'],
                                                    );
                                                    if (await canLaunchUrl(
                                                      url,
                                                    )) {
                                                      launchUrl(url);
                                                    }
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.pop(context),
                                              child: Text(
                                                "Cancel",
                                                style: GoogleFonts.poppins(
                                                  color: AppColors.softPurple,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  icon: Icon(
                                    LineIcons.infoCircle,
                                    color: AppColors.darkSlateBlue,
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Edit Profile',
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      'profile_edit',
                                      arguments: {
                                        'fullName': snap['fullName'],
                                        'headline': snap['headline'],
                                        'location': snap['location'],
                                        'about': snap['about'],
                                        'skills': snap['skills'],
                                        'contactNumber': snap['contactNumber'],
                                        'website': snap['website'],
                                        'id': snap.id,
                                      },
                                    );
                                  },
                                  icon: Icon(
                                    LineIcons.edit,
                                    color: AppColors.softPurple,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          "About",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkSlateBlue,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          snap['about'],
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Experiences",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkSlateBlue,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.pushNamed(context, 'experience_add');
                          },
                          icon: Icon(
                            LineIcons.plus,
                            color: AppColors.darkSlateBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  StreamBuilder(
                    stream:
                        experience
                            .where('addedBy', isEqualTo: userId)
                            .limit(3)
                            .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            "AN ERROR OCCURRED. PLEASE REFRESH THE PAGE.",
                          ),
                        );
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(child: Text(""));
                      }
                      return Card(
                        color: AppColors.softGrey,
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      'experience_view',
                                      arguments: {'addedBy': userId},
                                    );
                                  },
                                  child: Text("View all"),
                                ),
                              ],
                            ),
                            ListView.separated(
                              itemCount: snapshot.data!.docs.length,
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                final snap = snapshot.data!.docs[index];
                                return ListTile(
                                  title: Text(
                                    snap['jobTitle'],
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        snap['companyName'],
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        "${snap['startDate']}-${snap['endDate'] ?? 'Present'}",
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              separatorBuilder: (
                                BuildContext context,
                                int index,
                              ) {
                                return Divider(
                                  color: AppColors.mutedLavender.withAlpha(60),
                                  thickness: 0.8,
                                  indent: 10,
                                  endIndent: 10,
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Educations",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkSlateBlue,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.pushNamed(context, 'education_add');
                          },
                          icon: Icon(
                            LineIcons.plus,
                            color: AppColors.darkSlateBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  StreamBuilder(
                    stream:
                        education
                            .where('addedBy', isEqualTo: userId)
                            .limit(3)
                            .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            "AN ERROR OCCURRED. PLEASE REFRESH THE PAGE.",
                          ),
                        );
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(child: Text(""));
                      }
                      return Card(
                        color: AppColors.softGrey,
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      'education_view',
                                      arguments: {'addedBy': userId},
                                    );
                                  },
                                  child: Text("View all"),
                                ),
                              ],
                            ),
                            ListView.separated(
                              itemCount: snapshot.data!.docs.length,
                              physics: ScrollPhysics(),
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                final snap = snapshot.data!.docs[index];
                                return ListTile(
                                  title: Text(
                                    "${snap['academicCredential']} in ${snap['fieldOfStudy']}",
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        snap['institution'],
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        "${snap['startDate']}-${snap['endDate']}",
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              separatorBuilder: (
                                BuildContext context,
                                int index,
                              ) {
                                return Divider(
                                  color: AppColors.mutedLavender.withAlpha(60),
                                  thickness: 0.8,
                                  indent: 10,
                                  endIndent: 10,
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Top Skills",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkSlateBlue,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  content: SizedBox(
                                    height:
                                        MediaQuery.of(context).size.height *
                                        0.15,
                                    width:
                                        MediaQuery.of(context).size.width *
                                        0.01,
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              "Skills",
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.darkSlateBlue,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height:
                                              MediaQuery.of(
                                                context,
                                              ).size.height *
                                              0.01,
                                        ),
                                        Card(
                                          color: Colors.white,
                                          elevation: 3,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            side: BorderSide(
                                              color: AppColors.softPurple
                                                  .withAlpha(100),
                                            ),
                                          ),
                                          child: TextField(
                                            controller: skills,
                                            decoration: InputDecoration(
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 15,
                                                    vertical: 12,
                                                  ),
                                              border: InputBorder.none,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text(
                                        "Cancel",
                                        style: GoogleFonts.poppins(
                                          color: AppColors.softPurple,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        if (skills.text.isNotEmpty) {
                                          final doc =
                                              await FirebaseFirestore.instance
                                                  .collection('Candidates')
                                                  .doc(userId)
                                                  .get();
                                          final existingSkills =
                                              doc.exists
                                                  ? (doc.data()?['skills'] ??
                                                      '')
                                                  : '';
                                          final updatedSkills =
                                              existingSkills.isEmpty
                                                  ? skills.text.trim()
                                                  : '$existingSkills, ${skills.text.trim()}';
                                          await FirebaseFirestore.instance
                                              .collection('Candidates')
                                              .doc(userId)
                                              .update({
                                                'skills': updatedSkills,
                                              });

                                          skills.clear();
                                          Navigator.pop(context);
                                        }
                                      },
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                            0.25,
                                        height:
                                            MediaQuery.of(context).size.height *
                                            0.06,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                          color: AppColors.softPurple,
                                        ),
                                        child: Text(
                                          "ADD",
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          icon: Icon(
                            LineIcons.plus,
                            color: AppColors.darkSlateBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 40,
                    child: StreamBuilder(
                      stream: candidatesDetails.doc(userId).snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || !snapshot.data!.exists) {
                          return SizedBox();
                        }
                        final skillsString = snapshot.data!['skills'] ?? '';
                        final skillsList =
                            skillsString.isNotEmpty
                                ? skillsString.split(',')
                                : [];

                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: skillsList.length,
                          itemBuilder: (context, index) {
                            final skill = skillsList[index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Chip(
                                label: Text(skill),
                                deleteIcon: Icon(Icons.close, size: 18),
                                onDeleted: () async {
                                  final updatedSkills = skillsList
                                      .where((s) => s != skill)
                                      .join(',');
                                  await FirebaseFirestore.instance
                                      .collection('Candidates')
                                      .doc(userId)
                                      .update({'skills': updatedSkills});
                                },
                                backgroundColor: AppColors.mutedLavender
                                    .withAlpha(50),
                                labelStyle: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
