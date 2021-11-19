{
  machine = {
    imports = [ ../profiles/graphical ];
  };

  enableOCR = true;

  testScript = ''
    machine.wait_for_unit("graphical.target")
    print("waiting for login screen")
    # hostname should be machine anyway
    machine.wait_for_text("Welcome to machine")

    print("logging in")
    # go back to the login field
    machine.send_key("shift-tab")
    machine.send_chars("epita")
    machine.screenshot("sddm")
    machine.send_chars("\n")
    print("logged in")

    print("waiting for i3 config prompts")
    # OCR is a bit dodgy with small text, we are actually looking for:
    # first configuration
    machine.wait_for_text("first corfiguraticr")
    machine.screenshot("i3configuration")
    machine.send_chars("\n")
    machine.wait_for_text("-> <Win>")
    machine.screenshot("i3meta")
    machine.send_chars("\n")

    print("opening terminal")
    machine.succeed("su - epita -c 'urxvt &'")
    machine.sleep(2)
    machine.send_chars("term_size 20\nwhoami\n")
    machine.wait_for_text("epita@machine")
    machine.screenshot("terminal")
  '';
}
