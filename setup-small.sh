#!/data/data/com.termux/files/usr/bin/bash

echo "Starting Termux Setup install software..."
# Server 
termux-change-repo
# update 
yes | pkg update && yes | pkg upgrade

# Install packages
yes | pkg install python ffmpeg git tmux wget unzip php fish nodejs net-tools nano deno -y
yes | pkg install tur-repo -y
yes | pkg install ollama -y
yes | pkg install jq -y
yes | pkg install iproute2 nmap -y 

# Install pip tools
pip install --upgrade pip
pip install flask yt-dlp pyftpdlib 
pip install -U yt-dlp
pip install -U mcstatus dnspython

# Fix fish config folder (important)
mkdir -p ~/.config/fish

# Set fish shell (safe)
chsh -s fish || echo "⚠️ Cannot change shell (ignore if error)"

# Fix PATH
grep -qxF 'set -U fish_user_paths $fish_user_paths $HOME' ~/.config/fish/config.fish || \
echo 'set -U fish_user_paths $fish_user_paths $HOME' >> ~/.config/fish/config.fish

# ---------------- VIDEO SCRIPT ----------------
cat > ~/video.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash

DOWNLOAD_FOLDER="/storage/emulated/0/Movies"
mkdir -p "$DOWNLOAD_FOLDER"

echo "🎬 Multi Video Downloader (CTRL+C to exit)"

while true; do
    read -p "Enter video URL: " url

    if [[ -z "$url" ]]; then
        echo "⚠️ No URL entered"
        continue
    fi

    echo "⬇️ Downloading $url ..."

    yt-dlp \
        -f "bestvideo[height<=720][ext=mp4][fps<=60]+bestaudio[ext=m4a]/mp4" \
        --merge-output-format mp4 \
        -S "vcodec:h264,lang,quality,res,fps,hdr:12,acodec:aac" \
        -o "$DOWNLOAD_FOLDER/%(title).80s.%(ext)s" \
        "$url" &

    echo "✅ Started!"
done
EOF

chmod +x ~/video.sh

# ---------------- AUDIO SCRIPT ----------------
cat > ~/song.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash

DOWNLOAD_FOLDER="/storage/emulated/0/Music"
mkdir -p "$DOWNLOAD_FOLDER"

echo "🎵 Multi Audio Downloader (CTRL+C to exit)"

while true; do
    read -p "Enter video URL: " url

    if [[ -z "$url" ]]; then
        echo "⚠️ No URL entered"
        continue
    fi

    echo "⬇️ Downloading audio..."

    yt-dlp -x \
        --audio-format mp3 \
        --audio-quality 256k \
        --embed-thumbnail \
        --add-metadata \
        -o "$DOWNLOAD_FOLDER/%(title).80s.%(ext)s" "$url" &

    echo "🎧 Started!"
done
EOF

chmod +x ~/song.sh

# ---------------- FTP SERVER ----------------
cat > ~/ftp.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash

cd /storage/emulated/0 || exit

echo "📡 FTP Server Running"
echo "Port: 2121"
echo "User: user | Password: 12345"

python -m pyftpdlib -p 2121 -u user -P 12345 -d /storage/emulated/0 -w
EOF
chmod +x ~/ftp.sh

## Movie and Song
cat > ~/mv.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash

# Folder
VIDEO_FOLDER="/storage/emulated/0/Movies"
AUDIO_FOLDER="/storage/emulated/0/Music"

mkdir -p "$VIDEO_FOLDER"
mkdir -p "$AUDIO_FOLDER"

clear
echo "=========================================="
echo "   🚀 Downloader MV (MP4 & MP3)"
echo "=========================================="

