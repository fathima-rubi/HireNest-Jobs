import 'package:hire_nest_jobs/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class EducationAdd extends StatefulWidget {
  const EducationAdd({super.key});

  @override
  State<EducationAdd> createState() => _EducationAddState();
}

class _EducationAddState extends State<EducationAdd> {
  bool isSubmitting = false;

  DateTime? selectedStartDate;
  DateTime? selectedEndDate;

  String selectedAcademicCredential = '';

  void updateAcademicCredential(String value) {
    setState(() {
      selectedAcademicCredential = value;
      academicCredential.text = value;
    });
  }

  TextEditingController institution = TextEditingController();
  TextEditingController academicCredential = TextEditingController();
  TextEditingController startDate = TextEditingController();
  TextEditingController endDate = TextEditingController();
  TextEditingController grade = TextEditingController();
  TextEditingController description = TextEditingController();
  TextEditingController skills = TextEditingController();
  TextEditingController fieldOfStudy = TextEditingController();

  final CollectionReference education = FirebaseFirestore.instance.collection(
    "Education",
  );

  Future addEducation() async {
    if (isSubmitting) return;
    setState(() => isSubmitting = true);

    if (institution.text.isEmpty ||
        academicCredential.text.isEmpty ||
        fieldOfStudy.text.isEmpty ||
        startDate.text.isEmpty ||
        skills.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => isSubmitting = false);
      return;
    }
    try {
      final educationDetails = {
        'institution': institution.text,
        'academicCredential': academicCredential.text,
        'fieldOfStudy': fieldOfStudy.text,
        'startDate': startDate.text,
        'endDate': endDate.text.isEmpty ? 'Present' : endDate.text,
        'grade': grade.text,
        'description': description.text,
        'skills': skills.text,
        'addedBy': FirebaseAuth.instance.currentUser!.uid,
        'timestamp': FieldValue.serverTimestamp(),
      };
      await education.add(educationDetails);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Found an error. Please try again'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (selectedAcademicCredential.isNotEmpty &&
        academicCredential.text.isEmpty) {
      academicCredential.text = selectedAcademicCredential;
    }

    return Scaffold(
      backgroundColor: AppColors.softGrey,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: AppColors.softPurple),
        ),
        title: Text(
          "Add Education Details",
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
                    "Institution *",
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
                  controller: institution,
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
                    "Academic Credential *",
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
                  controller: academicCredential,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 12,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.expand_more),
                      onPressed:
                          () => showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder:
                                (context) => SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.6,
                                  child: ListView(
                                    children: [
                                      for (String option in [
                                        'High School Diploma',
                                        'Secondary School Certificate (SSC)',
                                        'Higher Secondary Certificate (HSC)',
                                        'Associate Degree',
                                        'Bachelor’s Degree',
                                        'Master’s Degree',
                                        'Doctorate / PhD',
                                        'Diploma',
                                        'Postgraduate Diploma',
                                        'Professional Certification',
                                        'Vocational Training Certificate',
                                        'Technical Certification',
                                        'Online Course Certificate',
                                        'License or Registration Certificate',
                                      ])
                                        RadioListTile(
                                          title: Text(
                                            option,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          value: option,
                                          groupValue:
                                              selectedAcademicCredential,
                                          activeColor: AppColors.softPurple,
                                          onChanged: (value) {
                                            updateAcademicCredential(value!);
                                            Navigator.pop(context);
                                          },
                                        ),
                                    ],
                                  ),
                                ),
                          ),
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              Row(
                children: [
                  Text(
                    "Field of study *",
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
                  controller: fieldOfStudy,
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
                    "Grade",
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
                  controller: grade,
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
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
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
                    addEducation();
                  },
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: MediaQuery.of(context).size.height * 0.06,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: isSubmitting ? Colors.grey : AppColors.softPurple,
                      boxShadow:
                          isSubmitting
                              ? []
                              : [
                                BoxShadow(
                                  color: Colors.black54.withAlpha(80),
                                  blurRadius: 8,
                                  offset: Offset(2, 2),
                                ),
                              ],
                    ),
                    child:
                        isSubmitting
                            ? CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            )
                            : Text(
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
