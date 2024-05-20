import 'package:diyetisyenapp/constants/fonts.dart';
import 'package:diyetisyenapp/widget/buttons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage("assets/images/avatar.jpg")),
            Container(
              child: const Text("Profil"),
            ),
            Icon(
              Icons.power_off_outlined,
              color: mainColor,
            )
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                child: const CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage("assets/images/avatar.jpg"),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Container(
                  decoration: BoxDecoration(
                    color: Colors.amberAccent,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.85,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Email:"),
                            // BlocBuilder<AuthenticationBloc, AuthenticationState>(
                            //   builder: (context, state) {
                            //     return Text('${state.user?.email ?? 'N/A'}');
                            //   },
                            // ),
                          ],
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.85,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Full Name:"),
                            // BlocBuilder<AuthenticationBloc, AuthenticationState>(
                            //   builder: (context, state) {
                            //     return Text('${'KAAN' ?? 'N/A'}');
                            //   },
                            // ),
                          ],
                        ),
                      ),
                      Container(
                          width: MediaQuery.of(context).size.width * 0.85,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Age:"),
                              // BlocBuilder<AuthenticationBloc,
                              //     AuthenticationState>(
                              //   builder: (context, state) {
                              //     return Text('${"5375019024" ?? 'N/A'}');
                              //   },
                              // ),
                            ],
                          )),
                    ],
                  )),
              const SizedBox(
                height: 15,
              ),
              Container(
                  decoration: BoxDecoration(
                    color: Colors.amberAccent,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      profileButtonsColumn("Notification"),
                      profileButtonsColumn("Apply promo ode"),
                      profileButtonsColumn("Join to the community"),
                      profileButtonsColumn("Share with friends"),
                      profileButtonsColumn("Contact support"),
                      profileButtonsColumn("Privacy policy"),
                      profileButtonsColumn("Terms & Conditions"),
                      profileButtonsColumn("Language"),
                    ],
                  )),
              const SizedBox(
                height: 15,
              ),
              Container(
                  decoration: BoxDecoration(
                    color: Colors.amberAccent,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  width: MediaQuery.of(context).size.width,
                  child: const Column(
                    children: [
                      MyButton(
                        text: "Sign Out",
                        buttonColor: Colors.black,
                        buttonTextColor: Colors.blue,
                        buttonTextSize: 15,
                        buttonTextWeight: FontWeight.bold,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      MyButton(
                        text: "Dark Mode",
                        buttonColor: Colors.black,
                        buttonTextColor: Colors.white,
                        buttonTextSize: 15,
                        buttonTextWeight: FontWeight.bold,
                      )
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Container profileButtonsColumn(final String text) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.black, width: 1.0))),
      child: InkWell(
        onTap: () {
          print("bastın");
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(text),
                const Icon(CupertinoIcons.arrow_right_square_fill)
              ],
            ),
            const SizedBox(
              height: 5,
            )
          ],
        ),
      ),
    );
  }
}
