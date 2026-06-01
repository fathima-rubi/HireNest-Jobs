import 'package:hire_nest_jobs/authentication/login.dart';
import 'package:hire_nest_jobs/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {

  TextEditingController email = TextEditingController();

  Future reset(context) async {
    if (email.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please enter your email address."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (!email.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please enter a valid email address."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.text);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password reset link sent to $email'),
          backgroundColor: Colors.green,
        ),
      );
      await FirebaseAuth.instance.signOut();
      final SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setBool('isLogged', false);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Login(),));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("Found an error. Please try again."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softGrey,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Reset Your Password",
              style: GoogleFonts.poppins(
                color: AppColors.mutedLavender,
                fontWeight: FontWeight.bold,
                fontSize: 28,
                letterSpacing: 0.8,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.015),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                    text: "No worries! ",
                    style: GoogleFonts.poppins(
                      color: AppColors.darkSlateBlue.withAlpha(180),
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      height: 1.6,
                    ),
                    children: [
                      TextSpan(
                        text: "Enter your email ",
                        style: GoogleFonts.poppins(
                          color: AppColors.softPurple,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                          text: "to reset your password and get back to hiring."
                      )
                    ]
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Card(
                color: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(color: AppColors.softPurple.withAlpha(100)),
                ),
                child: TextField(
                  controller: email,
                  autocorrect: false,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                    border: InputBorder.none,
                    labelText: "Email",
                    labelStyle: GoogleFonts.poppins(
                      color: AppColors.darkSlateBlue,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.04),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Card(
                      color: AppColors.softGrey,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(color: AppColors.darkSlateBlue.withAlpha(100)),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        borderRadius: BorderRadius.circular(15),
                        child: Container(
                          height : MediaQuery.of(context).size.height * 0.06,
                          alignment: Alignment.center,
                          child: Text(
                            "DISCARD",
                            style: GoogleFonts.poppins(
                              color: AppColors.darkSlateBlue,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ), SizedBox(width: 15),
                  Expanded(
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: InkWell(
                        onTap: () {
                          reset(context);
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
                                color: AppColors.darkSlateBlue.withAlpha(100),
                                blurRadius: 8,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            "RESET",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
