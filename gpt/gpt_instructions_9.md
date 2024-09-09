Given below is the full implementation of an app written in Flutter and a backend written as a Lambda Function.

Analyze it carefully.

I'd like you to make the necessary changes such that the unfolded sessions in both the participants tab and in the coach tab are remembered. Current, a state update resets the unfolded sessions to the default (with is; the first section is unfolded while the rest is not). The app should just remember forever which session ids should be unfolded and which should not be. However, if at any point this causes none of the shown sessions to be unfolded then I'd like to trigger the default behavior of showing the first session.

That is; the logic should be:
Unfold the last unfolded sessions (default to not unfold unseen sessions). If this causes no sessions to be unfolded then unfold the first session.

If anything is unclear or you need more context the please ask before proceeding.

I'd like you to procedure the full content of the files you modify or add.
