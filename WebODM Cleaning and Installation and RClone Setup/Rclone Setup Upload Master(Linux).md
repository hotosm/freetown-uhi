# ==========================================
# Rclone Setup & Upload Master Guide
# ==========================================

# 1. CREATE/OVERWRITE THE CONFIG (If needed)
rclone config create s3upload s3 provider AWS access_key_id AKIAZYDVV4ILH7CDNFXP secret_access_key YOUR_KEY region us-east-1

# 2. TEST THE CONNECTION (Targeted to your bucket)
rclone lsd s3upload:freetown-dtm-imagery-v2

# 3. CREATE THE PERMANENT SHORTCUT (Run once)
echo "alias uploadteam='_ut(){ rclone copy \"/home/salone2/Desktop/Waterloo Open Mapping/07-02-2026/Team \$1\" s3upload:freetown-dtm-imagery-v2/07-02-2026/\"Team \$1\" -P; }; _ut'" >> ~/.bashrc
source ~/.bashrc

# 4. HOW TO UPLOAD A TEAM (Daily Workflow)
# Replace '1' with your team number
uploadteam 1

# 5. VERIFY THE UPLOAD (Check for 100% accuracy)
# This compares your local folder to the cloud folder
rclone check "/home/salone2/Desktop/Waterloo Open Mapping/07-02-2026/Team 1" s3upload:freetown-dtm-imagery-v2/07-02-2026/"Team 1"

# 6. CHECK CLOUD STORAGE SIZE
rclone size s3upload:freetown-dtm-imagery-v2/07-02-2026
