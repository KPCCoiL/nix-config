{
  writeShellApplication,
  prefix ? "",
  choose-gui,
  rbw,
  ...
}:
writeShellApplication {
  name = prefix + "rbw";
  runtimeInputs = [
    choose-gui
    rbw
  ];
  text = ''
    function fakekey {
        echo "$1" | sed -E 's/(.)/\1\n/g' | while read -r key; do
            if [ "$key" = "" ]; then
                continue
            fi
            echo "fake-key \\$key" >> "$QUTE_FIFO"
        done
    }

    entry=$(rbw list | choose)
    fakekey "$(rbw get "$entry")"
  '';
}
