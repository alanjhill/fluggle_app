import 'package:fluggle_app/widgets/custom_app_bar.dart';
import 'package:fluggle_app/widgets/reusable_card.dart';
import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({Key? key}) : super(key: key);

  final List<String> _helps = const [
    'You need to be registered and logged-in to play or you can login as a guest. ',
    'If you are not registered and logged-in, you can only play in practice mode.',
    'Scores are not saved if you are playing as a guest.',
    'Once you are registered and logged-in, you can add friends and play multiplayer games.',
    'You can play a game of either one, two or three minutes length.',
    'Words must be at least three letters long.',
    'You can pause the game at any time.',
    'You can quit a game at any time.'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleText: 'Help',
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: SingleChildScrollView(
          child: ListView.separated(
            physics: const ScrollPhysics(),
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: _helps.length,
            itemBuilder: (context, index) {
              return ReusableCard(
                key: Key(_helps[index]),
                padding: 8.0,
                cardChild: ListTile(
                  visualDensity: VisualDensity.compact,
                  //leading: Icon(Icons.circle, size: 12.0, color: Colors.white),
                  title: Text(
                    _helps[index],
                    style: const TextStyle(fontSize: 16.0),
                  ),
                ),
              );
            },
            separatorBuilder: (BuildContext context, index) {
              return const SizedBox(height: 8.0);
            },
          ),
        ),
      ),
    );
  }
}
