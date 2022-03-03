import 'package:book_tracker/constants/constants.dart';
import 'package:book_tracker/model/book.dart';
import 'package:book_tracker/screens/main_screen.dart';
import 'package:book_tracker/util/util.dart';
import 'package:book_tracker/widgets/input_decoration.dart';
import 'package:book_tracker/widgets/two_sided_roundbutton.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class BookDetailsDialog extends StatefulWidget {
  const BookDetailsDialog({
    Key key,
    @required this.book,
  }) : super(key: key);

  final Book book;

  @override
  _BookDetailsDialogState createState() => _BookDetailsDialogState();
}

class _BookDetailsDialogState extends State<BookDetailsDialog> {
  bool isReadingClicked = false;
  bool isFinishedReadingClicked = false;
  TextEditingController _notestTextController;

  double _rating;
  final _bookCollectionReference =
      FirebaseFirestore.instance.collection('books');

  @override
  void initState() {
    _notestTextController = TextEditingController(text: widget.book.notes);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController _titleTextController =
        TextEditingController(text: widget.book.title);
    TextEditingController _authorTextController =
        TextEditingController(text: widget.book.author);
    TextEditingController _photoTextController =
        TextEditingController(text: widget.book.photoUrl);

    // TextEditingController _notestTextController =
    //     TextEditingController(text: widget.book.notes);

    return AlertDialog(
      title: Column(
        children: [
          Row(
            children: [
              const Spacer(),
              const Spacer(),
              CircleAvatar(
                backgroundColor: Colors.transparent,
                backgroundImage: NetworkImage(widget.book.photoUrl),
                radius: 50,
              ),
              const Spacer(),
              Container(
                margin: const EdgeInsets.only(bottom: 100),
                child: TextButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    label: const Text('')),
              )
            ],
          ),
          Text(widget.book.author)
        ],
      ),
      content: Form(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _titleTextController,
                  decoration: buildInputDecoration(
                      label: 'Book title', hintText: 'Flutter Development'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _authorTextController,
                  decoration: buildInputDecoration(
                      label: 'Author', hintText: 'Jeff A.'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _photoTextController,
                  decoration:
                      buildInputDecoration(label: 'Book cover', hintText: ''),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              TextButton.icon(
                  onPressed: widget.book.startedReading == null
                      ? () {
                          setState(() {
                            if (isReadingClicked == false) {
                              isReadingClicked = true;
                            } else {
                              isReadingClicked = false;
                            }
                          });
                        }
                      : null,
                  icon: const Icon(Icons.book_sharp),
                  label: (widget.book.startedReading == null)
                      ? (!isReadingClicked)
                          ? const Text('Start Reading')
                          : Text(
                              'Started Reading...',
                              style: TextStyle(color: Colors.blueGrey.shade300),
                            )
                      : Text(
                          'Started on: ${formatDate(widget.book.startedReading)}')),
              TextButton.icon(
                  onPressed: widget.book.finishedReading == null
                      ? () {
                          setState(() {
                            if (isFinishedReadingClicked == false) {
                              isFinishedReadingClicked = true;
                            } else {
                              isFinishedReadingClicked = false;
                            }
                          });
                        }
                      : null,
                  icon: const Icon(Icons.done),
                  label: (widget.book.finishedReading == null)
                      ? (!isFinishedReadingClicked)
                          ? const Text('Mark as Read')
                          : const Text(
                              'Finished Reading!',
                              style: TextStyle(color: Colors.grey),
                            )
                      : Text(
                          'Finished on ${formatDate(widget.book.finishedReading)}')),
              RatingBar.builder(
                  allowHalfRating: true,
                  initialRating: widget.book.rating ?? 4.5,
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    switch (index) {
                      case 0:
                        return const Icon(
                          Icons.sentiment_very_dissatisfied,
                          color: Colors.red,
                        );
                      case 1:
                        return const Icon(
                          Icons.sentiment_dissatisfied,
                          color: Colors.redAccent,
                        );
                      case 2:
                        return const Icon(
                          Icons.sentiment_neutral,
                          color: Colors.amber,
                        );
                      case 3:
                        return const Icon(
                          Icons.sentiment_satisfied,
                          color: Colors.lightGreen,
                        );
                      case 4:
                        return const Icon(
                          Icons.sentiment_very_satisfied,
                          color: Colors.green,
                        );
                      default:
                        return Container();
                    }
                  },
                  onRatingUpdate: (rating) {
                    setState(() {
                      _rating = rating;
                    });
                  }),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _notestTextController,
                  decoration: buildInputDecoration(
                      label: 'Your thoughts', hintText: 'Enter notes'),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TwoSidedRoundeButton(
                    text: 'Update',
                    radius: 12,
                    color: kIconColor,
                    press: () {
                      // Only update if new data was entered
                      final userChangedTitle =
                          widget.book.title != _titleTextController.text;
                      final userChangedAuthor =
                          widget.book.author != _authorTextController.text;
                      final userChangedPhotoUrl =
                          widget.book.author != _photoTextController.text;

                      final userChangedRating = widget.book.rating != _rating;

                      final userChangedNotes =
                          widget.book.notes != _notestTextController.text;

                      final bookUpdate = userChangedTitle ||
                          userChangedAuthor ||
                          userChangedRating ||
                          userChangedPhotoUrl ||
                          userChangedNotes;
                      if (bookUpdate) {
                        _bookCollectionReference
                            .doc(widget.book.id)
                            .update(Book(
                              userId: FirebaseAuth.instance.currentUser.uid,
                              title: _titleTextController.text,
                              author: _authorTextController.text,
                              photoUrl: _photoTextController.text,
                              rating: _rating ?? widget.book.rating,
                              startedReading: isReadingClicked
                                  ? Timestamp.now()
                                  : widget.book.startedReading,
                              finishedReading: isFinishedReadingClicked
                                  ? Timestamp.now()
                                  : widget.book.finishedReading,
                              notes: _notestTextController.text,
                            ).toMap());
                      }

                      Navigator.of(context).pop();
                    },
                  ),
                  TwoSidedRoundeButton(
                    text: 'Delete',
                    radius: 12,
                    color: Colors.red,
                    press: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Are you sure?'),
                            content: const Text(
                                'Once the book is deleted you can\'t retrieve it back.'),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    _bookCollectionReference
                                        .doc(widget.book.id)
                                        .delete();
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const MainScreenPage(),
                                        ));
                                  },
                                  child: const Text('Yes')),
                              TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('No'))
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
