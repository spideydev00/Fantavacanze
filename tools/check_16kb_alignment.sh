#!/bin/bash
# Verifica che tutte le .so dentro un AAB/APK siano allineate a 16 KB.
# Uso: ./check_16kb_alignment.sh path/to/app.aab

set -e
INPUT="$1"
if [ -z "$INPUT" ]; then
  echo "Uso: $0 <app.aab|app.apk>"
  exit 1
fi

WORK=$(mktemp -d)
echo "📦 Estrazione di $INPUT in $WORK"
unzip -q "$INPUT" -d "$WORK"

NDK_HOME="${ANDROID_NDK_HOME:-$HOME/Library/Android/sdk/ndk/28.2.13676358}"
OBJDUMP="$NDK_HOME/toolchains/llvm/prebuilt/darwin-x86_64/bin/llvm-objdump"

if [ ! -x "$OBJDUMP" ]; then
  echo "⚠️   llvm-objdump non trovato in $OBJDUMP"
  echo "    Imposta ANDROID_NDK_HOME o aggiusta il path nello script."
  exit 1
fi

UNALIGNED=0
TOTAL=0
while IFS= read -r SO; do
  TOTAL=$((TOTAL + 1))
  ALIGN=$("$OBJDUMP" -p "$SO" \
    | awk '/LOAD/ {print $NF}' \
    | sort -u | head -1)
  # ALIGN e' in esadecimale tipo 2**14 = 0x4000 (16 KB)
  if [ "$ALIGN" != "2**14" ] && [ "$ALIGN" != "2**15" ] && [ "$ALIGN" != "2**16" ]; then
    echo "❌ NON ALLINEATA (16 KB): $SO  (align=$ALIGN)"
    UNALIGNED=$((UNALIGNED + 1))
  fi
done < <(find "$WORK" -name "*.so")

echo ""
echo "Totale .so: $TOTAL — non allineate: $UNALIGNED"

rm -rf "$WORK"

if [ "$UNALIGNED" -gt 0 ]; then
  exit 1
fi
echo "✅ Tutte le .so sono 16 KB-aligned."
