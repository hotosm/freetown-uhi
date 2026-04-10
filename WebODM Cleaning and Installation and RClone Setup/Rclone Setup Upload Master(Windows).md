# ==========================================
# Rclone Setup & Upload Master Guide (Windows)
# ==========================================

# 1. CREATE THE CONFIG
# This creates the 's3upload' remote with your specific credentialsi
rclone config create s3upload s3 provider AWS access_key_id AKIAZYDVV4ILH7CDNFXP secret_access_key YOUR_KEY region us-east-1

# 2. TEST THE CONNECTION
# Lists the buckets to ensure the keys are working
rclone lsd s3upload:freetown-dtm-imagery-v2

# 3. DEFINE THE UPLOAD FUNCTION
# This replaces the Linux 'alias'. Run this once per session or add to $PROFILE
function uploadteam ($team) {
    $localPath = "D:\Waaterloo Open Mapping\18-02-2026\Team $team"
    $remotePath = "s3upload:freetown-dtm-imagery-v2/18-02-2026/Team $team"
    
    Write-Host "Starting upload for Team $team..." -ForegroundColor Cyan
    rclone copy $localPath $remotePath -P --fast-list --checksum --transfers 10
    
    Write-Host "Upload complete. Running verification check..." -ForegroundColor Yellow
    rclone check $localPath $remotePath --one-way
}

# 4. HOW TO USE (Run these as needed in your terminal)
# To upload Team 1:
# uploadteam 1

# To check the total size of the day's data on S3:
# rclone size s3upload:freetown-dtm-imagery-v2/18-02-2026
