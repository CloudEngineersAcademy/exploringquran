# 🚀 Complete GitHub Pages Setup Guide

## Prerequisites

✅ Git installed on your computer  
✅ GitHub account ([signup here](https://github.com/signup))  
✅ QuranExplorer files ready  

---

## 🎯 Quick Start (3 Steps)

### **Step 1: Create GitHub Repository**

1. Go to **[github.com/new](https://github.com/new)**
2. Fill in:
   - **Repository name**: `quran-explorer`
   - **Description**: `Modern Quran Explorer - Read, Listen & Learn`
   - **Visibility**: **Public** ⚠️ (must be public for free GitHub Pages)
   - ✅ Initialize with README
3. Click **"Create repository"**

---

### **Step 2: Push Your Code**

Open PowerShell in the QuranExplorer folder and run:

```powershell
# Navigate to folder
cd "C:\Users\AmirShahzad\.azure\Users-and-Groups-Administration\QuranExplorer"

# Create .gitignore
@"
.DS_Store
Thumbs.db
.vscode/
.idea/
*.log
"@ | Out-File -FilePath ".gitignore" -Encoding UTF8

# Initialize Git
git init
git add .
git commit -m "Initial commit - Modern Quran Explorer"
git branch -M main

# Connect to GitHub (replace with YOUR repository URL)
git remote add origin https://github.com/SAmirShahzad/quran-explorer.git

# Push to GitHub
git push -u origin main
```

**Expected output:**
```
Enumerating objects: 8, done.
Counting objects: 100% (8/8), done.
...
To https://github.com/SAmirShahzad/quran-explorer.git
 * [new branch]      main -> main
```

---

### **Step 3: Enable GitHub Pages**

1. Go to your repository: `https://github.com/SAmirShahzad/quran-explorer`
2. Click **"Settings"** (top menu)
3. Click **"Pages"** (left sidebar)
4. Under **"Source"**:
   - Branch: Select **`main`**
   - Folder: Select **`/ (root)`**
5. Click **"Save"**

**Wait 1-2 minutes**, then visit:
```
🌐 https://SAmirShahzad.github.io/quran-explorer/
```

---

## 🎨 Alternative: Use GUI (GitHub Desktop)

### Option A: GitHub Desktop

1. **Download**: [desktop.github.com](https://desktop.github.com)
2. Install and sign in
3. Click **"Add"** → **"Create New Repository"**
4. Name: `quran-explorer`
5. Local Path: Browse to your QuranExplorer folder
6. Click **"Create Repository"**
7. Click **"Publish repository"**
8. Enable GitHub Pages (follow Step 3 above)

---

## 📝 Update Your Website (After Initial Setup)

Whenever you make changes to your website:

```powershell
cd "C:\Users\AmirShahzad\.azure\Users-and-Groups-Administration\QuranExplorer"

# Stage changes
git add .

# Commit with message
git commit -m "Update website - add new features"

# Push to GitHub
git push origin main
```

**Your website updates automatically** in 1-2 minutes! 🎉

---

## 🌐 Custom Domain (Optional)

Want `quranexplorer.com` instead of `SAmirShahzad.github.io/quran-explorer`?

### Step 1: Buy Domain
- [Namecheap](https://namecheap.com) (~$10/year)
- [GoDaddy](https://godaddy.com)
- [Google Domains](https://domains.google)

### Step 2: Add CNAME File
Create `CNAME` file in your repository:
```
quranexplorer.com
```

### Step 3: Configure DNS
In your domain registrar, add these records:

```
Type: A
Name: @
Value: 185.199.108.153

Type: A
Name: @
Value: 185.199.109.153

Type: A
Name: @
Value: 185.199.110.153

Type: A
Name: @
Value: 185.199.111.153

Type: CNAME
Name: www
Value: SAmirShahzad.github.io
```

Wait 24-48 hours for DNS propagation.

---

## ❓ FAQ

### **Q: Does GitHub Pages cost money?**
**A:** No! It's completely **FREE** for public repositories.

### **Q: What are the limitations?**
**A:** 
- Repository must be public (or GitHub Pro for private)
- 1 GB repository size limit
- 100 GB bandwidth/month (soft limit)
- Static websites only (no server-side code)

### **Q: Can I use a database?**
**A:** No backend databases. But you can:
- Use browser localStorage (for bookmarks, etc.)
- Call external APIs (like Al-Quran Cloud API)
- Use Firebase/Supabase for free backend

### **Q: How do I add Google Maps API key?**
**A:** Edit [`mosques.html`](./mosques.html) line ~1100:
```javascript
const GOOGLE_MAPS_API_KEY = 'YOUR_API_KEY_HERE';
```

### **Q: Can I password protect it?**
**A:** Not directly on GitHub Pages. Options:
- Use Netlify (has password protection)
- Use Cloudflare Access
- Build authentication with Firebase

### **Q: How do I delete the website?**
**A:** 
1. Go to Settings → Pages
2. Source: Select "None"
3. Or delete the entire repository

---

## 🎯 What About Dynamic Websites?

### **GitHub Pages = Static Only** ❌

**Cannot host:**
- Node.js/Express servers
- Python/Flask/Django backends
- PHP applications
- MySQL/PostgreSQL databases
- WebSocket servers

### **Alternatives for Dynamic Websites** ✅

| Platform | Free Tier | Backend Support | Database |
|----------|-----------|-----------------|----------|
| **Heroku** | Yes (limited) | Node, Python, Ruby, Java | PostgreSQL |
| **Railway** | $5/month free credit | All languages | PostgreSQL, MySQL |
| **Render** | Yes | Node, Python, Ruby, Go | PostgreSQL |
| **Azure Web Apps** | Free tier | .NET, Node, Python, Java | SQL Database |
| **Vercel** | Yes | Node.js, serverless | Via integrations |
| **Netlify** | Yes | Serverless functions | Via integrations |
| **AWS Amplify** | 12-month free | Full stack | DynamoDB |
| **Google Cloud Run** | Free tier | Containers | Cloud SQL |

### **Hybrid Approach (Best for Quran Explorer)**

Your Quran Explorer is **already optimized** for static hosting:
- ✅ **Frontend**: GitHub Pages (free)
- ✅ **Data**: Al-Quran Cloud API (free)
- ✅ **Audio**: CDN (free)
- ✅ **Maps**: Google Places API (free tier: 28,000 requests/month)

**No backend needed!** 🎉

---

## 🔧 Troubleshooting

### **Issue: 404 Error**
**Solution:** 
- Check GitHub Pages is enabled (Settings → Pages)
- Verify branch is set to `main`
- URL should be: `https://USERNAME.github.io/REPO-NAME/`

### **Issue: CSS Not Loading**
**Solution:** Check file paths are relative:
```html
<!-- Wrong -->
<link href="/styles.css">

<!-- Right -->
<link href="./styles.css">
<link href="styles.css">
```

### **Issue: Changes Not Showing**
**Solution:**
- Hard refresh: `Ctrl + Shift + R` (Windows) or `Cmd + Shift + R` (Mac)
- Wait 2-3 minutes for GitHub to rebuild
- Check commit was pushed: `git log --oneline`

### **Issue: Google Maps Not Working**
**Solution:**
- Get API key from Google Cloud Console
- Enable Places API and Maps JavaScript API
- Add billing info (required, but won't charge for free tier)
- Restrict API key to your domain

---

## 📊 Analytics (Optional)

### Add Google Analytics

1. Create property at [analytics.google.com](https://analytics.google.com)
2. Get Measurement ID (G-XXXXXXXXXX)
3. Add to `<head>` in both HTML files:

```html
<!-- Google Analytics -->
<script async src="https://www.googletagmanager.com/gtag/js?id=G-XXXXXXXXXX"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'G-XXXXXXXXXX');
</script>
```

---

## 🎉 Your Website is Live!

**Main Quran Reader:**
```
https://SAmirShahzad.github.io/quran-explorer/
```

**Mosque Directory:**
```
https://SAmirShahzad.github.io/quran-explorer/mosques.html
```

### Share on Social Media

```markdown
🕌 Check out Modern Quran Explorer - Beautiful Quran reader with:
✅ Multiple translations
✅ Audio recitation by famous reciters
✅ Mosque directory with prayer times
✅ Dark mode & bookmarks

https://SAmirShahzad.github.io/quran-explorer/

#Quran #Islam #Islamic #Muslims
```

---

## 📚 Next Steps

1. ✅ Deploy to GitHub Pages
2. ⬜ Get Google Maps API key
3. ⬜ Add Google Analytics
4. ⬜ Share on social media
5. ⬜ Get custom domain (optional)
6. ⬜ Add more features (see FEATURES.md)

---

## 🆘 Need Help?

- **GitHub Pages Docs**: [docs.github.com/pages](https://docs.github.com/pages)
- **Git Tutorial**: [git-scm.com/book](https://git-scm.com/book)
- **Issues**: Create issue on your repository

---

## 📞 Quick Reference Commands

```powershell
# Check status
git status

# Add files
git add .

# Commit
git commit -m "Your message"

# Push
git push origin main

# Pull latest
git pull origin main

# View history
git log --oneline

# Undo last commit (keep changes)
git reset --soft HEAD~1

# Discard all local changes
git reset --hard origin/main
```

---

**Made with ❤️ for the Muslim community**

*"The best of you are those who learn the Quran and teach it."* - Prophet Muhammad ﷺ
