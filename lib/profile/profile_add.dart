import 'package:hire_nest_jobs/bottom_bar.dart';
import 'package:hire_nest_jobs/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileAdd extends StatefulWidget {
  const ProfileAdd({super.key});

  @override
  State<ProfileAdd> createState() => _ProfileAddState();
}

class _ProfileAddState extends State<ProfileAdd> {
  TextEditingController fullName = TextEditingController();
  TextEditingController headline = TextEditingController();
  TextEditingController location = TextEditingController();
  TextEditingController about = TextEditingController();
  TextEditingController skills = TextEditingController();
  TextEditingController contactNumber = TextEditingController();
  TextEditingController website = TextEditingController();
  final userEmail = FirebaseAuth.instance.currentUser!.email;
  final CollectionReference candidatesDetails = FirebaseFirestore.instance
      .collection("Candidates");

  bool isLoading = false;

  Future addProfileDetails() async {
    setState(() => isLoading = true);
    if (fullName.text.isEmpty || headline.text.isEmpty || about.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("Please fill all required fields."),
        ),
      );
      setState(() => isLoading = false);
      return;
    }
    final isNumeric = RegExp(r'^[0-9]+$');
    if (!isNumeric.hasMatch(contactNumber.text) ||
        contactNumber.text.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("Please enter a valid contact number."),
        ),
      );
      setState(() => isLoading = false);
      return;
    }

    // if (website.text.isNotEmpty && !website.text.startsWith(RegExp(r'https?://'))) {
    //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //     backgroundColor: Colors.red,
    //     content: Text("Website must start with http:// or https://"),
    //   ));
    //   setState(() => isLoading = true);
    //   return;
    // }
    try {
      final userDetails = {
        'addedBy': FirebaseAuth.instance.currentUser!.uid,
        'fullName': fullName.text,
        'headline': headline.text,
        'location': location.text,
        'about': about.text,
        'skills': skills.text,
        'contactNumber': contactNumber.text,
        'website': website.text,
        'email': userEmail,
        'timestamp': FieldValue.serverTimestamp(),
      };
      await candidatesDetails
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set(userDetails);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BottomBar()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("$e. Please try again."),
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    fullName.dispose();
    headline.dispose();
    location.dispose();
    about.dispose();
    skills.dispose();
    contactNumber.dispose();
    website.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softGrey,
      appBar: AppBar(
        leading: Text(""),
        title: Text(
          "Add Profile Details",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: AppColors.softPurple,
          ),
        ),
        backgroundColor: AppColors.softGrey,
        centerTitle: true,
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
              RichText(
                text: TextSpan(
                  text: "Full Name ",
                  style: GoogleFonts.poppins(
                    color: AppColors.darkSlateBlue,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(text: "*", style: TextStyle(color: Colors.red)),
                  ],
                ),
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
                  controller: fullName,
                  keyboardType: TextInputType.name,
                  autofillHints: [AutofillHints.name],
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 12,
                    ),
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () => fullName.clear(),
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              RichText(
                text: TextSpan(
                  text: "Headline ",
                  style: GoogleFonts.poppins(
                    color: AppColors.darkSlateBlue,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(text: "*", style: TextStyle(color: Colors.red)),
                  ],
                ),
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
                  controller: headline,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 12,
                    ),
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () => headline.clear(),
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              Text(
                "Location",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkSlateBlue,
                ),
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
                  controller: location,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 12,
                    ),
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () => location.clear(),
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              RichText(
                text: TextSpan(
                  text: "About ",
                  style: GoogleFonts.poppins(
                    color: AppColors.darkSlateBlue,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(text: "*", style: TextStyle(color: Colors.red)),
                  ],
                ),
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
                  minLines: 4,
                  controller: about,
                  maxLines: 5,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 12,
                    ),
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () => about.clear(),
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              Text(
                "Skills",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkSlateBlue,
                ),
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
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () => skills.clear(),
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              Text(
                "Contact Number",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkSlateBlue,
                ),
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
                  keyboardType: TextInputType.phone,
                  autofillHints: [AutofillHints.telephoneNumber],
                  controller: contactNumber,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 12,
                    ),
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () => contactNumber.clear(),
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              Text(
                "Website",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkSlateBlue,
                ),
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
                  keyboardType: TextInputType.url,
                  controller: website,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 12,
                    ),
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () => website.clear(),
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              Center(
                child: InkWell(
                  onTap: () => addProfileDetails(),
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: MediaQuery.of(context).size.height * 0.06,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: isLoading ? Colors.grey : AppColors.softPurple,
                      boxShadow:
                          isLoading
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
                        isLoading
                            ? SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : Text(
                              "CREATE",
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
