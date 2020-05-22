import 'package:ezphotoupload/ui/screens/feed_screen.dart';
import 'package:ezphotoupload/ui/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _tabIndex = 0;

  //controllers
  final feedController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabIndex,
        onTap: (val) {
          if (val == 0 && val == _tabIndex) {
            if (feedController.hasClients)
              feedController.animateTo(0,
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut);
          }
          setState(() {
            _tabIndex = val;
          });
        },
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.photo),
            title: Text('Photos'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            title: Text('Account'),
          ),
        ],
      ),
      body: IndexedStack(
        index: _tabIndex,
        children: <Widget>[
          FeedScreen(
            controller: feedController,
          ),
          ProfileScreen(),
        ],
      ),
    );
  }
}
