# `delete-duplicate-files`

Deletes all files in a folder that match the given hashes.

This will use a file hash you choose in order to delete any files in a folder you choose which have that
same hash.

> **This version of this command ONLY uses UTF-8 encoded SHA-512 hashes!**

## Usage
(chopped down for readability)
```man
delete-matching-files
    [--hash <hash>]
    [--hash-file-name <hash-file-name>]
    [--output-volume <output-volume>]
    <folder-path>
```


## Arguments
- `<folder-path>` – The path to the folder which this will clean. This is required to ensure you understand that files in this folder will be deleted.


## Options
- `--hash <hash>` – A hash which will be used instead of the hash file. If excluded, the hash file will be used
- `--hash-file-name <hash-file-name>` – Overides the default hash file name
- `--output-volume <output-volume>` – The volume (amount) of output you want from this command (default: unix)
- `--version` – Show the version.
- `--help` – Show help information.


## Providing hashes to this utility
By default, the name of the file which contains the designated hash(es) is `delete-files-matching-hashes.txt`.

You may choose a different file with the `--hash-file-name` option.
You may also provide a hash without using a file at all by using the `--hash` option.

Providing both of those options at the same time is not defined behavior.