while true; do
    echo ""
    read -p "🔗 URL video (CTRL+C to exit): " url

    if [[ -z "$url" ]]; then
        echo "⚠️ Please enter a link!"
        continue
    fi

    echo "⏳ Downloading..."

    # 🎬 Video MP4
    yt-dlp \
        -f "bestvideo[height<=720][ext=mp4][fps<=60]+bestaudio[ext=m4a]/mp4" \
        --merge-output-format mp4 \
        -S "vcodec:h264,lang,quality,res,fps,hdr:12,acodec:aac" \
        -o "$VIDEO_FOLDER/%(title).80s.%(ext)s" \
        "$url" &

    # 🎧 Audio MP3
    yt-dlp -x \
        --audio-format mp3 \
        --audio-quality 256k \
        --embed-thumbnail \
        --add-metadata \
        -o "$AUDIO_FOLDER/%(title).80s.%(ext)s" \
        "$url" &

    echo "✅ Download started in background"
    echo "   🎬 Video -> $VIDEO_FOLDER"
    echo "   🎧 Audio -> $AUDIO_FOLDER"
done
EOF

chmod +x mv.sh

## Ai local Gemma 
cat > ~/ai.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash

# ==========================================
# 🤖 Local AI Launcher for Ollama
# 📱 Android + Termux
# ==========================================

clear

# Check Ollama
if ! command -v ollama &> /dev/null; then
    echo "❌ Ollama not installed!"
    echo "Install first:"
    echo "pkg install ollama"
    exit 1
fi

# Start Ollama Server
echo "🚀 Starting Ollama Server..."
ollama serve > /dev/null 2>&1 &

sleep 3

while true
do
    clear

    echo "=================================="
    echo " 🤖 LOCAL AI SELECT MENU"
    echo "=================================="
    echo ""
    echo "1. Qwen2.5 3B"
    echo "2. Gemma2 2B"
    echo "3. Phi4 Mini"
    echo "4. Llama3.2 3B"
    echo "5. Qwen2.5 Coder 1.5B"
    echo "6. Install All Models"
    echo "0. Exit"
    echo ""

    read -p "📌 Select AI: " choice

    case $choice in

        1)
            clear
            echo "🧠 Running Qwen2.5 3B..."
            ollama run qwen2.5:3b
            ;;

        2)
            clear
            echo "⚡ Running Gemma2 2B..."
            ollama run gemma2:2b
            ;;

        3)
            clear
            echo "🔥 Running Phi4 Mini..."
            ollama run phi4-mini
            ;;

        4)
            clear
            echo "🌐 Running Llama3.2 3B..."
            ollama run llama3.2:3b
            ;;

        5)
            clear
            echo "💻 Running Qwen2.5 Coder..."
            ollama run qwen2.5-coder:1.5b
            ;;

        6)
            clear
            echo "📦 Installing Models..."
            
            ollama pull qwen2.5:3b
            ollama pull gemma2:2b
            ollama pull phi4-mini
            ollama pull llama3.2:3b
            ollama pull qwen2.5-coder:1.5b

            echo ""
            echo "✅ All Models Installed!"
            read -p "Press Enter..."
            ;;

        0)
            echo "👋 Bye!"
            exit
            ;;

        *)
            echo "❌ Invalid choice!"
            sleep 2
            ;;
    esac
done
EOF

chmod +x ai.sh

##minecraft server check online use python 
curl -sLO https://raw.githubusercontent.com/Sochamroun/Termux-EasySetup/refs/heads/main/check-mc.py

# paper server install
curl -sLO https://raw.githubusercontent.com/Sochamroun/Termux-EasySetup/refs/heads/main/paper-server-setup.sh && chmod +x paper-server-setup.sh
## bot 
curl -sLO https://raw.githubusercontent.com/Sochamroun/Termux-EasySetup/refs/heads/main/bot-setup-free.sh && chmod +x bot-setup-free.sh
## hi
echo ""
echo "✅ Setup Complete!"
echo "--------------------------------"
echo "Commands (use this to run script files)"
echo "video.sh   → Download videos 🎬"
echo "song.sh    → Download audio 🎵"
echo "ftp.sh     → Start FTP server 📡"
echo "mv.sh      → Download video and song one time"
echo "ai.sh      → Ai Run Local"
echo "paper-server-setup.sh → PaperMc Server Install"
echo "bot-setup-free.sh → Install Bot Mc use Node JavaScript"
echo "check-mc.py Run → python check-mc.py"
