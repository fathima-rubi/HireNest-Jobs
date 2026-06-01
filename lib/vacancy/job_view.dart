import 'dart:io';

import 'package:hire_nest_jobs/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';

class JobView extends StatefulWidget {
  const JobView({super.key});

  @override
  State<JobView> createState() => _JobViewState();
}

class _JobViewState extends State<JobView> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController fullName = TextEditingController();
  TextEditingController contactNumber = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController detailsController = TextEditingController();
  TextEditingController resume = TextEditingController();

  bool isSave = false;
  bool isLoading = true;
  bool isApply = false;
  bool isUploading = false;
  double uploadProgress = 0.0;

  File? selectedResumeFile;
  String resumeFileName = 'No file selected';

  late String jobTitle,
      jobLocation,
      jobDescription,
      jobRequirement,
      jobType,
      workplaceType,
      jobId,
      addedBy,
      companyName;

  String? selectedReason;
  String candidateName = '';

  final FirebaseStorage fileStorage = FirebaseStorage.instance;
  final CollectionReference report = FirebaseFirestore.instance.collection(
    "Report",
  );
  final CollectionReference jobApplication = FirebaseFirestore.instance
      .collection('Job Application');
  final CollectionReference savedVacancies = FirebaseFirestore.instance
      .collection("Saved Vacancies");

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchCandidateName();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null && route.settings.arguments != null) {
      final args = route.settings.arguments as Map;
      jobTitle = args['jobTitle'];
      jobLocation = args['jobLocation'];
      jobDescription = args['jobDescription'];
      jobRequirement = args['jobRequirement'];
      jobType = args['jobType'];
      workplaceType = args['workplaceType'];
      jobId = args['id'];
      companyName = args['companyName'];
      addedBy = args['addedBy'];
      checkIfSaved();
      checkApplicationStatus();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No job data received.')));
      Navigator.pop(context);
    }
  }

  Future fetchCandidateName() async {
    final doc = await FirebaseFirestore.instance
        .collection("Candidates")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    if (doc.exists) {
      setState(() {
        candidateName = doc["fullName"] ?? '';
      });
    }
  }

  Future<void> pickResume() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        selectedResumeFile = File(result.files.single.path!);
        resumeFileName = result.files.single.name;
        resume.text = resumeFileName;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Selected: $resumeFileName')));
    } else {
      setState(() {
        selectedResumeFile = null;
        resumeFileName = 'No file selected';
        resume.text = resumeFileName;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No resume selected')));
    }
  }

  Future checkIfSaved() async {
    final snapshot = await savedVacancies
        .where("savedBy", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .where("jobId", isEqualTo: jobId)
        .get();
    setState(() {
      isSave = snapshot.docs.isNotEmpty;
      isLoading = false;
    });
  }

  Future checkApplicationStatus() async {
    bool hasApplied = await hasUserApplied(jobId);

    setState(() {
      isApply = hasApplied;
    });
  }

  Future hasUserApplied(jobId) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final applicationSnapshot = await jobApplication
        .where('jobId', isEqualTo: jobId)
        .where('candidateId', isEqualTo: userId)
        .get();
    return applicationSnapshot.docs.isNotEmpty;
  }

  Future apply() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedResumeFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a resume file.')),
      );
      return;
    }

    if (isUploading) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Resume is still uploading. Please wait.'),
        ),
      );
      return;
    }

    setState(() {
      isUploading = true;
      uploadProgress = 0.0;
    });

    try {
      final existingApps = await jobApplication
          .where('jobId', isEqualTo: jobId)
          .where(
            'candidateId',
            isEqualTo: FirebaseAuth.instance.currentUser!.uid,
          )
          .get();

      if (existingApps.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("You have already applied for this job.")),
        );
        return;
      }

      String resumeStoragePath =
          'resumes/${DateTime.now().millisecondsSinceEpoch}_$resumeFileName';
      Reference storageRef = fileStorage.ref().child(resumeStoragePath);

      UploadTask uploadTask = storageRef.putFile(selectedResumeFile!);
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        setState(() {
          uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
        });
      });

      TaskSnapshot snapshot = await uploadTask;
      String resumeDownloadUrl = await snapshot.ref.getDownloadURL();

      final applicationDetails = {
        'candidateName': fullName.text,
        'contactNumber': contactNumber.text,
        'email': email.text,
        'status': 'Applied',
        'jobId': jobId,
        'companyName': companyName,
        'jobTitle': jobTitle,
        'jobDescription': jobDescription,
        'jobRequirement': jobRequirement,
        'jobType': jobType,
        'jobLocation': jobLocation,
        'workplaceType': workplaceType,
        'addedBy': addedBy,
        'resumeFileName': resumeFileName,
        'resumeDownloadUrl': resumeDownloadUrl,
        'candidateId': FirebaseAuth.instance.currentUser!.uid,
        'timestamp': FieldValue.serverTimestamp(),
      };
      await jobApplication.add(applicationDetails);
      setState(() {
        isApply = true;
        fullName.clear();
        email.clear();
        contactNumber.clear();
        selectedResumeFile = null;
        resumeFileName = 'No file selected';
        resume.text = resumeFileName;
      });
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (context) {
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.of(context).pop();
          });
          return AlertDialog(
            backgroundColor: AppColors.softGrey,
            shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            content: SizedBox(
              height: MediaQuery.of(context).size.height * 0.2,
              width: MediaQuery.of(context).size.width * 0.004,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LineIcons.checkCircle,
                    color: Colors.green,
                    size: 44,
                    weight: 2,
                  ),
                  Text(
                    "Your job application was sent successfully!",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkSlateBlue,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } on FirebaseException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Firebase Error: ${e.message}')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error submitting application: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isUploading = false;
        uploadProgress = 0.0;
      });
    }
  }

  Future toggleSave() async {
    setState(() {
      isSave = !isSave;
    });
    try {
      final snapshot = await savedVacancies
          .where("savedBy", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .where("jobId", isEqualTo: jobId)
          .get();
      if (snapshot.docs.isNotEmpty) {
        await savedVacancies.doc(snapshot.docs.first.id).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("This job is removed from your saved list."),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        final data = {
          "jobTitle": jobTitle,
          "jobLocation": jobLocation,
          "jobDescription": jobDescription,
          "jobRequirement": jobRequirement,
          "jobType": jobType,
          "workplaceType": workplaceType,
          "companyName": companyName,
          "addedBy": addedBy,
          "jobId": jobId,
          "savedBy": FirebaseAuth.instance.currentUser!.uid,
        };
        await savedVacancies.add(data);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Job saved successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error saving job: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future applyFunction() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.softGrey,
          shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: Form(
            key: _formKey,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                  Card(
                    color: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide(
                        color: AppColors.softPurple.withAlpha(100),
                      ),
                    ),
                    child: TextFormField(
                      controller: fullName,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Enter full name'
                          : null,
                      autocorrect: false,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15,
                        ),
                        border: InputBorder.none,
                        hintText: "Full Name",
                        hintStyle: GoogleFonts.poppins(
                          color: AppColors.darkSlateBlue,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  Card(
                    color: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide(
                        color: AppColors.softPurple.withAlpha(100),
                      ),
                    ),
                    child: TextFormField(
                      controller: contactNumber,
                      autocorrect: false,
                      keyboardType: TextInputType.phone,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Enter contact number'
                          : null,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15,
                        ),
                        border: InputBorder.none,
                        hintText: "Contact Number",
                        hintStyle: GoogleFonts.poppins(
                          color: AppColors.darkSlateBlue,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  Card(
                    color: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide(
                        color: AppColors.softPurple.withAlpha(100),
                      ),
                    ),
                    child: TextFormField(
                      controller: email,
                      autocorrect: false,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Enter email' : null,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15,
                        ),
                        border: InputBorder.none,
                        hintText: "Email",
                        hintStyle: GoogleFonts.poppins(
                          color: AppColors.darkSlateBlue,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  Card(
                    color: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide(
                        color: AppColors.softPurple.withAlpha(100),
                      ),
                    ),
                    child: TextField(
                      controller: resume,
                      readOnly: true,
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          onPressed: () {
                            pickResume();
                          },
                          icon: Icon(
                            LineIcons.upload,
                            color: AppColors.darkSlateBlue,
                            size: 20,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15,
                        ),
                        border: InputBorder.none,
                        hintText: "Resume",
                        hintStyle: GoogleFonts.poppins(
                          color: AppColors.darkSlateBlue,
                        ),
                      ),
                    ),
                  ),
                  isUploading
                      ? Column(
                          children: [
                            LinearProgressIndicator(
                              value: uploadProgress,
                              minHeight: 10,
                              backgroundColor: Colors.grey[300],
                              color: Colors.blueAccent,
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Uploading: ${(uploadProgress * 100).toStringAsFixed(1)}%',
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ],
              ),
            ),
          ),
          actions: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                width: MediaQuery.of(context).size.width * 0.15,
                height: MediaQuery.of(context).size.height * 0.06,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(width: 1, color: AppColors.softPurple),
                ),
                child: Text(
                  "DISCARD",
                  style: GoogleFonts.poppins(
                    color: AppColors.softPurple,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: isUploading
                  ? null
                  : () async {
                if (_formKey.currentState!.validate()) {
                  await apply();
                }
              },
              child: Container(
                width: MediaQuery.of(context).size.width * 0.25,
                height: MediaQuery.of(context).size.height * 0.06,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: AppColors.softPurple,
                ),
                child: Text(
                  "APPLY",
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
  }

  Future reportApplication() async {
    if (selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please select the reason"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    try {
      final details = {
        'reason': selectedReason,
        'details': detailsController.text,
        'reportType': "Job Report",
        'jobTitle': jobTitle,
        'jobId': jobId,
        'postedBy': addedBy,
        'postedByName': companyName,
        'reportedBy': FirebaseAuth.instance.currentUser!.uid,
        'status': "Pending",
        'reportedByName': candidateName,
      };
      await report.add(details);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error updating application: $e"),
          backgroundColor: Colors.red,
        ),
      );
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
        elevation: 2,
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                // spacing: 10,
                runSpacing: 8,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Text(
                      jobTitle,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: AppColors.darkSlateBlue,
                      ),
                      softWrap: true,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            backgroundColor: AppColors.softGrey,
                            shape: ContinuousRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            content: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.35,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text.rich(
                                    TextSpan(
                                      text:
                                          "What’s the reason for your report?",
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.darkSlateBlue,
                                        fontSize: 14,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: ' *',
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Card(
                                    color: Colors.white,
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      side: BorderSide(
                                        color: AppColors.softPurple.withAlpha(
                                          100,
                                        ),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      child: DropdownButtonFormField<String>(
                                        value: selectedReason,
                                        isExpanded: true,
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                        ),
                                        hint: Text(
                                          "Select a reason",
                                          style: GoogleFonts.poppins(
                                            color: AppColors.darkSlateBlue
                                                .withAlpha(150),
                                          ),
                                        ),
                                        items:
                                            [
                                              'Fraudulent Job Posting',
                                              'Misleading Job Details',
                                              'Scam or Suspicious Intent',
                                              'Offensive Content',
                                              'Other',
                                            ].map((reason) {
                                              return DropdownMenuItem<String>(
                                                value: reason,
                                                child: Text(
                                                  reason,
                                                  style: GoogleFonts.poppins(
                                                    color:
                                                        AppColors.darkSlateBlue,
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                        onChanged: (value) {
                                          selectedReason = value;
                                        },
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    "Tell us more (optional)",
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.darkSlateBlue,
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Card(
                                    color: Colors.white,
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      side: BorderSide(
                                        color: AppColors.softPurple.withAlpha(
                                          100,
                                        ),
                                      ),
                                    ),
                                    child: TextField(
                                      controller: detailsController,
                                      maxLines: 5,
                                      decoration: InputDecoration(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 15,
                                            ),
                                        border: InputBorder.none,
                                        hintText:
                                            "Provide additional details to help us review this report.",
                                        hintStyle: GoogleFonts.poppins(
                                          color: AppColors.darkSlateBlue
                                              .withAlpha(150),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            actionsAlignment: MainAxisAlignment.spaceBetween,
                            actions: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.15,
                                  height:
                                      MediaQuery.of(context).size.height * 0.06,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      width: 1,
                                      color: AppColors.softPurple,
                                    ),
                                  ),
                                  child: Text(
                                    "DISCARD",
                                    style: GoogleFonts.poppins(
                                      color: AppColors.softPurple,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  reportApplication(); // define this function in your logic
                                },
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.25,
                                  height:
                                      MediaQuery.of(context).size.height * 0.06,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: AppColors.softPurple,
                                  ),
                                  child: Text(
                                    "REPORT",
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
                      Icons.flag_outlined,
                      color: Colors.red.withAlpha(180),
                    ),
                    tooltip: "Report the Vacancy",
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              Row(
                children: [
                  Text(
                    "Job Description",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkSlateBlue,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Text(
                jobDescription,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              Row(
                children: [
                  Text(
                    "Requirements",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkSlateBlue,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Text(
                jobRequirement,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              Row(
                children: [
                  Icon(
                    LineIcons.building,
                    color: AppColors.darkSlateBlue,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    workplaceType,
                    style: GoogleFonts.poppins(
                      color: AppColors.darkSlateBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Row(
                children: [
                  Icon(
                    LineIcons.briefcase,
                    color: AppColors.darkSlateBlue,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    jobType,
                    style: GoogleFonts.poppins(
                      color: AppColors.darkSlateBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              Row(
                children: [
                  Text(
                    "Company Details",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkSlateBlue,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    'recruiters_profile',
                    arguments: {'profileId': addedBy},
                  );
                },
                child: Text(
                  companyName,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Row(
                children: [
                  Icon(LineIcons.alternateMapMarked),
                  SizedBox(width: 8),
                  Text(
                    jobLocation,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  isLoading
                      ? CircularProgressIndicator()
                      : IconButton(
                          onPressed: toggleSave,
                          icon: isSave
                              ? Icon(
                                  CupertinoIcons.bookmark_solid,
                                  color: AppColors.darkSlateBlue,
                                )
                              : Icon(CupertinoIcons.bookmark),
                        ),
                  GestureDetector(
                    onTap: () => isApply ? null : applyFunction(),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: MediaQuery.of(context).size.height * 0.06,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: isApply
                            ? AppColors.softGrey
                            : AppColors.softPurple,
                      ),
                      child: Text(
                        isApply ? "APPLIED " : "APPLY",
                        style: GoogleFonts.poppins(
                          color: isApply ? Colors.black : Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            ],
          ),
        ),
      ),
    );
  }
}
