# Deploy Quran Explorer to GitHub Pages
# Run this script to deploy your website

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  QURAN EXPLORER - GITHUB DEPLOYMENT" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Check if this is a new repo or existing
$choice = Read-Host "Deploy to (1) New dedicated repo or (2) Existing Users-and-Groups-Administration repo? Enter 1 or 2"

if ($choice -eq "1") {
    Write-Host "`n📦 Setting up new repository..." -ForegroundColor Yellow
    
    # Create .gitignore
    @"
# OS files
.DS_Store
Thumbs.db

# Editor files
.vscode/
.idea/

# Logs
*.log
"@ | Out-File -FilePath ".gitignore" -Encoding UTF8
    
    # Initialize new repo
    git init
    git add .
    git commit -m "Initial commit - Modern Quran Explorer"
    git branch -M main
    
    Write-Host "`n✅ Repository initialized!" -ForegroundColor Green
    Write-Host "`nNEXT STEPS:" -ForegroundColor Yellow
    Write-Host "1. Create repository on GitHub: https://github.com/new" -ForegroundColor White
    Write-Host "   Name it: quran-explorer" -ForegroundColor White
    Write-Host "   Make it PUBLIC (required for free GitHub Pages)" -ForegroundColor White
    Write-Host "`n2. Then run these commands:" -ForegroundColor White
    Write-Host "   git remote add origin https://github.com/SAmirShahzad/quran-explorer.git" -ForegroundColor Cyan
    Write-Host "   git push -u origin main" -ForegroundColor Cyan
    Write-Host "`n3. Enable GitHub Pages:" -ForegroundColor White
    Write-Host "   Go to: Settings → Pages → Source: main branch → Save" -ForegroundColor White
    Write-Host "`n4. Your site will be live at:" -ForegroundColor White
    Write-Host "   https://SAmirShahzad.github.io/quran-explorer" -ForegroundColor Green
    
} elseif ($choice -eq "2") {
    Write-Host "`n📦 Adding to existing repository..." -ForegroundColor Yellow
    
    # Go to parent directory
    cd ..
    
    # Add QuranExplorer files
    git add QuranExplorer/
    git commit -m "Add Quran Explorer website"
    git push origin main
    
    Write-Host "`n✅ Pushed to GitHub!" -ForegroundColor Green
    Write-Host "`nYour website will be accessible at:" -ForegroundColor Yellow
    Write-Host "https://SAmirShahzad.github.io/Users-and-Groups-Administration/QuranExplorer/" -ForegroundColor Green
    Write-Host "`nTo enable GitHub Pages:" -ForegroundColor Yellow
    Write-Host "1. Go to: https://github.com/SAmirShahzad/Users-and-Groups-Administration/settings/pages" -ForegroundColor White
    Write-Host "2. Source: Select 'main' branch" -ForegroundColor White
    Write-Host "3. Folder: Select '/ (root)'" -ForegroundColor White
    Write-Host "4. Click 'Save'" -ForegroundColor White
    
} else {
    Write-Host "`n❌ Invalid choice. Please run the script again." -ForegroundColor Red
}

Write-Host "`n========================================`n" -ForegroundColor Cyan
