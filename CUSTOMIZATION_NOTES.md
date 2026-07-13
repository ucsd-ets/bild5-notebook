# BILD 5 DataHub image — customization notes

Two things are set up in this repo: a fast **test-a-change loop** and a
**simplified RStudio layout** for students.

## 1. The build-and-deploy loop

Every push to this repo triggers `.github/workflows/docker.yml`, which builds the
image and pushes it to GHCR tagged by branch name
(`ghcr.io/ucsd-ets/bild5-notebook:main` for the `main` branch, `:wi25` for the
`wi25` branch). A nightly cron rebuild also runs at 02:00 UTC.

The course is confirmed to pull the `:main` tag, which this repo builds on every
push to `main`. Because `:main` is a mutable tag, your changes flow into the
student environment automatically — no ETS ticket needed to move a pin. That
removes the biggest uncertainty.

One variable remains, and it's on the Kubernetes side, not this repo:

- **The node has to re-pull the image.** Kubernetes can serve a cached copy of a
  mutable tag. A student's *already-running* server won't change under them; the
  image only refreshes when the server is fully stopped and started again (and
  the node pulls the new `:main`). In practice this means changes land the next
  time a student starts a fresh server, not mid-session.

The sentinel below tells you definitively whether a given push has reached the
environment, so you're never guessing about caching.

## 2. How to run a test (the sentinel)

The Dockerfile writes a marker file at `/opt/bild5/BUILD_INFO.txt`. It lives
outside `/home/jovyan`, so the persistent home mount can't hide it.

To test a change:

1. In the `Dockerfile`, bump the version: `ARG BILD5_BUILD=test-1` -> `test-2`.
2. Commit and push to the branch your course uses.
3. Watch the **Actions** tab until the build is green.
4. In DataHub, fully **stop and restart** your RStudio server (Control Panel ->
   Stop My Server -> Start). A restart is what forces a fresh image.
5. In RStudio open the **Terminal** tab and run:

   ```
   cat /opt/bild5/BUILD_INFO.txt
   ```

   If it shows `version: test-2`, your push reached the environment. If it still
   shows the old value after a full restart, the node is serving a cached image
   — give it a few minutes and restart once more. If it's still stale after
   repeated restarts, open a ticket with the ETS service desk referencing the
   image `ghcr.io/ucsd-ets/bild5-notebook:main` so they can confirm the pull
   policy on your course.

Once you've confirmed the loop works, you can delete or ignore the sentinel
block; it costs nothing to leave in.

## 3. The simplified RStudio layout

`rstudio-prefs.json` is copied to `/etc/rstudio/rstudio-prefs.json`, which
RStudio Server reads as the **system-wide default** for every user. It's a
default, not a lock: a student can still open Global Options and rearrange
things, and any student who has already customized their own settings keeps
theirs (their `~/.config/rstudio` wins over the system default).

What it does:

- **Source editor** stays the large top-left pane.
- **Files, Plots, Viewer, Help** are grouped as tabs in a single right-hand pane
  (`tabSet2`). The other tab set (`tabSet1`) is left empty so that pane collapses
  and the output pane fills the right column.
- **Environment, History, Connections, Build, VCS, Tutorial, Packages,
  Presentation** are moved to `hiddenTabSet` to cut clutter.
- **Console** sits tucked at the bottom-left, reachable but out of the way.
- **`.qmd` files open in Visual (WYSIWYG) mode by default** — the closest thing
  to a notebook feel. Code chunks run inline.
- Workspace save/restore prompts are turned off so students aren't nagged.

### Tuning it

Because the test loop above is fast, the intended workflow is: push, restart,
look, adjust. A few easy tweaks in `rstudio-prefs.json`:

- Want a tab visible again? Move its name from `hiddenTabSet` into `tabSet2`.
- Want the console even more out of the way? RStudio can't pre-minimize a pane
  from this file, but with `tabSet1` empty the layout is already close to three
  panes.
- The full list of valid preference keys is in RStudio's docs
  (`Custom Settings` / `Pane Layout`).

### One caveat worth knowing

RStudio is a four-pane IDE at heart; it can't be reduced to a literal two-pane
app. This config gets as close as the software allows: a prominent editor, one
combined output/files pane, and a de-emphasized console. If that still feels too
busy for intro students, the more radical option is switching the course to a
Jupyter-based image (JupyterLab has a genuinely notebook-first UI), but that
would change the `.qmd`/Quarto-in-RStudio workflow you described.
