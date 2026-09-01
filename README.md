# Research Diary

A small LaTeX repository template for keeping a chronological research diary.

The diary is organized by month. A Bash function, `rd`, takes care of creating the current monthly file, adding today's entry if necessary, and opening it in Vim. The complete diary is compiled from `main.tex`.

## Repository structure

```text
research-diary/
├── main.tex
├── refs.bib
├── research-diary.sh
└── months/
    ├── 2026-09.tex
    ├── 2026-10.tex
    └── ...
```

- `main.tex` is the master LaTeX document. It contains the preamble, diary metadata, project list, custom commands, monthly `\include` statements, and bibliography.
- `refs.bib` is the BibLaTeX bibliography database used by the diary.
- `research-diary.sh` defines the `rd` Bash function.
- `months/` contains the diary itself, with one file per month. These files are created automatically by `rd`.

## Creating a diary from this template

Create a new repository from this template and clone it normally. The Bash script determines the repository location automatically, so the clone does not need to live at any particular path.

After cloning, edit the setup section near the beginning of `main.tex`:

```latex
% Replace these values when setting up the diary.
\newcommand{\DiaryAuthor}{[Author Name]}
\newcommand{\DiaryAcademicYear}{[Academic Year]}
\newcommand{\DiaryTitle}{[Diary Title]}
```

For example:

```latex
\newcommand{\DiaryAuthor}{Alice Example}
\newcommand{\DiaryAcademicYear}{2026--2027}
\newcommand{\DiaryTitle}{Research Diary}
```

You should also edit the **Current projects** list on the title page:

```latex
Current projects:
\begin{itemize}
  \item \ptag{p1}:~[Brief description of first project]
  \item \ptag{p2}:~[Brief description of second project]
  \item \ptag{p3}:~[Brief description of third project]
\end{itemize}
```

The tags (`p1`, `p2`, etc.) are meant to give short identifiers to projects that can then be reused throughout the diary with `\ptag{...}`. Add, remove, or rename projects as appropriate.

The rest of `main.tex` can normally be left unchanged. In particular, do **not** manually add monthly `\include` commands: `rd` manages them automatically below the marker

```latex
% Monthly files:
```

You may, of course, customize the LaTeX preamble, theorem environments, formatting, or diary commands if desired.

Add bibliography entries to `refs.bib` in the usual BibTeX/BibLaTeX format. The diary uses `biblatex` with `biber`.

## Enabling the `rd` command

`research-diary.sh` defines a Bash function rather than installing a standalone executable. Source it from your Bash configuration file.

For example, add the following line to `~/.bashrc`:

```bash
source "/path/to/research-diary/research-diary.sh"
```

Then reload the shell configuration:

```bash
source ~/.bashrc
```

After that, the command

```bash
rd
```

is available from any directory.

If you create several independent diaries from this template, source the script only for the diary whose `rd` function you want to use, or rename the function in each copy.

## Using `rd`

Run

```bash
rd
```

whenever you want to write in the diary.

Suppose the date is September 1, 2026. The function will:

1. determine the current month and date;
2. create `months/2026-09.tex` if it does not already exist, beginning with

   ```latex
   \chapter{September 2026}
   ```

3. make sure that `main.tex` contains

   ```latex
   \include{months/2026-09}
   ```

4. add today's entry to the monthly file if it has not already been created:

   ```latex
   \section*{\color{teal}2026-09-01 (Tuesday)}
   \phantomsection\label{day:2026-09-01}
   ```

5. open the monthly file in Vim at the end of the file, ready for editing.

Running `rd` more than once on the same day does not create duplicate month includes or duplicate daily headings.

Vim is opened with `months/` as its working directory. This is useful for Vim/LaTeX configurations that look for `main.tex` in the current directory or its parent directory. When Vim exits, your shell remains in the directory from which you originally ran `rd`.

## Writing diary entries

Write ordinary LaTeX directly below the current day's heading.

The template provides two small diary-specific commands.

### Project tags

Use

```latex
\ptag{p1}
```

to mark which project a note belongs to.

For example:

```latex
\ptag{p1}

Today I tried to prove...
```

### Topic changes

Use

```latex
\newtopic
```

to insert a visible separator when changing topics within the same day's entry.

### Linking to previous days

Every daily heading receives a label of the form

```latex
day:YYYY-MM-DD
```

so previous entries can be linked with `hyperref`. For example:

```latex
See \hyperref[day:2026-09-01]{the entry from September 1}.
```

The labels are intended as hyperlink targets rather than numbered `\ref`/`\cref` references.

## Compiling

Compile `main.tex`, not the individual monthly files.

Since the template uses BibLaTeX with the `biber` backend, a typical manual compilation sequence is

```bash
pdflatex main.tex
biber main
pdflatex main.tex
pdflatex main.tex
```

If your editor or Vim LaTeX setup already automates compilation and bibliography processing, use that instead.

## Notes

- Monthly files and daily headings are generated automatically; ordinary diary content is never overwritten by `rd`.
- The `% Monthly files:` marker in `main.tex` is used by the script to determine where new monthly `\include` statements belong. Do not remove it unless you also modify the script.
- The repository can be moved or cloned to a different location without changing `research-diary.sh`.
