#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# vi: set ft=python :
from pathlib import Path
import pytz
import argparse
from icalendar import Calendar
from datetime import datetime


def main(infile: str, outfile: str):
    # Load the ICS file
    ics_path = Path(infile)
    cal = Calendar.from_ical(ics_path.read_text())

    # Create a new calendar
    new_cal = Calendar()

    # Copy headers from the original calendar
    for key, value in cal.items():
        new_cal.add(key, value)

    # Dictionary to track the latest event per title
    events_by_uid = {}

    for component in cal.walk():
        if component.name == "VEVENT":
            uid = str(component.get("UID", "")).strip()
            last_modified = component.get("LAST-MODIFIED")

            # Convert LAST-MODIFIED to a comparable datetime object
            if last_modified:
                last_modified = last_modified.dt
                if isinstance(last_modified, datetime) and last_modified.tzinfo is None:
                    last_modified = last_modified.replace(tzinfo=pytz.UTC)
            else:
                last_modified = datetime.min.replace(tzinfo=pytz.UTC)  # Default to oldest if missing

            # Keep the latest version of an event based on UID and LAST-MODIFIED
            if uid not in events_by_uid or last_modified > events_by_uid[uid]["last_modified"]:
                events_by_uid[uid] = {"event": component, "last_modified": last_modified}

    # Add only the latest events to the new calendar
    for entry in events_by_uid.values():
        new_cal.add_component(entry["event"])


    # Save the filtered calendar
    with open(outfile, "wb") as f:
        f.write(new_cal.to_ical())

    print(f"Purged ICS file saved as {outfile}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(prog="myagenda-prune", description="Prune old events from ics file")
    parser.add_argument("-i", "--input", help="input ics file path")
    parser.add_argument("-o", "--output", help="output ics file path")
    args = parser.parse_args()
    main(args.input, args.output)
