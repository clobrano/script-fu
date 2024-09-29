#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# vi: set ft=python :
import argparse

def refile_done_tasks(input_file, output_file):
    with open(input_file, 'r') as f:
        lines = f.readlines()

    tasks_to_move = []
    current_task = []
    in_task = False

    for line in lines:
        if len(line) == 0:
            continue

        if line.startswith('*'):
            # New Item: if we were in a DONE section, archive it
            if in_task:
                tasks_to_move.append(''.join(current_task))

            in_task = False
            current_task = []

            if line.lstrip().startswith("* DONE"):
                # New DONE section
                in_task = True
                current_task.append(line)
        elif in_task:
            current_task.append(line)
        else:
            current_task = []

    # Adding Last DONE section, if any
    if in_task:
        tasks_to_move.append(''.join(current_task))

    # Archive selected tasks
    with open(output_file, 'a') as f:
        f.write('\n'.join(tasks_to_move))

    # Remove archived tasks
    with open(input_file, 'w') as f:
        f.write(''.join([line for line in lines if line not in ''.join(tasks_to_move)]))

    print(f"Refiling completed. {len(tasks_to_move)} Task(s) moved in {output_file}.")

def main():
    # Imposta argparse per gestire gli argomenti da riga di comando
    parser = argparse.ArgumentParser(description='Refile DONE tasks from an Orgmode file to another file.')
    parser.add_argument('input_file', type=str, help='orgmode source file.')
    parser.add_argument('output_file', type=str, help='orgmode destination file.')

    args = parser.parse_args()

    # Chiama la funzione di refiling con i file forniti dall'utente
    refile_done_tasks(args.input_file, args.output_file)

if __name__ == "__main__":
    main()

