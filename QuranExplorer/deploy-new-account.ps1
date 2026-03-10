# ═══════════════════════════════════════════════════════
# EXPLORING QURAN - QUICK DEPLOYMENT SCRIPT
# ═══════════════════════════════════════════════════════
# After creating your GitHub account, run this script to deploy the website

Write-Host "`n╔════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   EXPLORING QURAN - DEPLOYMENT SCRIPT    ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

Write-Host "This script will deploy your website to GitHub Pages.`n" -ForegroundColor Yellow

# Step 1: Verify we're in the right directory
$currentPath = Get-Location
Write-Host "📂 Current directory: $currentPath`n" -ForegroundColor White

if (-not (Test-Path "index.html")) {
    Write-Host "❌ ERROR: index.html not found!" -ForegroundColor Red
    Write-Host "Please navigate to the QuranExplorer folder first:" -ForegroundColor Yellow
    Write-Host 'cd "C:\Users\AmirShahzad\.azure\Users-and-Groups-Administration\QuranExplorer"' -ForegroundColor Cyan
    exit
}

Write-Host "✅ Found website files!`n" -ForegroundColor Green

# Step 2: Check Git
Write-Host "🔍 Checking Git installation..." -ForegroundColor Yellow
try {
    $gitVersion = git --version
    Write-Host "✅ $gitVersion`n" -ForegroundColor Green
} catch {
    Write-Host "❌ Git is not installed!" -ForegroundColor Red
    Write-Host "Please install Git from: https://git-scm.com/download/win" -ForegroundColor Yellow
    exit
}

# Step 3: Get GitHub username
Write-Host "═══════════════════════════════════════════════════════`n" -ForegroundColor Cyan
Write-Host "IMPORTANT: Make sure you have:" -ForegroundColor Yellow
Write-Host "  ✓ Created GitHub account with: ExploringQuran@gmail.com" -ForegroundColor White
Write-Host "  ✓ Created repository named: ExploringQuran" -ForegroundColor White
Write-Host "  ✓ Generated Personal Access Token from GitHub`n" -ForegroundColor White

$username = Read-Host "Enter your GitHub username (default: ExploringQuran)"
if ([string]::IsNullOrWhiteSpace($username)) {
    $username = "ExploringQuran"
}

$repoName = Read-Host "Enter repository name (default: ExploringQuran)"
if ([string]::IsNullOrWhiteSpace($repoName)) {
    $repoName = "ExploringQuran"
}

Write-Host "`n"

# Step 4: Initialize Git
Write-Host "📦 Initializing Git repository..." -ForegroundColor Yellow

if (Test-Path ".git") {
    Write-Host "⚠️  Git already initialized. Removing old .git folder..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force .git
}

git init
git config user.name "Exploring Quran"
git config user.email "ExploringQuran@gmail.com"

Write-Host "✅ Git initialized!`n" -ForegroundColor Green

# Step 5: Create .gitignore
Write-Host "📝 Creating .gitignore file..." -ForegroundColor Yellow
@"
# OS files
.DS_Store
Thumbs.db
desktop.ini

# Editor files
.vscode/
.idea/
*.swp
*.swo
*~

# Logs
*.log
npm-debug.log*

# Temporary files
*.tmp
*.bak

# Environment variables
.env
.env.local

# Dependencies
node_modules/
"@ | Out-File -FilePath ".gitignore" -Encoding UTF8

Write-Host "✅ .gitignore created!`n" -ForegroundColor Green

# Step 6: Stage and commit files
Write-Host "📋 Staging files..." -ForegroundColor Yellow
git add .

Write-Host "✅ Files staged!`n" -ForegroundColor Green

Write-Host "💾 Committing files..." -ForegroundColor Yellow
git commit -m "Initial commit - Exploring Quran website"

Write-Host "✅ Files committed!`n" -ForegroundColor Green

# Step 7: Set branch to main
Write-Host "🌿 Setting branch to main..." -ForegroundColor Yellow
git branch -M main

Write-Host "✅ Branch set to main!`n" -ForegroundColor Green

# Step 8: Add remote
$remoteUrl = "https://github.com/$username/$repoName.git"
Write-Host "🔗 Adding remote repository..." -ForegroundColor Yellow
Write-Host "   URL: $remoteUrl" -ForegroundColor Gray

git remote add origin $remoteUrl

Write-Host "✅ Remote added!`n" -ForegroundColor Green

# Step 9: Push to GitHub
Write-Host "═══════════════════════════════════════════════════════`n" -ForegroundColor Cyan
Write-Host "🚀 Ready to push to GitHub!`n" -ForegroundColor Green

