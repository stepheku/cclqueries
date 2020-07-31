"""
sync_file_docstrings_to_readme.py
~~~~~~~~~~~~~~~~~~~~
This module goes through each query's docstring and adds it to the
folder's README.md file
"""

import os
import os.path
import glob

def check_path_for_sub_dir(path: str) -> list:
    return [os.path.join(path, x) for x in os.listdir(path)
            if os.path.isdir(os.path.join(parent_path, x)) and x[0] != '.']

def check_path_for_sql_files(path: str) -> list:
    return [os.path.join(path, x) for x in os.listdir(path)
            if x.split('.')[-1] == 'sql']


def readme_contents_section_exists(path: str) -> bool:
    """
    Given a README.md path, checks to see if there is a Contents section
    """
    try:
        with open(path, 'r') as f:
            return '## Contents' in f.read()
    except FileNotFoundError:
        return False


def del_readme_contents_section(path: str) -> bool:
    """
    Given a README.md path, deletes a Contents section
    """
    contents_section_start_idx = 0
    contents_section_end_idx = 0

    with open(path, 'r') as f:
        lines = f.readlines()

    for idx, line in enumerate(lines):
        if '## Contents' in line:
            contents_section_start_idx = idx

        if contents_section_start_idx < idx and line[0] == '#':
            contents_section_end_idx = idx 
            break
        elif contents_section_start_idx < idx and idx == len(lines) - 1:
            contents_section_end_idx = idx 
            break

    with open(path, 'w') as f:
        for idx, line in enumerate(lines):
            if contents_section_end_idx:
                if idx < contents_section_start_idx or \
                    idx > contents_section_end_idx:
                    f.write(line)


def get_sql_docstring(path: str) -> str:
    docstring = ''
    start_doc_line = 0
    comment_block_end_line = 0

    with open(path, 'r') as f:
        lines = f.read().splitlines()
    for idx, line in enumerate(lines):
        if '/*' in line:
            comment_block_start_line = idx
        elif '~~~~~' in line:
            start_doc_line = idx
        elif '*/' in line:
            comment_block_end_line = idx
            break
    for idx, line in enumerate(lines):
        if idx > start_doc_line and idx < comment_block_end_line:
            docstring += line.strip() + ' '

    return docstring


def sync_file_docstrings_to_readme(folders: list):
    for folder in folders:
        readme_path = os.path.join(folder, 'README.md')

        if check_path_for_sql_files(folder):
            if readme_contents_section_exists(readme_path):
                del_readme_contents_section(readme_path)

            with open(readme_path, 'a') as f:

                f.write('## Contents\n')

                for sql_file in check_path_for_sql_files(folder):
                    try:
                        basename = os.path.basename(sql_file)
                        f.write('* [{}]({}): {}\n'.format(
                            basename, os.path.join('.', basename),
                            get_sql_docstring(sql_file)))
                    except Exception as e:
                        print('{}: {}'.format(sql_file, e))

        sub_paths = [folder for folder in glob.glob(os.path.join(folder, '*'))
                     if os.path.isdir(folder)]
        
        if sub_paths:
            sync_file_docstrings_to_readme(sub_paths)

if __name__ == "__main__":
    dir_path = os.path.dirname(os.path.realpath(__file__))
    parent_path = os.path.dirname(dir_path)
    subfolders = [folder for folder in glob.glob(os.path.join(parent_path, '*'), 
                  recursive=True) if os.path.isdir(folder)]
    sync_file_docstrings_to_readme(subfolders)