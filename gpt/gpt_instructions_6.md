Given below is the full implementation of an app written in Flutter and a backend written as a Lambda Function.

I'd like you to make a bunch of changes to improve the user interface.

If anything is unclear or you need more context the please ask before proceeding.

I'd like you to procedure the full content of the files you modify or add.


### Coach tag

In the bottom of the coach tab I'd like to add a button "View participant history" below a horizontal ruler.

This button should be fixed this location.
If there are may session listed in the above section then the scrolling through those sessions should not affect the location of this button.

Clicking the "View participant history" should bring you to an entirely new screen
with information fetched from the backend using the new action `coach_get_historical_participation`
(add a new matching in `api_service.dart` for this).

Note that end_date should be included. So end date + 1 day needs to be send as "end_time" to the backend.

Id like participation history screen to look similar to what I've outlined below.
The matrix should only include dates that pass the week day filtering
and it should only include users that have joined at least one of the filtered dates.

+-------------------------------------------------------------------------------+
|                                                                               |
|  <start date> [calendar icon]   <end date> [calendar icon]   <submit button>  |
|                                                                               |
|  Filtering:                                                                   |
|  Week days: Mon[X] Tue[X] Wed[X] Thu[X] Fri[X] Sat[X] Sun[X]                  |
|                                                                               |
|                       Participation matrix                                    |
|                                                                               |
|                   <names written vertically >                                 |
|                                                                               |
|                                                                               |
|  Mon 2024-10-07      X     X  X                                               |
|  Tue 2024-10-08   X        X                                                  |
|  Thu 2024-10-10         X  X  X                                               |
|  Mon 2024-10-14            X  X                                               |
|  Tue 2024-10-15   X        X                                                  |
|  Thu 2024-10-17            X  X                                               |
|  Mon 2024-10-21      X     X  X                                               |
|  Tue 2024-10-22   X        X                                                  |
|  Thu 2024-10-24            X  X     X                                         |
|  Mon 2024-10-28            X  X                                               |
|  Tue 2024-10-29   X        X                                                  |
|  Thu 2024-10-31            X  X     X                                         |
|  Mon 2024-11-04      X     X  X                                               |
|  ---------------------------------------------------------------------------  |
|  Total           10  7  3 29 15  1  4                                         |
+-------------------------------------------------------------------------------+

