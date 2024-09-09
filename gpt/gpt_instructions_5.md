Given below is the full implementation of an app written in Flutter and a backend written as a Lambda Function.

I'd like you to make a bunch of changes to improve the user interface.

If anything is unclear or you need more context the please ask before proceeding.

I'd like you to procedure the full content of the files you modify or add.
Also, remember to let me know if an existing file is no longer needed.

### The participants tab

The horizontal line between each session should be removed. It should still be shown below a session that has been expanded though (below the first section or below a section where one has clicked "See participation"). The "See participation" text should be replaced with "Details".

Change the listing such that both the time of the day, the "Coach: <name>" and the session comment is only shown for an expanded session.

The text for an unexpanded session should then be on the format "Tuesday 2024-10-29" while the additional text for an expanded session should be on the format shown below

```
Session is at 19:00 - 20:30 with Minik
<Extra line or lines with comment, no empty line if comment is empty>
Yes: Jesper Barrith
Maybe: 
No: Jesper TK, Minik
```


### The coach tab

In the "Add Training Session" tab I'd like to change how the start and end time is specified.
If possible, I prefer a 24 hour clock where you don't need to switch between am and pm.
For the choice of start time: If possible, I prefer that HH:MM is set to 19:00 by default after having chosen the date.
If the user first selects start time and end time has not yet been specified, then set end time to start time plus 1 1/2 hour.

The session listing should be changed to show the same information as on the participants page.
So here most information should also be hidden by default (expect for the first session) and be unfolded by clicking the "details" icon.

Add a filtering such that archived sessions older than half a day are not shown.

The "Register P." button should not be shown instead of the session state dropdown; it should be shown in addition to the session state dropdown - immediately before it.

I've updated the backend such that the action `coach_update_training_session` now recognized two different sets of arguments.
The new set of arguments is for updating a session without changing its state.
For a scheduled session where the button "Register P." is NOT shown (that is; a more future session) there should instead be a button with the text "Update". Clicking this button should bring you to a new screen similar to when you click "Add Training Session". When clicking "Update" or "Submit" (what you find most appropriate) this should trigger that `coach_update_training_session` is called with the new set of arguments - via a new function in `api_service.dart`


## The admin tab

The admin tab should be almost redone from scratch.

In the top there should still be the button "Create User" but it should no longer be stretched in size.

The two other buttons should be removed.

Below the "Create User" button there should be a listing of all users, sorted in alphabetic order according to name.

Each line should contain the user name, left aligned followed by 2 buttons: "Show login" and "Update". These buttons should be right aligned.

"Show login" behave like the old "Retrieve Auth Token" button.

"Update" should show a new screen similar to "Create User". This screen should also include a button for deleting the user.
When clicking this button the UI should ask for confirmation.

Note that the button "Update" requires a new method in `api_service.dart` to be added - calling the action `admin_update_user`.
