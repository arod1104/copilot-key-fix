#Requires AutoHotkey v2.0

; ==============================================
;  FIX ASUS: Remap Copilot key to RCtrl
;
;  The Copilot key sends LWin+LShift+F23 (~1ms between events).
;  We intercept LWin and LShift BEFORE they reach the OS.
;  If F23 appears within 30ms -> it's Copilot -> activate RCtrl.
;  If not -> real keys -> let them pass.
; ==============================================

#SingleInstance Force

global state := "idle"
global shiftSuppressed := false

; --- LWin: intercept and hold ---
$*LWin::{
    global state
    state := "waiting"
    SetTimer(PassKeys, -30)
}

$*LWin up::{
    global state, shiftSuppressed
    if state = "waiting" {
        SetTimer(PassKeys, 0)
        state := "idle"
        if shiftSuppressed {
            shiftSuppressed := false
            SendInput "{LWin down}{LShift down}{LWin up}"
        } else {
            SendInput "{LWin down}{LWin up}"
        }
    } else if state = "lwin_passed" {
        state := "idle"
        SendInput "{LWin up}"
    }
    ; "copilot" or "idle" -> ignore
}

; --- LShift: intercept only if waiting for F23 ---
$*LShift::{
    global state, shiftSuppressed
    if state = "waiting" {
        shiftSuppressed := true
    } else {
        shiftSuppressed := false
        SendInput "{LShift down}"
    }
}

$*LShift up::{
    global shiftSuppressed
    if shiftSuppressed {
        shiftSuppressed := false
    } else {
        SendInput "{LShift up}"
    }
}

; --- Timer: if 30ms pass without F23, these are real keys ---
PassKeys() {
    global state, shiftSuppressed
    if state = "waiting" {
        state := "lwin_passed"
        if shiftSuppressed {
            shiftSuppressed := false
            SendInput "{LWin down}{LShift down}"
        } else {
            SendInput "{LWin down}"
        }
    }
}

; --- F23 (SC06E) = Copilot key: activate RCtrl ---
$*SC06E::{
    global state, shiftSuppressed
    SetTimer(PassKeys, 0)
    state := "copilot"
    shiftSuppressed := false
    SendInput "{RCtrl down}"
}

$*SC06E up::{
    global state
    if state = "copilot" {
        state := "idle"
        SendInput "{RCtrl up}"
    }
}
