# App Store Screenshot Guide for TaskFlow Pro

Complete guide for creating compelling screenshots for Google Play Store and Apple App Store listings.

## Why Screenshots Matter

- 📊 **90% of users** look at screenshots before downloading
- ⬆️ **Good screenshots = 25% higher conversion** rate
- 🎯 **First 2-3 screenshots** are most important
- 📱 **Show don't tell** - demonstrate features visually

---

## Quick Requirements

| Platform | Minimum Required | Recommended | Max File Size |
|----------|-----------------|-------------|---------------|
| **Google Play** | 2 screenshots | 8 screenshots | 8 MB each |
| **Apple App Store** | 1 set (3 sizes) | 2 sets + iPad | 8 MB each |

---

## Google Play Store Requirements

### Required Sizes

| Device Type | Size | Aspect Ratio |
|-------------|------|--------------|
| **Phone** (Required) | 1080x1920 to 1080x2340 | 16:9 to 19.5:9 |
| **7" Tablet** (Optional) | 1200x1920 | - |
| **10" Tablet** (Optional) | 1600x2560 | - |

**Recommended for TaskFlow Pro:** 1080x2340 (modern phones)

### Google Play Guidelines
- ✅ **Format**: PNG or JPEG
- ✅ **24-bit color** (no alpha channel)
- ✅ **Minimum**: 2 screenshots
- ✅ **Maximum**: 8 screenshots
- ✅ **Portrait or landscape** (portrait recommended for our app)
- ✅ **File size**: Up to 8 MB each
- ❌ **No** text-heavy images
- ❌ **No** low-resolution or pixelated images

---

## Apple App Store Requirements

### Required Screenshot Sets

**iPhone (Required - Choose ONE):**

| Device | Size | Notes |
|--------|------|-------|
| **iPhone 15 Pro Max** | 1290x2796 | Recommended |
| **iPhone 14 Pro Max** | 1290x2796 | Same as above |
| **iPhone 13 Pro Max** | 1284x2778 | Acceptable |
| **iPhone 11 Pro Max** | 1242x2688 | Minimum |

**iPhone (Alternative - Choose ONE):**
| Device | Size | Notes |
|--------|------|-------|
| **iPhone 8 Plus** | 1242x2208 | 5.5" display |

**iPad Pro (Recommended but optional):**
| Device | Size | Notes |
|--------|------|-------|
| **iPad Pro 12.9"** | 2048x2732 | Best for iPad |
| **iPad Pro 11"** | 1668x2388 | Alternative |

### Apple Guidelines
- ✅ **Format**: PNG, JPEG, or TIFF
- ✅ **RGB color space**
- ✅ **Minimum**: 3-10 screenshots per device
- ✅ **Maximum**: 10 screenshots per device
- ✅ **File size**: Up to 8 MB each
- ✅ **Status bar** can be hidden or shown
- ❌ **No** misleading features
- ❌ **No** competitor mentions

---

## Screenshot Strategy for TaskFlow Pro

### Recommended Order (Most Important First)

**Screenshot 1: Hero/Dashboard** ⭐
- Show the main dashboard with modern design
- Display prayer times and today's tasks
- Highlight the clean, professional UI
- **Message**: "Beautiful, prayer-aware productivity"

**Screenshot 2: Task Management**
- Show the agenda/task list with filters
- Demonstrate swipe gestures (visual indicators)
- Show completed and pending tasks
- **Message**: "Powerful task management"

**Screenshot 3: AI Assistant**
- Display AI chat with task suggestions
- Show natural language input
- Highlight smart scheduling
- **Message**: "AI-powered productivity assistant"

**Screenshot 4: Prayer Times Integration**
- Show prayer schedule screen
- Display task scheduling relative to prayers
- Highlight location-based accuracy
- **Message**: "Schedule around your prayers"

**Screenshot 5: Timeline View**
- Display the daily timeline with prayer blocks
- Show how tasks fit between prayers
- Visual time management
- **Message**: "Visualize your perfect day"

**Screenshot 6: Spaces/Projects** (Optional)
- Show project organization
- Display hierarchical spaces
- Demonstrate bulk operations
- **Message**: "Organize your world"

**Screenshot 7: Voice Input** (Optional - Android only)
- Show voice recording interface
- Display transcribed task
- Highlight hands-free productivity
- **Message**: "Just speak, we'll organize"

**Screenshot 8: Settings/Customization** (Optional)
- Show theme options
- Display notification settings
- Highlight user control
- **Message**: "Make it yours"

---

## Screenshot Design Best Practices

### Visual Elements

**1. Device Frames** (Recommended)
- Use realistic device mockups
- Makes screenshots more professional
- Tools: Rotato, Mockuphone, Previewed.app
- Shows app in context

