{
  nodes.machine = {
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
    machine.wait_until_succeeds("DISPLAY=:0 XAUTHORITY=$(find /run/sddm -name 'xauth_*') xwininfo -root -tree | grep 'i3: first configuration'")
    machine.screenshot("i3configuration")
    machine.send_chars("\n")
    machine.sleep(1)
    machine.screenshot("i3meta")
    machine.send_chars("\n")

    print("opening terminal")
    machine.sleep(2)
    machine.send_key('meta_l-ret')
    machine.sleep(2)
    machine.send_chars("whoami\necho epita@machine\n")
    machine.wait_for_text("epita@machine")
    machine.screenshot("terminal")
  '';
}
