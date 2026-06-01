import 'package:hire_nest_jobs/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';

class ApplicationView extends StatefulWidget {
  const ApplicationView({super.key});

  @override
  State<ApplicationView> createState() => _ApplicationViewState();
}

class _ApplicationViewState extends State<ApplicationView> {
  TextEditingController fullName = TextEditingController();
  TextEditingController contactNumber = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController resume = TextEditingController();

  Color statusColor(status) {
    if (status == 'Applied') {
      return Colors.grey;
    } else if (status == 'Under Review') {
      return Colors.amber;
    } else if (status == 'Selected') {
      return Colors.green;
    } else if (status == 'Rejected') {
      return Colors.red;
    } else {
      return AppColors.mutedLavender;
    }
  }

  late String status,
      jobId,
      companyName,
      jobTitle,
      jobDescription,
      jobRequirement,
      jobType,
      jobLocation,
      workplaceType,
      id,
      resumeFileName,
      addedBy;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    fullName.text = args['candidateName'];
    contactNumber.text = args['contactNumber'];
    email.text = args['email'];
    status = args['status'];
    jobId = args['jobId'];
    companyName = args['companyName'];
    jobTitle = args['jobTitle'];
    jobDescription = args['jobDescription'];
    jobRequirement = args['jobRequirement'];
    jobType = args['jobType'];
    jobLocation = args['jobLocation'];
    workplaceType = args['workplaceType'];
    addedBy = args['addedBy'];
    resumeFileName = args['resumeFileName'];
    id = args['id'];
  }
  final CollectionReference jobApplication = FirebaseFirestore.instance.collection('Job Application');

  Future update()async{
    try{
      if(fullName.text.isEmpty ||
          contactNumber.text.isEmpty ||
          email.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Please complete all required fields."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      final details = {
        'candidateName' : fullName.text,
        'contactNumber' : contactNumber.text,
        'email' : email.text
      }; await jobApplication.doc(id).update(details);
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (context) {
          Future.delayed(
            const Duration(seconds: 2),
                () {
              Navigator.of(context).pop();
            },
          );
          return AlertDialog(
            backgroundColor: AppColors.softGrey,
            shape: ContinuousRectangleBorder(
              borderRadius:
              BorderRadius.circular(15),
            ),
            content: SizedBox(
              height:
              MediaQuery.of(
                context,
              ).size.height *
                  0.2,
              width:
              MediaQuery.of(
                context,
              ).size.width *
                  0.004,
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.center,
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  Icon(
                    LineIcons.checkCircle,
                    color: Colors.green,
                    size: 44,
                    weight: 2,
                  ),
                  Text(
                    "The application has been updated.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontWeight:
                      FontWeight.bold,
                      color:
                      AppColors
                          .darkSlateBlue,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update application."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future delete()async{
    try{
      jobApplication.doc(id).delete();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            "Job deleted successfully!",
          ),
          backgroundColor:
          AppColors.softPurple,
          duration: const Duration(
            seconds: 3,
          ),
        ),
      );
      Navigator.pop(context);
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error deleting application: $e"),
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
        elevation: 0,
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
                // spacing: 12,
                runSpacing: 8,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
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
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      status == 'Applied'? IconButton(
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
                                  height:
                                      MediaQuery.of(context).size.height * 0.5,
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                            0.04,
                                      ),
                                      Card(
                                        color: Colors.white,
                                        elevation: 4,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                          side: BorderSide(
                                            color: AppColors.softPurple
                                                .withAlpha(100),
                                          ),
                                        ),
                                        child: TextField(
                                          controller: fullName,
                                          autocorrect: false,
                                          decoration: InputDecoration(
                                            contentPadding:
                                                const EdgeInsets.symmetric(
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
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                            0.01,
                                      ),
                                      Card(
                                        color: Colors.white,
                                        elevation: 4,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                          side: BorderSide(
                                            color: AppColors.softPurple
                                                .withAlpha(100),
                                          ),
                                        ),
                                        child: TextField(
                                          controller: contactNumber,
                                          autocorrect: false,
                                          keyboardType: TextInputType.phone,
                                          decoration: InputDecoration(
                                            contentPadding:
                                                const EdgeInsets.symmetric(
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
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                            0.01,
                                      ),
                                      Card(
                                        color: Colors.white,
                                        elevation: 4,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                          side: BorderSide(
                                            color: AppColors.softPurple
                                                .withAlpha(100),
                                          ),
                                        ),
                                        child: TextField(
                                          controller: email,
                                          autocorrect: false,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          decoration: InputDecoration(
                                            contentPadding:
                                                const EdgeInsets.symmetric(
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
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                            0.01,
                                      ),
                                      Card(
                                        color: Colors.white,
                                        elevation: 4,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                          side: BorderSide(
                                            color: AppColors.softPurple
                                                .withAlpha(100),
                                          ),
                                        ),
                                        child: TextField(
                                          readOnly: true,
                                          decoration: InputDecoration(
                                            suffixIcon: IconButton(
                                              onPressed: () {},
                                              icon: Icon(
                                                LineIcons.upload,
                                                color: AppColors.darkSlateBlue,
                                                size: 20,
                                              ),
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
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
                                    ],
                                  ),
                                ),
                                actions: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
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
                                      update();
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
                                        borderRadius: BorderRadius.circular(15),
                                        color: AppColors.softPurple,
                                      ),
                                      child: Text(
                                        "UPDATE",
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
                          LineIcons.edit,
                          color: AppColors.darkSlateBlue,
                          size: 24,
                        ),
                        tooltip: "Edit",
                      ): Text(''),
                      IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: Text(
                                    "Delete Application?",
                                    style: GoogleFonts.poppins(
                                      color: AppColors.darkSlateBlue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  content: Text(
                                    "Are you sure you want to delete this job application?",
                                    style: GoogleFonts.poppins(
                                      color: AppColors.darkSlateBlue.withAlpha(
                                        180,
                                      ),
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
                                    TextButton(
                                      onPressed: () {
                                        delete();
                                      },
                                      child: Text(
                                        "Delete",
                                        style: GoogleFonts.poppins(
                                          color: Colors.red,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                          );
                        },
                        icon: Icon(
                          LineIcons.trash,
                          color: Colors.red,
                          size: 24,
                        ),tooltip: 'Delete',
                      ),
                    ],
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
              Row(
                children: [
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
                ],
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
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              Row(
                children: [
                  Text(
                    "Personal Details",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkSlateBlue,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Row(
                children: [
                  Icon(CupertinoIcons.mail),
                  SizedBox(width: 8),
                  Expanded(
                    child: Tooltip(
                      message: email.text,
                      child: Text(
                        email.text,
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Row(
                children: [
                  Icon(CupertinoIcons.phone),
                  SizedBox(width: 8),
                  Text(
                    contactNumber.text,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Row(
                children: [
                  Icon(CupertinoIcons.doc_person),
                  SizedBox(width: 8),
                  Expanded(
                    child: Tooltip(
                      message: resumeFileName,
                      child: Text(
                        resumeFileName,
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.04),
              Row(
                children: [
                  Text(
                    "Status :",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkSlateBlue,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    status,
                    style: GoogleFonts.poppins(
                      color: statusColor(status),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            ],
          ),
        ),
      ),
    );
  }
}