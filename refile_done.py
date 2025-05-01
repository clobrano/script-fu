#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# vi: set ft=python :
from shutil import move
import argparse

def refile_done_tasks(input_file, output_file):
    tasks_to_keep = 0
    tasks_to_archive = 0
    in_done = False

    with open(input_file, 'r') as f:
        lines = f.readlines()

    with open('/tmp/readitlater.org', 'w') as to_keep, open(output_file, 'a') as to_archive:
        for line in lines:
            if len(line) == 0:
                continue

            if line.lstrip().startswith("* TODO"):
                in_done = False
                tasks_to_keep += 1

            if line.lstrip().startswith("* DONE"):
                in_done = True
                tasks_to_archive += 1

            if in_done:
                to_archive.write(line)
            else:
                to_keep.write(line)

    move('/tmp/readitlater.org', input_file)
    print(f"Refiling completed.")
    print(f" {tasks_to_keep} Task(s) left in {input_file}.")
    print(f" {tasks_to_archive} Task(s) moved in {output_file}.")


def main():
    parser = argparse.ArgumentParser(description='Refile DONE tasks from an Orgmode file to another file.')
    parser.add_argument('input_file', type=str, help='orgmode source file.')
    parser.add_argument('output_file', type=str, help='orgmode destination file.')

    args = parser.parse_args()

    refile_done_tasks(args.input_file, args.output_file)

if __name__ == "__main__":
    main()

