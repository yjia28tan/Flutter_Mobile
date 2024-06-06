import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:habitual_heart_app/pages/mood_update_page.dart';

import '../design/font_style.dart';
import 'home_page.dart';

class MoodDetailsPage extends StatefulWidget {
  final String moodId;

  const MoodDetailsPage({Key? key, required this.moodId}) : super(key: key);

  @override
  State<MoodDetailsPage> createState() => _MoodDetailsPageState();
}

class _MoodDetailsPageState extends State<MoodDetailsPage> {
  Icon? todayMoodIcon;
  String? moodDescription;
  String? mood;
  DateTime? timestamp;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMoodDetails(widget.moodId);
  }

  void refreshHomePage() {
    setState(() {
      // Refresh your data here
    });
  }

  void getMoodIcon(String mood) {
    switch (mood) {
      case 'Excellent':
        todayMoodIcon = Icon(Icons.sentiment_very_satisfied);
        break;
      case 'Good':
        todayMoodIcon = Icon(Icons.sentiment_satisfied);
        break;
      case 'Neutral':
        todayMoodIcon = Icon(Icons.sentiment_neutral);
        break;
      case 'Bad':
        todayMoodIcon = Icon(Icons.sentiment_dissatisfied);
        break;
      case 'Terrible':
        todayMoodIcon = Icon(Icons.sentiment_very_dissatisfied);
        break;
      default:
        todayMoodIcon = null;
    }
  }

  Future<void> fetchMoodDetails(String moodId) async {
    try {
      DocumentSnapshot moodDoc = await FirebaseFirestore.instance
          .collection('moodRecord')
          .doc(moodId)
          .get();

      if (moodDoc.exists) {
        setState(() {
          mood = moodDoc['mood'];
          moodDescription = moodDoc['description'];
          timestamp = (moodDoc['timestamp'] as Timestamp).toDate();
          getMoodIcon(mood!);
          isLoading = false;
        });
      } else {
        setState(() {
          moodDescription = 'No description available.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        moodDescription = 'Error fetching description: $e';
        isLoading = false;
      });
    }
  }

  Future<void> deleteMood(String moodId) async {
    try {
      await FirebaseFirestore.instance
          .collection('moodRecord')
          .doc(moodId)
          .delete();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage()
        ),
      ).then((value) => setState(() {})
      );

      // Trigger a rebuild of the homepage by setting the state
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting mood: $e'),
        ),
      );
    }
  }

  void showDeleteConfirmationDialog(String moodId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this mood record?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                deleteMood(moodId);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HomePage()
                  ),
                ).then((value) => setState(() {})
                );
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => HomePage()
              ),
            ).then((value) => setState(() {})
            );
          },
        ),
        title: Text(
          'Mood Details',
          style: headerText,
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (todayMoodIcon != null)
                    Icon(
                      todayMoodIcon!.icon,
                      size: 100,
                      color: Color(0xFF366021),
                    ),
                  SizedBox(height: 16),
                  Text(
                    'Mood: $mood',
                    style: TextStyle(fontSize: 24, color: Color(0xFF366021)),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Description:',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF366021)),
                  ),
                  SizedBox(height: 8),
                  Text(
                    moodDescription ?? 'Loading...',
                    style: TextStyle(fontSize: 16, color: Color(0xFF366021)),
                  ),
                  SizedBox(height: 16),
                  Container(
                    height: 45,
                    width: 250,
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.edit, color: Color(0xFF366021)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFE5FFD0),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MoodUpdatePage(
                              moodId: widget.moodId,
                              onUpdateHome: refreshHomePage,
                            ),
                          ),
                        );
                      },
                      label: Text('Edit', style: homeSubHeaderText),
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    height: 45,
                    width: 250,
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.delete_forever, color: Color(0xFF366021)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFE5FFD0),
                      ),
                      onPressed: () {
                        showDeleteConfirmationDialog(widget.moodId);
                      },
                      label: Text('Delete', style: homeSubHeaderText),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