Write-Host "AUTHENTICATION REQUIRED:" -ForegroundColor Yellow
Write-Host "  Username: $username" -ForegroundColor White
Write-Host "  Password: Use your Personal Access Token (NOT your password)`n" -ForegroundColor White

Write-Host "Haven't created a Personal Access Token yet?" -ForegroundColor Yellow
Write-Host "  1. Go to: https://github.com/settings/tokens" -ForegroundColor White
Write-Host "  2. Click: Generate new token (classic)" -ForegroundColor White
Write-Host "  3. Select: 'repo' scope" -ForegroundColor White
Write-Host "  4. Click: Generate token" -ForegroundColor White
Write-Host "  5. Copy the token (you won't see it again!)`n" -ForegroundColor White

$proceed = Read-Host "Do you have your Personal Access Token ready? (Y/N)"

if ($proceed -eq "Y" -or $proceed -eq "y") {
    Write-Host "`n🚀 Pushing to GitHub..." -ForegroundColor Yellow
    Write-Host "(You'll be prompted for username and token)`n" -ForegroundColor Gray
    
    git push -u origin main
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n╔════════════════════════════════════════════════════════╗" -ForegroundColor Green
        Write-Host "║              🎉 DEPLOYMENT SUCCESSFUL! 🎉              ║" -ForegroundColor Green
        Write-Host "╚════════════════════════════════════════════════════════╝`n" -ForegroundColor Green
        
        Write-Host "NEXT STEPS:`n" -ForegroundColor Yellow
        
        Write-Host "1️⃣  ENABLE GITHUB PAGES:" -ForegroundColor Cyan
        Write-Host "   • Go to: https://github.com/$username/$repoName/settings/pages" -ForegroundColor White
        Write-Host "   • Source: Deploy from a branch" -ForegroundColor White
        Write-Host "   • Branch: main" -ForegroundColor White
        Write-Host "   • Folder: / (root)" -ForegroundColor White
        Write-Host "   • Click 'Save'`n" -ForegroundColor White
        
        Write-Host "2️⃣  VIEW YOUR WEBSITE (wait 2-3 minutes):" -ForegroundColor Cyan
        Write-Host "   🌐 https://$username.github.io/$repoName/`n" -ForegroundColor Green
        
        Write-Host "3️⃣  CREATE YOUTUBE CHANNEL:" -ForegroundColor Cyan
        Write-Host "   • Follow the guide in COMPLETE_ACCOUNT_SETUP_GUIDE.md`n" -ForegroundColor White
        
        Write-Host "═══════════════════════════════════════════════════════`n" -ForegroundColor Cyan
        
        Write-Host "📚 Repository URL:" -ForegroundColor Yellow
        Write-Host "   https://github.com/$username/$repoName`n" -ForegroundColor White
        
        Write-Host "📖 Documentation:" -ForegroundColor Yellow
        Write-Host "   • README.md - Project overview" -ForegroundColor White
        Write-Host "   • COMPLETE_ACCOUNT_SETUP_GUIDE.md - Full setup guide" -ForegroundColor White
        Write-Host "   • GITHUB_PAGES_SETUP.md - GitHub Pages details`n" -ForegroundColor White
        
        Write-Host "May Allah bless your efforts! 🤲" -ForegroundColor Green
        Write-Host "`n═══════════════════════════════════════════════════════`n" -ForegroundColor Cyan
        
    } else {
        Write-Host "`n❌ Push failed!" -ForegroundColor Red
        Write-Host "`nCommon issues:" -ForegroundColor Yellow
        Write-Host "  1. Wrong username or token" -ForegroundColor White
        Write-Host "  2. Repository doesn't exist on GitHub" -ForegroundColor White
        Write-Host "  3. Network connection issues`n" -ForegroundColor White
        Write-Host "Please check and try again.`n" -ForegroundColor Yellow
    }
    
} else {
    Write-Host "`n⏸️  Deployment paused." -ForegroundColor Yellow
    Write-Host "`nCreate your Personal Access Token, then run:" -ForegroundColor White
    Write-Host "   git push -u origin main`n" -ForegroundColor Cyan
}

# Step 10: Show summary
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "QUICK REFERENCE" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════`n" -ForegroundColor Cyan

Write-Host "📧 Email: ExploringQuran@gmail.com" -ForegroundColor White
Write-Host "🐙 GitHub: https://github.com/$username" -ForegroundColor White
Write-Host "📁 Repository: https://github.com/$username/$repoName" -ForegroundColor White
Write-Host "🌐 Website: https://$username.github.io/$repoName/" -ForegroundColor White
Write-Host "📺 YouTube: https://youtube.com/@ExploringQuran`n" -ForegroundColor White

Write-Host "═══════════════════════════════════════════════════════`n" -ForegroundColor Cyan
