fkeywords_to_delete=(
)

if [[ $FIRMWARE_TAG == *"NOWIFI"* ]]; then
     fkeywords_to_delete+=("wpad")
     fkeywords_to_delete+=("hostapd")
fi

for line in "${fkeywords_to_delete[@]}"; do
    sed -i "/$line/d" ./.config
done
