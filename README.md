# Student Attendance Tracker — Project Factory

A shell script that sets up the workspace for a Student Attendance Tracker application.

## How to Run

1. Clone the repo and navigate into it
2. Give the script execute permission:
```
chmod +x setup_project.sh
```
3. Run it:
```
bash setup_project.sh
```
4. When prompted, enter a project name. The script will create a folder called `attendance_tracker_<name>`
5. The script will then ask if you want to update the default attendance thresholds (warning = 75%, failure = 50%)
6. Once setup is done, run the app with:
```
cd attendance_tracker_<name>
python3 attendance_checker.py
```

## How to Trigger the Archive Feature

While the script is still running, press **Ctrl+C**.

The script will catch the interrupt signal and:
- Copy the current project folder to a new folder called `attendance_tracker_<name>_archive`
- Delete the incomplete original folder
- Exit cleanly

This means even if you cancel mid-setup, your work is not lost.

## Project Structure Created

```
attendance_tracker_<name>/
├── attendance_checker.py
├── Helpers/
│   ├── assets.csv
│   └── config.json
└── reports/
    └── reports.log
```

## Requirements

- Bash
- Python 3
