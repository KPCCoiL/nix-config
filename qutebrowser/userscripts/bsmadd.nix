{
  writeShellApplication,
  prefix ? "",
  bsm,
}:
writeShellApplication {
  name = prefix + "bsmadd";
  runtimeInputs = [ bsm ];
  text = ''
    dlpath="$HOME/Downloads/a.pdf"
    pdfpath="$QUTE_URL"
    if [[ -e "$dlpath" ]]; then
      pdfpath="$dlpath"
    fi
    output=$(bsm -b "$QUTE_URL" "$pdfpath" 2>&1)
    echo "message-info '$output'" > "$QUTE_FIFO"
  '';
}
