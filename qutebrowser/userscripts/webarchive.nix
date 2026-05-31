{
  writeShellApplication,
  prefix ? "",
  ...
}:
writeShellApplication {
  name = prefix + "webarchive";
  text = ''
    echo "open -t https://web.archive.org/web/$QUTE_URL" > "$QUTE_FIFO"
  '';
}
