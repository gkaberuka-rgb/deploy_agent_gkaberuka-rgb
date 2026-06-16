#!/bin/bash

# setup script for the attendance tracker project

read -p "Enter project name: " name

PROJECT_DIR="attendance_tracker_$name"

# trap to handle ctrl+c
handle_interrupt() {
    echo "Script interrupted! Saving current work..."
    cp -r $PROJECT_DIR attendance_tracker_${name}_archive
    rm -rf $PROJECT_DIR
    echo "Saved a copy to attendance_tracker_${name}_archive and cleaned up."
    exit 1
}

trap handle_interrupt SIGINT

# create the folders
echo "Creating project directories..."
mkdir $PROJECT_DIR
mkdir $PROJECT_DIR/Helpers
mkdir $PROJECT_DIR/reports

# create attendance_checker.py
cat > $PROJECT_DIR/attendance_checker.py << 'PYEOF'
import csv
import json
import os
from datetime import datetime

def run_attendance_check():
    # 1. Load Config
    with open('Helpers/config.json', 'r') as f:
        config = json.load(f)

    # 2. Archive old reports.log if it exists
    if os.path.exists('reports/reports.log'):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        os.rename('reports/reports.log', f'reports/reports_{timestamp}.log.archive')

    # 3. Process Data
    with open('Helpers/assets.csv', mode='r') as f, open('reports/reports.log', 'w') as log:
        reader = csv.DictReader(f)
        total_sessions = config['total_sessions']
        log.write(f"--- Attendance Report Run: {datetime.now()} ---\n")

        for row in reader:
            name = row['Names']
            email = row['Email']
            attended = int(row['Attendance Count'])

            attendance_pct = (attended / total_sessions) * 100
            message = ""

            if attendance_pct < config['thresholds']['failure']:
                message = f"URGENT: {name}, your attendance is {attendance_pct:.1f}%. You will fail this class."
            elif attendance_pct < config['thresholds']['warning']:
                message = f"WARNING: {name}, your attendance is {attendance_pct:.1f}%. Please be careful."

            if message:
                if config['run_mode'] == "live":
                    log.write(f"[{datetime.now()}] ALERT SENT TO {email}: {message}\n")
                    print(f"Logged alert for {name}")
                else:
                    print(f"[DRY RUN] Email to {email}: {message}")

if __name__ == "__main__":
    run_attendance_check()
PYEOF

echo "Created attendance_checker.py"

# create assets.csv
cat > $PROJECT_DIR/Helpers/assets.csv << 'CSVEOF'
Names,Email,Attendance Count
Alice Mwangi,alice.mwangi@school.ac.ke,28
Bob Kariuki,bob.kariuki@school.ac.ke,18
Carol Njeri,carol.njeri@school.ac.ke,12
David Ouma,david.ouma@school.ac.ke,35
Eve Achieng,eve.achieng@school.ac.ke,22
Frank Mutua,frank.mutua@school.ac.ke,8
CSVEOF

echo "Created Helpers/assets.csv"

# create config.json with default thresholds
cat > $PROJECT_DIR/Helpers/config.json << 'JSONEOF'
{
    "total_sessions": 40,
    "run_mode": "dry_run",
    "thresholds": {
        "warning": 75,
        "failure": 50
    }
}
JSONEOF

echo "Created Helpers/config.json"

# create an empty log file
echo "No reports yet. Run attendance_checker.py to generate one." > $PROJECT_DIR/reports/reports.log
echo "Created reports/reports.log"

# ask user if they want to change thresholds
echo ""
echo "Default thresholds are: warning=75%, failure=50%"
read -p "Do you want to change the thresholds? (y/n): " answer

if [ "$answer" = "y" ]; then
    read -p "Enter new warning threshold (e.g. 80): " warning_val
    read -p "Enter new failure threshold (e.g. 60): " failure_val

    sed -i "s/\"warning\": 75/\"warning\": $warning_val/" $PROJECT_DIR/Helpers/config.json
    sed -i "s/\"failure\": 50/\"failure\": $failure_val/" $PROJECT_DIR/Helpers/config.json

    echo "Thresholds updated in config.json"
fi

# health check
echo ""
echo "Running health check..."

python3 --version
if [ $? -eq 0 ]; then
    echo "python3 is installed, good to go."
else
    echo "Warning: python3 was not found. Please install it before running the app."
fi

if [ -f "$PROJECT_DIR/attendance_checker.py" ]; then
    echo "attendance_checker.py - OK"
fi
if [ -f "$PROJECT_DIR/Helpers/assets.csv" ]; then
    echo "Helpers/assets.csv - OK"
fi
if [ -f "$PROJECT_DIR/Helpers/config.json" ]; then
    echo "Helpers/config.json - OK"
fi
if [ -f "$PROJECT_DIR/reports/reports.log" ]; then
    echo "reports/reports.log - OK"
fi

echo ""
echo "Setup done! Your project is ready in $PROJECT_DIR"
echo "Run it with: cd $PROJECT_DIR && python3 attendance_checker.py"
