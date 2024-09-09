Given below is the full implementation of an app written in Flutter and a backend written as a Lambda Function.

Analyze it carefully.

I'd like you to make a few small updates:

* Currently, when you update a user in the update_user_screen.dart then the current
  username isn't being displayed. This has previously been working so it's most likely
  a bug introduced in connection with the data provider.
* The theory tab allows you to train the meaning of the Korean taekwondo commmands.
  I'd like you to extend this tab such that it can also train your active memory of
  the taekwondo commands given their description in Danish. That is; to go the other way.
  Rename the button "Start quiz" to "Træn skjult forklaring", keep the button "Træn" as is
  and introduce a new button "Træn skjult udtryk" for the new case where the Danish
  explanation is originally shown and you have to guess the matching taewondo command.
* I'd like you to change the link tab into a kind of about tab.
  The 3 links should be rearranged such that they're on the same link.
  Change their styling to make it more clear that they're actually links.
  Add a horizontal ruler below.
  Below the horizontal ruler add a title "dokumentation". This should be followed the an
  unfoldable section for each of the other visible tabs (i.e. depending on your user role).
  Please document the purpose and how to use each screen. Remember to add details such as
  the coach section only allows you to register the participation for a training session
  that will start within 10 minutes or already has started or ended.

If anything is unclear or you need more context the please ask before proceeding
- this is important! I've noticed that you proceed with a solution even though
I've sometimes forgot to add a file.

I'd like you to procedure the full content of the files you modify or add.
