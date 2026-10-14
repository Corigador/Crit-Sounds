from pathlib import Path

sounds = Path(__file__).parent / "Sounds"
output = sounds.parent / "SoundPacks.lua"

lines = ["CritSoundsPacks = {"]

for folder in sorted(sounds.iterdir()):
    if folder.is_dir():
        name = folder.name
        lines.append(f'    ["{name}"] = {{')

        for file in sorted(folder.rglob("*")):
            if file.is_file() and file.suffix.lower() in (".mp3", ".ogg", ".wav"):
                path = file.relative_to(sounds.parent).as_posix()
                lines.append(f'        "{path}",')

        lines.append("    },")

lines.append("}")

output.write_text("\n".join(lines) + "\n", encoding="utf-8")
print(f"Generated {output}")