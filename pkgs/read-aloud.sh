# Reads the arguments, or stdin, aloud with Kokoro. Jargon is first swapped
# for how it sounds, using "term = spoken form" lines from $PRONUNCIATIONS.
text=${*:-$(cat)}
text=$(printf '%s' "$text" | perl -e '
  open my $f, "<", $ENV{PRONUNCIATIONS} or die;
  my @p = map { chomp; [split / = /, $_, 2] } <$f>;
  local $/; my $t = <STDIN>;
  $t =~ s/\Q$$_[0]\E/$$_[1]/g for @p;
  print $t;
')

wav=$(mktemp -d)/speech.wav
trap 'rm -rf "$(dirname "$wav")"' EXIT
sherpa-onnx-offline-tts \
  --num-threads=4 \
  --kokoro-model="$KOKORO/model.onnx" \
  --kokoro-voices="$KOKORO/voices.bin" \
  --kokoro-tokens="$KOKORO/tokens.txt" \
  --kokoro-data-dir="$KOKORO/espeak-ng-data" \
  --output-filename="$wav" \
  "$text" >/dev/null 2>&1
"$PLAYER" "$wav"
