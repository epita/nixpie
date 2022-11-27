{
  nodes.machine = {
    imports = [ ../profiles/graphical ];
  };

  enableOCR = true;

  testScript = ''


    machine.wait_for_unit("graphical.target")
    machine.screenshot("sddm")
    print("waiting for login screen")
    # hostname should be machine anyway
    machine.wait_for_text("Welcome to machine")

    print("logging in")
    # go back to the login field
    machine.send_key("shift-tab")
    machine.send_chars("epita")
    machine.sleep(30)
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
    machine.sleep(30)
    print("i3 configured")

    print("open dmenu")
    machine.send_key('meta_l-d')
    # no visual queue (text to small)
    machine.sleep(30)
    machine.screenshot("dmenu")

    print("launch terminal ")
    machine.send_chars("i3-sensible-terminal\n")
    machine.wait_for_text("epita@machine")
    machine.screenshot("terminal")

    print("try run a command")
    machine.send_chars("whoami && pwd\n")
    machine.wait_for_text("/home/epita")
    machine.screenshot("commands")
  '';
}
