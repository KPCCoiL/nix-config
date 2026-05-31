{
  writeShellApplication,
  prefix ? "",
  ...
}:
writeShellApplication {
  name = prefix + "open-in-brave";
  text = ''
    open -a "Brave browser" "$QUTE_URL"
  '';
}
