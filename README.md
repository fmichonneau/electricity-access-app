# Develop in Positron, publish to Posit Connect

Exercises for the hands-on session. You'll take one small Shiny app from your editor to a production app on Posit Connect: run it, add a feature with Posit Assistant, publish a prototype, deploy it from Git, share it, and switch its data from a file to a pin.

| What | Where |
| --- | --- |
| Posit Workbench | `https://<workbench-url>` |
| Posit Connect | `https://<connect-url>` |
| This repository | `https://github.com/<org>/<repository>` |
| The pin | `francois/electricity_access` |

## How the session works

- Each part starts with a short demo, followed by an exercise with a timer.
- No exercise needs the one before it. If you're stuck or out of time, move on to the next exercise with everyone else. `solutions/` holds a working version of each change.
- Post questions in the Teams chat.
- You don't commit or push today: you have no credentials for this repository. You'll do everything up to the commit, and the instructor commits and pushes on screen.

## Exercise 1: Explore the data and run the app (7 min)

1. On Workbench, start a new **Positron Pro** session.
2. Clone this repository. Open the Command Palette (`F1`, or `Ctrl+Shift+P`), run **Workspaces: New Folder from Git...**, paste the repository URL, and pick your home folder. Positron opens the cloned folder.
3. In the Explorer, open `electricity-app/electricity-access.csv`. It opens in the Data Explorer. In which year did more than half of the population of Sub-Saharan Africa first have access to electricity?
4. Open `electricity-app/app.R` and click **Run Shiny App**, the play icon at the top right of the editor. The app opens in the Viewer.
5. Change the region the app shows when it starts (`selected = "Sub-Saharan Africa"`), save, and run the app again.

If the clone fails, open the copy already in your home folder: **File** > **Open Folder** > `workshop-copy`.

## Exercise 2: Add a feature with Posit Assistant (7 min)

1. Open Posit Assistant: Command Palette > **View: Show Posit Assistant**.
2. Pick one request and ask for it:
   - "Add a slider that limits the chart in electricity-app/app.R to a range of years."
   - "Show the latest value for the selected region above the chart."
   - "Let me pick a second region to compare."
3. Read the change before you keep it.
4. Run the app and try your feature.
5. Open the Source Control view (the branch icon in the Activity Bar, or `Ctrl+Shift+G`) and click `app.R` to see everything that changed.

If the app stops with "there is no package called ...", ask the Assistant to use base R instead.

If the app breaks: in the Source Control view, right-click `app.R` > **Discard Changes**. Or use the reference version, in the R console:

```r
file.copy("solutions/02-assistant/app.R", "electricity-app/app.R", overwrite = TRUE)
```

## Exercise 3: Publish a prototype with Posit Publisher (6 min)

At the Bank, publishing with the button is for prototypes. Production content comes from Git (exercise 4).

1. Click the Posit Publisher icon in the Activity Bar, then **Add Deployment**.
2. Entrypoint: `electricity-app/app.R`. If it isn't listed, click **Open...** and pick it.
3. Title: "Electricity access prototype (your name)".
4. Create a credential: enter the Connect URL and sign in when the browser opens. Nickname: `training`.
5. Click **Deploy Your Project**. When it finishes, open the app on Connect.
6. On Connect, open **Settings** > **Access**. Who can see your prototype?

If Publisher fails, skip this exercise. Nothing later uses it.

## Exercise 4: Deploy from Git (9 min)

1. On Connect, click **Publish** > **Import from Git**.
2. Repository URL: this repository. Branch: `main`. Directory: `electricity-app`. Title: "Electricity access (your name)". Deploy, and go back to Positron while it builds.
3. In Positron, open the Source Control view. Your changes from exercise 2 are listed; click `app.R` to see the diff. At the Bank, you'd commit and push them now.
4. Watch the instructor commit a change on a branch, then merge it into `main` with a pull request. Connect follows `main`, so the change reaches your app only once it's merged.
5. On Connect, open your app's **Settings** > **Source** and click **Update Now**. Reload the app: it has a year slider and a new title. Without the click, Connect would pick up the change within 15 minutes.
6. In **Settings** > **Source**, click **View all bundles**: one version per deployment. Select the first one and click **Activate**, then reload the app. Activate the latest one again.

## Exercise 5: Share your app (7 min)

Use your app from exercise 4.

1. **Settings** > **Access**: choose **Specific users or groups** and add the group `wb-workshop` as viewers.
2. Add the instructor as a collaborator.
3. **Settings** > **General** > **Custom URL**: `/firstname-lastname-electricity/`, for example `/jane-doe-electricity/`. Use only letters, digits, hyphens, and underscores.
4. In the Connect content list, open a classmate's app.
5. Open the link the instructor posts in the chat, to an app that isn't shared with you, and request access.

No app of your own? Steps 4 and 5 still work.

## Exercise 6: Read the data from a pin (9 min)

The CSV inside the app stops at 2022. The pin on Connect is kept up to date.

1. On Connect, click your picture at the top right > **Manage Your API Keys** > **New API Key**. Name it `workbench`. If Connect asks for a role, choose **Viewer**: reading a pin needs nothing more. Copy the key.
2. In the R console, open your personal environment file:

   ```r
   file.edit("~/.Renviron")
   ```

   Add these two lines, then save. The file lives in your home folder, outside the project, so the key can't end up in Git.

   ```bash
   CONNECT_SERVER=https://<connect-url>
   CONNECT_API_KEY=paste-your-key-here
   ```

3. Restart R (the circular arrow at the top of the Console, or `Ctrl+Shift+0`), then read the pin:

   ```r
   access <- pins::pin_read(pins::board_connect(), "francois/electricity_access")
   range(access$year)
   ```

4. In `electricity-app/app.R`, replace

   ```r
   access <- read.csv("electricity-access.csv")
   ```

   with

   ```r
   library(pins)
   board <- board_connect()
   access <- pin_read(board, "francois/electricity_access")
   ```

   Run the app: 2023 appears. If your slider from exercise 2 has its end year typed in, such as `max = 2022`, change it to `max(access$year)`.
5. Delete `electricity-app/electricity-access.csv`, then refresh the manifest, because the app now uses a new package:

   ```r
   rsconnect::writeManifest("electricity-app")
   ```

   In the Source Control view, `manifest.json` now lists pins and its dependencies, and the CSV shows as deleted.
6. Wait for the instructor to push the same change on screen. Then click **Update Now** on your app from exercise 4: it now reads the pin.
7. The instructor adds 2024 to the pin. Open your app in a new tab: 2024 is there, with no redeploy.

No API key working? Skip to step 6.

## After today

- Git-backed content on Connect: <https://docs.posit.co/connect/user/git-backed/>
- The manifest: <https://docs.posit.co/connect/user/manifest/>
- Publishing from Positron: <https://docs.posit.co/connect/user/publishing-positron-vscode/>
- Sharing and access settings: <https://docs.posit.co/connect/user/content-settings/>
- Pins on Connect: <https://docs.posit.co/connect/user/pins/>
- Posit Assistant: <https://positron.posit.co/assistant.html>
