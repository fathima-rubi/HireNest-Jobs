import 'package:career_hub/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ExperienceAdd extends StatefulWidget {
  const ExperienceAdd({super.key});

  @override
  State<ExperienceAdd> createState() => _ExperienceAddState();
}

class _ExperienceAddState extends State<ExperienceAdd> {
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;

  Map workplaceTypeOptions = {
    "Remote": false,
    "On-site": false,
    "Hybrid": false,
    "Field Work": false,
  };

  Map jobTypeOptions = {
    "Internship": false,
    "Full-time": false,
    "Part-time": false,
    "Freelance": false,
    "Apprenticeship": false,
    "Temporary": false,
  };

  void updateWorkplaceType() {
    locationType.text = workplaceTypeOptions.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .join(",");
  }

  void updateJobType() {
    jobType.text = jobTypeOptions.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .join(",");
  }

  TextEditingController jobTitle = TextEditingController();
  TextEditingController jobType = TextEditingController();
  TextEditingController companyName = TextEditingController();
  TextEditingController startDate = TextEditingController();
  TextEditingController endDate = TextEditingController();
  TextEditingController description = TextEditingController();
  TextEditingController locationType = TextEditingController();
  TextEditingController skills = TextEditingController();

  final CollectionReference experience = FirebaseFirestore.instance.collection(
    "Experience",
  );

  Future addExperience() async {
    if (jobTitle.text.isEmpty ||
        companyName.text.isEmpty ||
        startDate.text.isEmpty ||
        skills.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all required fields"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    try {
      final experienceDetails = {
        'jobTitle': jobTitle.text,
        'jobType': jobType.text,
        'companyName': companyName.text,
        'startDate': startDate.text,
        'endDate': endDate.text.isEmpty ? 'Present' : endDate.text,
        'description': description.text,
        'locationType': locationType.text,
        'skills': skills.text,
        'addedBy': FirebaseAuth.instance.currentUser!.uid,
        'timestamp' : FieldValue.serverTimestamp()
      };
      await experience.add(experienceDetails);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Found an error. Please try again"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    for (var key in workplaceTypeOptions.keys) {
      workplaceTypeOptions[key] = locationType.text.contains(key);
    }

    for (var key in jobTypeOptions.keys) {
      jobTypeOptions[key] = jobType.text.contains(key);
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
        title: Text(
          "Add Experience Details",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: AppColors.softPurple,
          ),
        ),
        backgroundColor: AppColors.softGrey,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              Text(
                "* represent important field",
                style: GoogleFonts.poppins(
                  color: Colors.red.withAlpha(200),
                  fontSize: 12,
                ),
              ),
              Divider(thickness: 1, color: AppColors.softPurple.withAlpha(100)),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              Row(
                children: [
                  Text(
                    "Job Title *",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkSlateBlue,
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Card(
                color: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: AppColors.softPurple.withAlpha(100)),
                ),
                child: TextField(
                  controller: jobTitle,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 12,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              Row(
                children: [
                  Text(
                    "Employment Type",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkSlateBlue,
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Card(
                color: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: AppColors.softPurple.withAlpha(100)),
                ),
                child: TextField(
                  controller: jobType,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 12,
                    ),
                    suffixIcon: PopupMenuButton(
                      icon: Icon(Icons.expand_more),
                      color: Colors.white,
                      itemBuilder:
                          (context) => [
                        PopupMenuItem(
                          child: SizedBox(
                            width: 115,
                            child: Column(
                              children: jobTypeOptions.entries.map((entry) {
                                return CheckboxListTile(
                                  activeColor: AppColors.softPurple,
                                  title: Text(entry.key, style: TextStyle(fontWeight: FontWeight.bold)),
                                  value: entry.value,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      jobTypeOptions[entry.key] = value!;
                                      updateJobType();
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              Row(
                children: [
                  Text(
                    "Company or organization *",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkSlateBlue,
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Card(
                color: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: AppColors.softPurple.withAlpha(100)),
                ),
                child: TextField(
                  controller: companyName,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 12,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              Row(
                children: [
                  Text(
                    "Start date *",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkSlateBlue,
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Card(
                color: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: AppColors.softPurple.withAlpha(100)),
                ),
                child: TextField(
                  controller: startDate,
                  readOnly: true,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      onPressed: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedStartDate ?? DateTime.now(),
                          firstDate: DateTime.utc(1880),
                          lastDate: DateTime.utc(2080),
                        );
                        if (picked != null) {
                          setState(() {
                            selectedStartDate = picked;
                            startDate.text = DateFormat(
                              'MMM yyyy',
                            ).format(picked);
                          });
                        }
                      },
                      icon: Icon(CupertinoIcons.calendar),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 12,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              Row(
                children: [
                  Text(
                    "End date",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkSlateBlue,
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Card(
                color: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: AppColors.softPurple.withAlpha(100)),
                ),
                child: TextField(
                  controller: endDate,
                  readOnly: true,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      onPressed: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedEndDate ?? DateTime.now(),
                          firstDate: DateTime.utc(1880),
                          lastDate: DateTime.utc(2080),
                        );
                        if (picked != null) {
                          setState(() {
                            selectedEndDate = picked;
                            endDate.text = DateFormat(
                              'MMM yyyy',
                            ).format(picked);
                          });
                        }
                      },
                      icon: Icon(CupertinoIcons.calendar),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 12,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              Row(
                children: [
                  Text(
                    "Description",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkSlateBlue,
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Card(
                color: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: AppColors.softPurple.withAlpha(100)),
                ),
                child: TextField(
                  controller: description,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 12,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              Row(
                children: [
                  Text(
                    "Location type",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkSlateBlue,
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Card(
                color: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: AppColors.softPurple.withAlpha(100)),
                ),
                child: TextField(
                  controller: locationType,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 12,
                    ),
                    suffixIcon: PopupMenuButton(
                      icon: Icon(Icons.expand_more_outlined),
                      color: Colors.white,
                      itemBuilder:
                          (context) => [
                        PopupMenuItem(
                          child: SizedBox(
                            width: 100,
                            child: Column(
                              children: workplaceTypeOptions.entries.map((entry) {
                                return CheckboxListTile(
                                  activeColor: AppColors.softPurple,
                                  title: Text(entry.key, style: TextStyle(fontWeight: FontWeight.bold)),
                                  value: entry.value,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      workplaceTypeOptions[entry.key] = value!;
                                      updateWorkplaceType();
                                    });
                                  },
                                );
                              },).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              Row(
                children: [
                  Text(
                    "Skills *",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkSlateBlue,
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Card(
                color: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: AppColors.softPurple.withAlpha(100)),
                ),
                child: TextField(
                  controller: skills,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 12,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              Center(
                child: InkWell(
                  onTap: () {
                    addExperience();
                  },
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: MediaQuery.of(context).size.height * 0.06,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: AppColors.softPurple,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black54.withAlpha(80),
                          blurRadius: 8,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      "ADD",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            ],
          ),
        ),
      ),
    );
  }
}
