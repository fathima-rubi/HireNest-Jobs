import 'package:hire_nest_jobs/application/applications.dart';
import 'package:hire_nest_jobs/home/home.dart';
import 'package:hire_nest_jobs/vacancy/job.dart';
import 'package:hire_nest_jobs/main.dart';
import 'package:hire_nest_jobs/profile/profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int currentIndex = 0;
  List pages = [Home(),Job(),Applications(),Profile()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softGrey,
      bottomNavigationBar: Card(
        elevation: 4,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
        ),
        color: AppColors.softPurple.withAlpha(230),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(LineIcons.home),
                color: currentIndex == 0
                    ? Colors.white
                    : Colors.white54,
                onPressed: () => setState(() => currentIndex = 0),
              ),
              IconButton(
                icon: Icon(LineIcons.suitcase),
                color: currentIndex == 1
                    ? Colors.white
                    : Colors.white54,
                onPressed: () => setState(() => currentIndex = 1),
              ),
              IconButton(
                icon: Icon(CupertinoIcons.doc_person),
                color: currentIndex == 2
                    ? Colors.white
                    : Colors.white54,
                onPressed: () => setState(() => currentIndex = 2),
              ),
              IconButton(
                icon: Icon(CupertinoIcons.person),
                color: currentIndex == 3
                    ? Colors.white
                    : Colors.white54,
                onPressed: () => setState(() => currentIndex = 3),
              ),
            ],
          ),
        ),
      ),
      body: pages[currentIndex],
    );
  }
}
