// Name: SAM_Agent625(on Twitch) or Alice
// Date: 07/08/2023
// Version: v0.5


// Updates v0.5
// - splits have been finished, there is one split towards the end that I'm not entirely certain
// -- where it triggers, but as long as the isGameLoaded variable works on other devices, this
// --- autosplitter is done
// - now onto the testing phase, good luck, speedrunners!

// Updates v0.4.1
// - isGameLoaded was tested and did not initially transfer over to my second computer
// -- However, I have already found a replacement value that also transfers over

// Updates v0.4
// - Splits have been added as well as a variable to determine if the game is loaded in or not
// - isGamePaused may not be an entirely stable variable either, further testing is required

// Updates v0.3.2
// - Found an isGameReady variable that seems to transfer from device to device, will send to Seth to test with his device

// Updates v0.3.1
// - isGameReady has been adjusted to a slightly more accessible value (this is hopefully a temporary fix until a consistent variable is found)
// - Timer will now only pause if the player pauses the game

// Updates v0.3
// - isGameReady has been fixed (hopefully)
// - isGamePaused has been added (this will replace the use of the inGameTimer to determine when the player has paused the game

// Current Issues:
// splits: it is currently unknown where the current objective is stored at, or where the list of characters to save/kill is stored at
// isGameReady will always be a pain in the butt


state("KillerFrequency")
{  
  // so far this value has been 0 when the character cannot be moved, and a value greater than zero when the character can be moved
  // The byte value is more consistent, but it seems restricted to at least only my main computer.
  // If the byte value fails, the long value can be used to replace it.
  // If the timer still will not start after the game is loaded, the solution to fix this is to close the game and reopen it.

  // long isGameReadyLong : "UnityPlayer.dll", 0x01AF27F0, 0x48, 0x8, 0x88, 0x3C;
  // byte isGameReadyByte : "GameAssembly.dll", 0x0323E9B0, 0x40, 0xB8, 0x8, 0x634;
  
  // isGameReady v2
  byte isGameReady : "GameAssembly.dll", 0x03241BB8, 0xB8, 0x68;
  
  // in game timer that updates only when the game is paused
  // will be left in for now, but has become obsolete
  float inGameTimer : "GameAssembly.dll", 0x0346C990, 0x210, 0x1D0, 0x20; 

  // separate value to determine if the game is paused or not
  byte isGamePaused : "GameAssembly.dll", 0x034525C0, 0x70, 0xCA0;
  
  // value to determine if the game is loaded or not
  byte isGameLoaded : "GameAssembly.dll", 0x03368A68, 0xB8, 0x30, 0x590;
}

init
{
  // separate value to count "checkpoints"
  vars.checkpointCounter = 0;
  vars.comparisonCounter = 0;
}

startup
{
  settings.Add("chap", true, "Killer Frequency");

  vars.Chapters = new Dictionary<string,string> 
  {
    {"01", "Clive's Death"},
    {"02", "Show Preparations"},
    {"03", "12:00 (Leslie and Sandra)"},
    {"04", "12:42 (Maurice)"},
    {"05", "Whistling Man Escape"},
    {"06", "01:04 (Forrest's Old Friend)"},
    {"07", "Back to Work (Virginia)"},
    {"08", "Party Time (Virginia and Eugene)"},
    {"09", "01:49 (Murphy)"},
    {"10", "Trash Compactor (Murphy and Teens)"},
    {"11", "Peggy Really Hates This Song"},
    {"12", "02:40 (Chuck)"},
    {"13", "03:00 (Roller Ricky and Jason)"},
    {"14", "Final Interview"},
  };
  foreach (var Tag in vars.Chapters)
  {
	settings.Add(Tag.Key, true, Tag.Value, "chap");
  };

  if (timer.CurrentTimingMethod == TimingMethod.RealTime) // stolen from dude simulator 3, basically asks the runner to set their livesplit to game time
  {        
    var timingMessage = MessageBox.Show
    (
            "This game uses Time without Loads (Game Time) as the main timing method.\n"+
            "LiveSplit is currently set to show Real Time (RTA).\n"+
            "Would you like to set the timing method to Game Time? This will make verification easier",
            "LiveSplit | Killer Frequency",
            MessageBoxButtons.YesNo,MessageBoxIcon.Question
    );
        
    if (timingMessage == DialogResult.Yes)
    {
      timer.CurrentTimingMethod = TimingMethod.GameTime;
    }
  }

  vars.SetTextComponent = (Action<string, string>)((id, text) =>
  {
    var textSettings = timer.Layout.Components.Where(x => x.GetType().Name == "TextComponent").Select(x => x.GetType().GetProperty("Settings").GetValue(x, null));
    var textSetting = textSettings.FirstOrDefault(x => (x.GetType().GetProperty("Text1").GetValue(x, null) as string) == id);
    if (textSetting == null)
    {
      var textComponentAssembly = Assembly.LoadFrom("Components\\LiveSplit.Text.dll");
      var textComponent = Activator.CreateInstance(textComponentAssembly.GetType("LiveSplit.UI.Components.TextComponent"), timer);
      timer.Layout.LayoutComponents.Add(new LiveSplit.UI.Components.LayoutComponent("LiveSplit.Text.dll", textComponent as LiveSplit.UI.Components.IComponent));

      textSetting = textComponent.GetType().GetProperty("Settings", BindingFlags.Instance | BindingFlags.Public).GetValue(textComponent, null);
      textSetting.GetType().GetProperty("Text1").SetValue(textSetting, id);
    }

    if (textSetting != null)
      textSetting.GetType().GetProperty("Text2").SetValue(textSetting, text);
  });
}

update
{
  if (current.isGameLoaded > old.isGameLoaded)
  {
    vars.checkpointCounter += 1;
  }
}

start
{
  if ((current.isGameReady == 1) && (current.isGamePaused == 0))
  {
    return true;
  }
}

onStart
{
  // separate value to count "checkpoints"
  vars.checkpointCounter = 0;
  vars.comparisonCounter = 0;
}

reset
{
  if ((old.inGameTimer > current.inGameTimer) && (current.inGameTimer == 0))
  {
    return true;
  }
  else
  {
    return false;
  }
}

onReset
{
  // separate value to count "checkpoints"
  vars.checkpointCounter = 0;
  vars.comparisonCounter = 0;
}

split
{
    if (old.isGameLoaded < current.isGameLoaded)
	{
	  return true;
	}
}

isLoading
{
  if (current.isGamePaused == 1)
  {
    return true;
  }
  else
  {
    return false;
  }
}
