import 'package:hire_nest_jobs/main.dart';
import 'package:hire_nest_jobs/profile/profile_add.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  bool obscureText = true;
  bool isLoading = false;


  final CollectionReference users =
  FirebaseFirestore.instance.collection("Users");

  Future signup()async{
    setState(() {
      isLoading = true;
    });
    if(email.text.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Email is required. Please enter your email address."),backgroundColor: Colors.red,));
      setState(() {
        isLoading = false;
      });
      return;
    }
    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
    if (!emailRegex.hasMatch(email.text)){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please enter a valid email address."),backgroundColor: Colors.red,));
      setState(() {
        isLoading = false;
      });
      return;
    }
    if(password.text.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Password is required. Please enter your password."),backgroundColor: Colors.red,));
      setState(() {
        isLoading = false;
      });
      return;
    }
    if(password.text.length<=6){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Password must be at least 6 characters long."),backgroundColor: Colors.red,));
      setState(() {
        isLoading = false;
      });
      return;
    }
    try{
      await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email.text, password: password.text);
      final userDetails = {
        'email' : FirebaseAuth.instance.currentUser!.email,
        'userId' : FirebaseAuth.instance.currentUser!.uid,
        'role' : 'Candidate'
      }; await users.doc(FirebaseAuth.instance.currentUser!.uid).set(userDetails);
      final SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setBool('isLogged', true);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProfileAdd(),));
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("An error occurred. Please try again."),backgroundColor: Colors.red,));
    }finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softGrey,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.25),
              Text(
                "Join HireNest Jobs Today!",
                style: GoogleFonts.poppins(
                  color: AppColors.mutedLavender,
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  height: 1.5
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Text(
                "Create your account and take the next step in your career.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: AppColors.darkSlateBlue.withAlpha(180),
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                  height: 1.3,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
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
                      labelStyle: GoogleFonts.poppins(color: AppColors.darkSlateBlue),
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Card(
                  color: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(color: AppColors.softPurple.withAlpha(100)),
                  ),
                  child: TextField(
                    controller: password,
                    obscureText: obscureText,
                    autocorrect: false,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                      border: InputBorder.none,
                      labelText: "Password",
                      labelStyle: GoogleFonts.poppins(color: AppColors.darkSlateBlue),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            obscureText = !obscureText;
                          });
                        },
                        icon: Icon(
                          obscureText ? LineIcons.eyeSlash : LineIcons.eye,
                          color: AppColors.darkSlateBlue,
                        ),
                      ),
                    ),
                  ),
                ),),
              SizedBox(height: MediaQuery.of(context).size.height * 0.04),
              GestureDetector(
                onTap: () => signup(),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                  height: MediaQuery.of(context).size.height * 0.06,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                   color: isLoading
                       ? Colors.grey
                       : AppColors.softPurple,
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
                  child: isLoading
                      ? SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : Text(
                    "SIGNUP",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),
              Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an Account?",
                      style: GoogleFonts.poppins(
                        color: AppColors.darkSlateBlue,
                        fontSize: 14,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Log In.",
                        style: GoogleFonts.poppins(
                          color: AppColors.mutedLavender,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
