#!/usr/bin/env python
import re
import argparse
from datetime import datetime, timedelta
from icalendar import Calendar, Event


def parse_remind_file(remind_file):
    """Parse remind file for events."""
    events = []
    with open(remind_file, "r") as file:
        for line in file:
            line = line.strip()
            # Match REM statement: REM [weekday(s)] AT [time] DURATION [duration] MSG [message]
            match = re.match(r"^REM\s+(.+?)\s+AT\s+(\d{1,2}:\d{2})\s+DURATION\s+(\d{1,2}:\d{2})\s+MSG\s+(.+)", line)
            if match:
                days_str, time_str, duration_str, message = match.groups()
                try:
                    # Handle multiple days, times, and durations
                    event_dates = parse_remind_dates(days_str, time_str, duration_str)
                    for event_date, event_duration in event_dates:
                        events.append((event_date, event_duration, message))
                except ValueError:
                    print(f"Could not parse date: {days_str}")
    return events


def parse_remind_dates(date_str, time_str, duration_str):
    """Convert REMIND date strings (with weekdays, times, and durations) into datetime objects."""
    # Handle multiple weekdays (e.g., "TUE FRI")
    weekdays = {
        "SUN": 6,
        "MON": 0,
        "TUE": 1,
        "WED": 2,
        "THU": 3,
        "FRI": 4,
        "SAT": 5,
    }
    days = date_str.upper().split()  # Split multiple days
    event_dates = []

    # Parse the given time (e.g., 6:00)
    try:
        event_time = datetime.strptime(time_str, "%H:%M").time()
    except ValueError:
        raise ValueError(f"Invalid time format: {time_str}")

    # Parse the given duration (e.g., 1:30 for 1 hour 30 minutes)
    try:
        event_duration = parse_duration(duration_str)
    except ValueError:
        raise ValueError(f"Invalid duration format: {duration_str}")

    for day in days:
        if day in weekdays:
            weekday_date = next_weekday(datetime.now(), weekdays[day])
            event_datetime = datetime.combine(weekday_date, event_time)
            event_dates.append((event_datetime, event_duration))
        else:
            print(f"Warning: Unrecognized day '{day}' in '{date_str}'")

    return event_dates


def parse_duration(duration_str):
    """Convert DURATION string (HH:MM) into a timedelta object."""
    try:
        hours, minutes = map(int, duration_str.split(":"))
        return timedelta(hours=hours, minutes=minutes)
    except ValueError:
        raise ValueError(f"Invalid duration format: {duration_str}")


def next_weekday(start_date, target_weekday):
    """
    Calculate the next occurrence of the target weekday.
    start_date: The starting date as a datetime object.
    target_weekday: The target weekday (0=Monday, 6=Sunday).
    """
    days_ahead = target_weekday - start_date.weekday()
    if days_ahead <= 0:  # Target day already passed this week
        days_ahead += 7
    return start_date + timedelta(days=days_ahead)


def convert_to_ics(events, output_file):
    """Convert events to ICS format."""
    cal = Calendar()
    cal.add("prodid", "-//Remind to ICS Converter//")
    cal.add("version", "2.0")

    for event_date, event_duration, message in events:
        event = Event()
        event.add("summary", message)
        event.add("dtstart", event_date)
        event.add("dtend", event_date + event_duration)  # Duration applied here
        event.add("dtstamp", datetime.now())
        cal.add_component(event)

    # Write to .ics file
    with open(output_file, "wb") as f:
        f.write(cal.to_ical())


def main(remind_file:str = "reminders.rem", output_file:str = "reminders.ics"):
    # Parse and convert
    events = parse_remind_file(remind_file)
    if not events:
        print("No events found in the remind file.")
        return

    convert_to_ics(events, output_file)
    print(f"ICS file created: {output_file}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(prog="rem2ics", description="Convert a remind file in ics format")
    parser.add_argument("-i", "--remind_file", default="reminders.rem", help="input reminder file path", required=False)
    parser.add_argument("-o", "--output_file", default="reminders.ics", help="output ics file path", required=False)
    args = parser.parse_args()
    main(args.remind_file, args.output_file)

