# Taekwondo App

Note that the app is mostly in Danish.

I made this app after discussions in my local taekwondo club on how to easily track the participation of members. That is; to be able to answer the question "have X participated sufficiently to be allowed next graduation?"

Many similar apps exists. But those I have tried either have ads, are paid or are too complex to use because of all the unnecessary functionality.

If I had spent more time I probably would have found a useful app though. The primary reason for building the app was for me to get a bit experience with app building and seeing how much the o1-preview model can help you build something from scratch.

With my extensive Python experience I decided to build the API myself and leave just the Flutter app to the o1-preview model. The experiment succeeded; I made very little tweaking of the Flutter app myself and almost everything was produced by o1-preview. I basically had the role of a product owner and just had to state the requirements clearly to the o1-preview model. The [gpt directory](./gpt) contains the prompts I used (except for the first two that accidentally got deleted).


## Table of Contents

- [Test Setup](#test-setup)
- [Design Overview](#design-overview)
- [Features](#features)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
- [Usage](#usage)
  - [Login](#login)
  - [Home Screen](#home-screen)
  - [Participants Tab](#participants-tab)
  - [Coach Tab](#coach-tab)
  - [Admin Tab](#admin-tab)
  - [Theory Tab](#theory-tab)
  - [Links Tab](#links-tab)

## Test setup

A test setup is running at https://d3c06zdmscvvms.cloudfront.net/

You can test it by logging in (upper right corner) as one of the profiles below. Note that every hour at minute 0 the setup resets to a clean state and your changes will be gone.

* **Admin** Grandmaster ByteFist login code: `OhbVrpoi`
* **Coach** Black Belt Betty login code: `VgRV5IfL`
* **Student** Tornado Todd login code: `oCLrZ3aW`

## Design Overview

Technologies: Python, Flutter, Dart, Amazon S3, Amazon CloudFront, Amazon Lambda, Amazon EventBridge, OpenAI o1-preview model

The app frontend is hosted on Amazon S3 and accessible thought Amazon Cloudfront.
The Python backend is based on an Amazon Lambda plus a file hosted on Amazon S3.
The idea is to host the non-sensitive publicly available data from the file on S3 and thus avoiding the latency that coldstarting a Lambda function incurs.

Amazon EventBridge is used to call the reset test setup action once per hour.

I didn't find a good way to cheaply host a database instance. Given the very small deployment scale I chose to go with Amazon S3 as data storage. Race conditions are avoided by restricting the allowed concurrency of the Lambda function to 1. The resulting setup has a negligible cost in the order of a few dollars a year.

I did not set up a separate DNS entry for the app as I didn't find it important. New users will be emailed the URL and authentication/login code.

## Features

- **User Authentication**: Secure login using unique authentication tokens.
- **Role-Based Access**: Different functionalities for Participants, Coaches, and Administrators.
- **Training Session Management**: Create, update, and delete training sessions.
- **Participation Registration**: Register attendance for upcoming sessions.
- **Historical Participation Data**: View and analyze past participation records.
- **User Management**: Administrators can create, update, and delete users.
- **Theory Training**: Access taekwondo theory and practice with quizzes.
- **External Resources**: Quick links to the club's website and social media pages.

## Getting Started

### Prerequisites

- **Flutter SDK**: Ensure you have Flutter installed on your machine. You can download it from the [official website](https://flutter.dev/docs/get-started/install).
- **Dart SDK**: Comes bundled with Flutter.
- **IDE**: I used [Android Studio](https://developer.android.com/studio) with Flutter and Dart plugins installed for the app and [Visual Studio Code](https://code.visualstudio.com/) with Remote Development extensions for the backend.

## Usage

### Login

- **First-Time Users**: You will need a login code (authentication token) provided by an administrator.
- **Login Screen**: Enter your login code to access the app's features.

### Home Screen

- **Role Detection**: The app detects your role (Participant, Coach, Admin) and displays relevant tabs.
- **Tabs Available**:
  - Participants
  - Coach (if applicable)
  - Admin (if applicable)
  - Theory
  - Links

### Participants Tab

- **View Upcoming Sessions**: See a list of scheduled training sessions.
- **Register Participation**: Indicate your attendance status (Yes, No, Maybe).
- **Add Users**: Register on behalf of other users (e.g., family members).
- **Session Details**: Tap on a session to view more information.

### Coach Tab

- **Create Sessions**: Add new training sessions with details like time, coach, and comments.
- **Update Sessions**: Modify or delete upcoming sessions.
- **Register Attendance**: Record actual attendance for sessions that are about to start or have ended.
- **Participation History**: Access historical data of participant attendance.

### Admin Tab

- **User Management**: Create, update, or delete user accounts.
- **View Authentication Tokens**: Retrieve login codes for users.
- **Role Assignment**: Assign roles to users (Admin, Coach, Student).

### Theory Tab

- **Theory Training**: Access taekwondo theory material categorized by belt levels.
- **Quiz Modes**:
  - **Hidden Explanation**: Test your knowledge by recalling explanations.
  - **Training**: Review terms and explanations together.
  - **Hidden Term**: Recall terms based on explanations.

### Links Tab

- **External Resources**: Quick access to the club's website, Facebook group, and TikTok page.
- **Documentation**: Expandable sections with detailed guides for each tab.
