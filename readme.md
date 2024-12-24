merge daily notes
=================

having used obsidian on both my phone and laptop for over a year now, i got
tired of having 2 different files with different contents meant for the same
day, so i wrote a little script to merge them and append a symbol (°) to the
headings to indicate which come from my mobile vault.

i'm also including the template i use with the [periodic notes
plugin](https://github.com/liamcain/obsidian-periodic-notes), as an example of
what the script is looking for. if yours are formatted even a little bit
differently then it Probably won't work sorry. but feel free to modify the
script to suit your own needs


syntax
------

for merging 2 files:

```merge.rb path/to/file1.md path/to/file2.md```

for merging the contents of 2 directories (i.e., all matching file names /
paths):

```merge.rb -d path/to/folder1 path/to/folder2```

---

(**not yet implemented**) use a custom / no indicator for the appended
headings:

```merge.rb -h=SYMBOL file1.md file2.md```
