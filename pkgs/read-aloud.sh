# Reads the arguments, or stdin, aloud with Kokoro. Jargon is first swapped
# for how it sounds, using "term = spoken form" lines from $PRONUNCIATIONS.
# Each sentence plays while the next one is generated, so speech starts soon.
text=${*:-$(cat)}
sentences=$(printf '%s' "$text" | perl -e '
  open my $f, "<", $ENV{PRONUNCIATIONS} or die;
  my @p = map { chomp; [split / = /, $_, 2] } <$f>;
  local $/; my $t = <STDIN>;
  $t =~ s/\Q$$_[0]\E/$$_[1]/g for @p;
  # Markdown: keep link text, drop heading, quote, list and emphasis marks.
  $t =~ s/\[([^\]]*)\]\([^)]*\)/$1/g;
  $t =~ s/^[ \t]*(?:#+|>|[-*+]|\d+\.)[ \t]+//mg;
  $t =~ s/[*`~]//g;
  $t =~ s/_/ /g;
  $t =~ s/\|/, /g;
  # One sentence per line.
  $t =~ s/[ \t]+/ /g;
  $t =~ s/(?<=[.!?]) /\n/g;
  print $t;
')

dir=$(mktemp -d)
trap 'rm -rf "$dir"' EXIT
i=0
player=
while IFS= read -r sentence; do
  [ -n "${sentence// /}" ] || continue
  i=$((i + 1))
  sherpa-onnx-offline-tts \
    --num-threads=4 \
    --kokoro-model="$KOKORO/model.onnx" \
    --kokoro-voices="$KOKORO/voices.bin" \
    --kokoro-tokens="$KOKORO/tokens.txt" \
    --kokoro-data-dir="$KOKORO/espeak-ng-data" \
    --output-filename="$dir/$i.wav" \
    "$sentence" >/dev/null 2>&1
  [ -z "$player" ] || wait "$player"
  "$PLAYER" "$dir/$i.wav" &
  player=$!
done <<<"$sentences"
wait
