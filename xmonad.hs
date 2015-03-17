--
-- An example, simple ~/.xmonad/xmonad.hs file.
-- It overrides a few basic settings, reusing all the other defaults.
--

import XMonad

import System.Exit
import XMonad.Layout.ResizableTile
import XMonad.Layout.WindowNavigation
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.SetWMName
import XMonad.Layout.NoBorders
import XMonad.Hooks.ManageHelpers
import XMonad.Layout.SubLayouts
import XMonad.Layout.BoringWindows
import XMonad.Layout.Tabbed
import XMonad.Layout.Simplest
import XMonad.Util.Themes
import XMonad.Layout.Gaps
import XMonad.Layout.Spacing

import qualified XMonad.StackSet as W
import qualified Data.Map        as M

myNormalBorderColor  = "#1a1a1a"
myFocusedBorderColor = "#33ccff"

myTabTheme = theme wfarrTheme

gapWidth = 5

myLayouts = boringWindows $
    smartBorders $
    avoidStruts $
    (enableTabs rtall ||| tabbed' ||| noBorders Full)
  where
    tabbed' = tabbed shrinkText myTabTheme
    rtall = spacing gapWidth $ gaps [(U, gapWidth),(D,gapWidth),(L,gapWidth),(R,gapWidth)] $
            configurableNavigation noNavigateBorders $ ResizableTall 1 (3/100) (1/2) []
    enableTabs x = addTabs shrinkText myTabTheme $ subLayout [] Simplest x

myWorkspaces = ["1:vim", "2:xterm", show 3, "4:docs", show 5, show 6,
                "7:www", "8:email", "9:irc", "10:misc"]

------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
--
myKeys conf@(XConfig {XMonad.modMask = modMask}) = M.fromList $
    -- launch a terminal
    [ ((modMask .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)
    -- launch dmenu
    , ((modMask,               xK_p     ), spawn "dmenu_run")
    -- close focused window
    , ((modMask .|. shiftMask, xK_c     ), kill)
     -- Rotate through the available layout algorithms
    , ((modMask,               xK_space ), sendMessage NextLayout)
    --  Reset the layouts on the current workspace to default
    , ((modMask .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)
    -- Resize viewed windows to the correct size
    , ((modMask,               xK_n     ), refresh)

    -- Move focus to the next window
    , ((modMask,               xK_Tab   ), windows W.focusDown)
    , ((modMask .|. shiftMask, xK_Tab   ), windows W.focusUp)

    -- Merge groups
    , ((modMask .|. mod1Mask, xK_h), sendMessage $ pullGroup L)
    , ((modMask .|. mod1Mask, xK_l), sendMessage $ pullGroup R)
    , ((modMask .|. mod1Mask, xK_k), sendMessage $ pullGroup U)
    , ((modMask .|. mod1Mask, xK_j), sendMessage $ pullGroup D)
    , ((modMask .|. mod1Mask, xK_m), withFocused (sendMessage . MergeAll))
    , ((modMask .|. mod1Mask, xK_u), withFocused (sendMessage . UnMerge))
    , ((modMask, xK_bracketleft), onGroup W.focusUp')
    , ((modMask, xK_bracketright), onGroup W.focusDown')

    -- vim move window bindingsbindings
    , ((modMask,               xK_j     ), sendMessage $ Go D)
    , ((modMask,               xK_k     ), sendMessage $ Go U)
    , ((modMask,               xK_l     ), sendMessage $ Go R)
    , ((modMask,               xK_h     ), sendMessage $ Go L)

    -- Move focus to the master window
    , ((modMask,               xK_m     ), windows W.focusMaster  )
    -- Swap the focused window and the master window
    , ((modMask,               xK_Return), windows W.swapMaster)

    -- Swap the stuff
    , ((modMask .|. shiftMask, xK_k     ), sendMessage $ Swap U)
    , ((modMask .|. shiftMask, xK_l     ), sendMessage $ Swap R)
    , ((modMask .|. shiftMask, xK_j     ), sendMessage $ Swap D)
    , ((modMask .|. shiftMask, xK_h     ), sendMessage $ Swap L)

    -- squashing and enlarging
    , ((modMask .|. controlMask, xK_h     ), sendMessage Shrink)
    , ((modMask .|. controlMask, xK_l     ), sendMessage Expand)
    , ((modMask .|. controlMask, xK_j     ), sendMessage MirrorShrink)
    , ((modMask .|. controlMask, xK_k     ), sendMessage MirrorExpand)

    -- Push window back into tiling
    , ((modMask,               xK_t     ), withFocused $ windows . W.sink)
    -- Increment the number of windows in the master area
    , ((modMask              , xK_comma ), sendMessage (IncMasterN 1))
    -- Deincrement the number of windows in the master area
    , ((modMask              , xK_period), sendMessage (IncMasterN (-1)))
    -- Quit xmonad
    , ((modMask .|. shiftMask, xK_q     ), io (exitWith ExitSuccess))
    -- Restart xmonad
    , ((modMask              , xK_q     ), restart "xmonad" True)
    -- Lock xscreensaver
    , ((modMask .|. controlMask, xK_x     ), spawn "xscreensaver-command -lock")
    ]
    ++

    --
    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    --
    [((m .|. modMask, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) ([xK_1 .. xK_9] ++ [xK_0])
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++

    --
    -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
    --
    [((m .|. modMask, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]

-- xmobar settings
myBar = "xmobar"
myPP = xmobarPP {
    ppCurrent = xmobarColor "#ff0066" "" . wrap "<" ">",
    ppVisible = xmobarColor "#ff00ff" "" . wrap "(" ")",
    ppTitle = xmobarColor "green" ""
}

-- Key binding to toggle the gap for the bar.
toggleStrutsKey XConfig {XMonad.modMask = modMask} = (modMask, xK_b)

main = xmonad =<< statusBar myBar myPP toggleStrutsKey defaults

defaults = defaultConfig {
   borderWidth        = 1,
   terminal           = "urxvt",
   normalBorderColor  = myNormalBorderColor,
   focusedBorderColor = myFocusedBorderColor,
   manageHook = manageDocks <+> manageHook defaultConfig,
   modMask = mod4Mask,
   keys = myKeys,
   layoutHook = myLayouts,
   startupHook = setWMName "LG3D",
   focusFollowsMouse = True,
   workspaces = myWorkspaces
}