**2. Captions/Text Overlays**
- ✅ **Do**: Short, benefit-focused headlines (5-7 words)
- ✅ **Do**: Use brand colors (#2563EB, #F97316)
- ✅ **Do**: Keep text readable (min 24pt)
- ❌ **Don't**: Overcrowd with text
- ❌ **Don't**: Cover important UI elements

**3. Background**
- Option A: Gradient background (our brand colors)
- Option B: Solid color with subtle pattern
- Option C: Pure white/light gray (clean, minimal)
- Keep consistent across all screenshots

**4. Annotations**
- Use arrows or circles to highlight key features
- Keep annotations minimal and tasteful
- Use brand colors for consistency
- Remove for actual app UI screenshots if clean look preferred

### Design Template Structure

```
┌────────────────────────────────┐
│     [App Name/Logo]            │ <- Top section (optional)
│                                 │
│   ┌────────────────────────┐  │
│   │                         │  │
│   │    Device Frame         │  │ <- Main screenshot area
│   │    (Actual App UI)      │  │    Most important!
│   │                         │  │
│   └────────────────────────┘  │
│                                 │
│  "Short, compelling headline"  │ <- Caption (benefit-focused)
│     about this feature          │
│                                 │
└────────────────────────────────┘
```

---

## How to Capture Screenshots

### Method 1: Emulator/Simulator (Easiest)

**iOS (Xcode Simulator):**
```bash
# Run app in simulator
flutter run

# In Simulator:
# 1. Command + S to save screenshot
# 2. Saved to Desktop by default
# 3. Choose device: iPhone 15 Pro Max

# Or specific device:
flutter run -d "iPhone 15 Pro Max"
```

**Android (Emulator):**
```bash
# Run app in emulator
flutter run

# In Emulator:
# 1. Click camera icon on toolbar
# 2. Or Ctrl + S (Windows) / Cmd + S (Mac)
# 3. Saved to ~/Pictures/Android

# Create specific device:
# Android Studio > AVD Manager > Create Virtual Device
# Choose: Pixel 8 Pro (1080x2340)
```

### Method 2: Real Device (Most Accurate)

**iOS Device:**
```
1. Connect iPhone via USB
2. flutter run -d [device-id]
3. Take screenshot: Volume Up + Side Button
4. Screenshots in Photos app
5. AirDrop to Mac or use iCloud Photos
```

**Android Device:**
```
1. Enable Developer Mode
2. Enable USB Debugging
3. flutter run -d [device-id]
4. Take screenshot: Power + Volume Down
5. Transfer via USB or Google Photos
```

### Method 3: Screenshot Tools (Most Professional)

**Automated Screenshot Tools:**
- **Fastlane Snapshot** (iOS) - Automated screenshots
- **Screengrab** (Android) - Automated screenshots
- **flutter_driver** - Custom screenshot automation

---

## Post-Processing & Enhancement

### Tools for Editing

**Professional:**
- **Adobe Photoshop** - Industry standard
- **Figma** - Free, collaborative
- **Sketch** - Mac only, popular

**Quick & Easy:**
- **Canva** - Free templates
- **Previewed.app** - Device mockups
- **Rotato** - 3D device mockups
- **Mockuphone** - Free mockups

### Enhancement Steps

**1. Clean Up UI:**
```
- Remove test data
- Use realistic task names
- Set realistic dates/times
- Show varied priorities
- Display meaningful content
```

**2. Add Device Frame:**
```
- Use Rotato or Previewed
- Choose iPhone/Android device
- Add subtle shadow
- Keep device color neutral (black/white)
```

**3. Add Text Overlay:**
```
- Headline: 32-48pt, bold
- Subtext: 18-24pt, regular
- Use Montserrat or SF Pro fonts
- Align to grid
```

**4. Export:**
```
- Format: PNG (best quality)
- Resolution: Original size (don't upscale)
- Color profile: sRGB
- Compression: Minimal
```

---

## Screenshot Content Guidelines

### DO Include:
- ✅ **Real features** that actually work
- ✅ **Beautiful, modern UI** showing design system
- ✅ **Diverse content** (various task types, priorities)
- ✅ **Benefit-focused captions** (what user gains)
- ✅ **Brand colors** consistently
- ✅ **Prayer times** (core feature)
- ✅ **Localization** (if targeting multiple markets)

### DON'T Include:
- ❌ **Personal information** (real names, emails, phone numbers)
- ❌ **Placeholder text** ("Lorem ipsum", "Test task")
- ❌ **Error messages** or bugs
- ❌ **Competitor logos** or names
- ❌ **Misleading features** not in app
- ❌ **Outdated UI** (use latest version)
- ❌ **System UI issues** (low battery, notifications)

---

## Localization Strategy

If targeting multiple countries:

### Priority Markets for TaskFlow Pro:
1. **English** (US, UK, Australia) - Primary
2. **Arabic** (UAE, Saudi Arabia, Egypt) - High priority
3. **Urdu** (Pakistan, India) - High priority
4. **Indonesian** (Indonesia) - Large Muslim population
5. **Turkish** (Turkey) - Growing market

### Localized Screenshots:
- Translate caption text
- Use RTL layouts for Arabic
- Adapt prayer times to local conventions
- Consider cultural sensitivities

---

## Testing Your Screenshots

### Pre-Submission Checklist

**Technical Validation:**
- [ ] Correct dimensions for platform
- [ ] File size under 8 MB
- [ ] PNG or JPEG format
- [ ] No alpha transparency (if required)
- [ ] sRGB color profile
- [ ] All screenshots load correctly

**Content Validation:**
- [ ] No personal information visible
- [ ] UI is current app version
- [ ] Text is readable at thumbnail size
- [ ] Captions are accurate
- [ ] Features shown actually exist
- [ ] Brand colors are consistent
- [ ] No typos or errors

**A/B Testing:**
- [ ] Test different caption variations
- [ ] Try with and without device frames
- [ ] Compare different feature orders
- [ ] Monitor conversion rates after launch

---

## Screenshot Templates

### Template 1: Minimalist
```
- Pure white background
- No device frame
- Floating app UI screenshot
- Small caption at bottom
- Clean, Apple-style
```

### Template 2: Device Frame
```
- Subtle gradient background
- Realistic device mockup
- App UI in device
- Caption overlay on background
- Professional, polished
```

### Template 3: Feature Highlight
```
- Colored background (brand colors)
- Large headline at top
- App UI screenshot below
- Feature bullets or icons
- Marketing-focused
```

### Template 4: Side-by-Side
```
- Two phone mockups
- Before/After comparison
- Problem vs Solution
- Great for onboarding/tutorial
- Storytelling approach
```

**Recommended for TaskFlow Pro:** Template 2 (Device Frame) - Professional and trustworthy

---

## Tools & Resources

### Free Tools
- **Figma** - Design tool with templates
- **Canva** - Quick mockups
- **Screely** - Fast device mockups
- **MockUPhone** - Free device frames

### Paid Tools (Worth It)
- **Rotato** - $29, 3D mockups
- **Previewed** - $15/mo, professional mockups
- **PlaceIt** - $15/mo, tons of templates
- **AppLaunchpad** - $49, complete kit

### Template Marketplaces
- **Creative Market** - App Store templates
- **Envato Elements** - Subscription access
- **UI8** - Modern templates
- **Figma Community** - Free templates

---

## Example Captions (TaskFlow Pro)

### Screenshot 1 (Dashboard):
```
"Beautiful productivity meets prayer times"
"Stay organized while honoring your faith"
```

### Screenshot 2 (Tasks):
```
"Manage tasks with powerful filters & search"
"Swipe to complete, organize, and achieve"
```

### Screenshot 3 (AI Assistant):
```
"Your AI-powered productivity companion"
"Just type or speak - AI handles the rest"
```

### Screenshot 4 (Prayer Times):
```
"Never miss a prayer, stay productive too"
"Accurate prayer times for anywhere on Earth"
```

### Screenshot 5 (Timeline):
```
"Visualize your perfect day"
"Schedule around what matters most"
```

---

## Common Mistakes to Avoid

### Design Mistakes:
- ❌ Too much text (keep it concise!)
- ❌ Unreadable fonts (min 24pt)
- ❌ Inconsistent styling across screenshots
- ❌ Poor color contrast
- ❌ Cluttered composition

### Content Mistakes:
- ❌ Showing bugs or errors
- ❌ Test data visible ("Test Task 123")
- ❌ Wrong language for target market
- ❌ Features that don't exist yet
- ❌ Competitor screenshots

### Technical Mistakes:
- ❌ Wrong dimensions (rejected by store)
- ❌ Low resolution/pixelated
- ❌ File size too large (>8MB)
- ❌ Wrong color space (non-sRGB)
- ❌ Transparency when not allowed

---

## After Submission

### Monitor Performance:
- **Google Play Console**: Conversion rate metrics
- **App Store Connect**: Impressions → Downloads
- **A/B Testing**: Change screenshots every 2-3 months
- **User Feedback**: Read reviews for improvement ideas

### Iterate:
- Update screenshots with new features
- Test different messaging
- Add seasonal variations (Ramadan special, etc.)
- Localize for new markets

---

## Next Steps

1. ✅ Capture raw screenshots from app
2. ✅ Add device frames (optional but recommended)
3. ✅ Create caption text (keep it short!)
4. ✅ Edit in Figma/Photoshop
5. ✅ Export in correct sizes
6. ✅ Validate dimensions and file sizes
7. ✅ Prepare for store submission

---

**Pro Tip**: Keep source files (PSD, Figma, Sketch) for easy updates when you add new features or redesign!

Good luck with your screenshots! 📸
