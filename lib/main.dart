import 'package:hire_nest_jobs/application/application_view.dart';
import 'package:hire_nest_jobs/bottom_bar.dart';
import 'package:hire_nest_jobs/firebase_options.dart';
import 'package:hire_nest_jobs/profile/education/education_add.dart';
import 'package:hire_nest_jobs/profile/education/education_edit.dart';
import 'package:hire_nest_jobs/profile/education/education_view.dart';
import 'package:hire_nest_jobs/profile/experience/experience_add.dart';
import 'package:hire_nest_jobs/profile/experience/experience_edit.dart';
import 'package:hire_nest_jobs/profile/experience/experience_view.dart';
import 'package:hire_nest_jobs/authentication/forgot_password.dart';
import 'package:hire_nest_jobs/vacancy/job_saved_view.dart';
import 'package:hire_nest_jobs/vacancy/job_view.dart';
import 'package:hire_nest_jobs/vacancy/jobs_saved.dart';
import 'package:hire_nest_jobs/authentication/login.dart';
import 'package:hire_nest_jobs/profile/profile_edit.dart';
import 'package:hire_nest_jobs/recruiters_profile.dart';
import 'package:hire_nest_jobs/authentication/reset_password.dart';
import 'package:hire_nest_jobs/home/search.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'authentication/sign_up.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Main(),
      routes: {
        'forgot_password': (context) => ForgotPassword(),
        'sign_up': (context) => SignUp(),
        'profile_edit': (context) => ProfileEdit(),
        'reset_password': (context) => ResetPassword(),
        'job_view': (context) => JobView(),
        'recruiters_profile': (context) => RecruitersProfile(),
        'application_view': (context) => ApplicationView(),
        'jobs_saved': (context) => JobsSaved(),
        'education_add': (context) => EducationAdd(),
        'experience_add': (context) => ExperienceAdd(),
        'education_view': (context) => EducationView(),
        'experience_view': (context) => ExperienceView(),
        'education_edit': (context) => EducationEdit(),
        'experience_edit': (context) => ExperienceEdit(),
        'search' : (context) => Search(),
        'job_saved_view' : (context) => JobSavedView()
      },
    ),
  );
}

class AppColors {
  static const Color softPurple = Color(0xFF5D4373);
  static const Color softGrey = Color(0xFFF1F1F1);
  static const Color warmAmber = Color(0xFFF3A712);
  static const Color darkSlateBlue = Color(0xFF2B2D42);
  static const Color mutedLavender = Color(0xFFA07CC5);
}

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> fadeAnimation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
    controller.forward();
    Future.delayed(Duration(seconds: 3), () async { // Ensure the splash screen is visible for at least 3 seconds
      await sharedPreference(); // Wait for sharedPreference to complete
      if (data == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BottomBar()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Login()),
        );
      }
    });
  }

  bool? data;

  Future sharedPreference() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    var getData = preferences.getBool('isLogged');
    setState(() {
      data = getData;
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.softPurple.withAlpha(240),
              AppColors.mutedLavender.withAlpha(210),
              AppColors.darkSlateBlue.withAlpha(240),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FadeTransition(
          opacity: fadeAnimation,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: MediaQuery.of(context).size.width * 0.2,
                  width: MediaQuery.of(context).size.width * 0.2,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('lib/assets/logo.png'),
                      fit: BoxFit.cover,
                      opacity: 0.6,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                Text(
                  "HireNest Jobs",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 38,
                    letterSpacing: 1.5,
                    shadows: [
                      Shadow(
                        blurRadius: 10,
                        color: Colors.black.withAlpha(100),
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Text(
                  "Showcase • Network • Succeed.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.white.withAlpha(220),
                    fontWeight: FontWeight.w400,
                    fontSize: 20,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
