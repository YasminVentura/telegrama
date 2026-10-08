const fs = require('fs');
const path = require('path');

const libDir = path.join(__dirname, 'lib');

const moveMap = {
  // core
  'themes/app_themes.dart': 'core/themes/app_themes.dart',
  
  // app/main
  'main.dart': 'main.dart',

  // features/auth
  'screens/auth/forget-password-screen.dart': 'features/auth/forget_password_screen.dart',
  'screens/auth/login.dart': 'features/auth/login_screen.dart',
  'screens/auth/sign-up.dart': 'features/auth/sign_up_screen.dart',
  'screens/auth/welcome.dart': 'features/auth/welcome_screen.dart',

  // features/chats
  'screens/chats/wave-chats.dart': 'features/chats/wave_chats_screen.dart',
  'screens/chats/components/chat-list.dart': 'features/chats/components/chat_list_component.dart',
  'screens/chats/components/chat.dart': 'features/chats/components/chat_window_component.dart',

  // features/feed
  'screens/main-feed.dart': 'features/feed/main_feed_screen.dart',
  'screens/modules/post/post-card.dart': 'features/feed/components/post_card.dart',
  'screens/modules/post/send-post.dart': 'features/feed/components/send_post_widget.dart',
  'screens/modules/post/components/post_attachment_button.dart': 'features/feed/components/post_attachment_button.dart',

  // features/zones
  'screens/modules/zones/zones.dart': 'features/zones/explore_zones_screen.dart',
  'screens/modules/zones/in-zone.dart': 'features/zones/zone_detail_screen.dart',
  'screens/modules/zones/components/zone-card.dart': 'features/zones/components/zone_card.dart',
  'screens/modules/zones/components/retrowave-fm.dart': 'features/zones/components/retrowave_fm.dart',

  // features/settings
  'screens/settings/settings-screen.dart': 'features/settings/settings_screen.dart',
  'screens/settings/components/appearance-settings.dart': 'features/settings/components/appearance_settings.dart',
  'screens/settings/components/notifications-settings.dart': 'features/settings/components/notifications_settings.dart',
  'screens/settings/components/privacy-settings.dart': 'features/settings/components/privacy_settings.dart',
  'screens/settings/components/profile-settings.dart': 'features/settings/components/profile_settings.dart',
  'screens/settings/components/security-settings.dart': 'features/settings/components/security_settings.dart',
  'screens/settings/components/settings-menu.dart': 'features/settings/components/settings_menu.dart',
  'screens/modules/profile/profile.dart': 'features/settings/profile_screen.dart',
  'screens/modules/profile/components/profile-card.dart': 'features/settings/components/profile_card.dart',

  // shared/widgets
  'screens/modules/header/header.dart': 'shared/widgets/header.dart',
  'screens/modules/menu/menu.dart': 'shared/widgets/side_menu.dart',

  // shared/components
  'screens/modules/header/components/hover-icon-button.dart': 'shared/components/hover_icon_button.dart',
  'screens/modules/menu/components/menu-item-button.dart': 'shared/components/menu_item_button.dart',
};

// 1. Move files
const oldFiles = Object.keys(moveMap);

oldFiles.forEach(oldPathRelative => {
  const oldPath = path.join(libDir, oldPathRelative);
  const newPathRelative = moveMap[oldPathRelative];
  const newPath = path.join(libDir, newPathRelative);
  
  if (oldPath !== newPath && fs.existsSync(oldPath)) {
    fs.mkdirSync(path.dirname(newPath), { recursive: true });
    fs.renameSync(oldPath, newPath);
    console.log(`Moved: ${oldPathRelative} -> ${newPathRelative}`);
  }
});

// 2. Update imports
function getAllFiles(dirPath, arrayOfFiles) {
  const files = fs.readdirSync(dirPath);
  arrayOfFiles = arrayOfFiles || [];
  files.forEach(function(file) {
    if (fs.statSync(dirPath + "/" + file).isDirectory()) {
      arrayOfFiles = getAllFiles(dirPath + "/" + file, arrayOfFiles);
    } else {
      if (file.endsWith('.dart')) {
        arrayOfFiles.push(path.join(dirPath, "/", file));
      }
    }
  });
  return arrayOfFiles;
}

const allDartFiles = getAllFiles(libDir);
const importRegex = /import\s+['"]([^'"]+)['"];/g;

// Create a reverse map to lookup new path by old path easily
// But wait, the file is already moved, so its current path is newPathRelative
// And it might contain imports to old paths.
// We need to resolve the old import string from the NEW path perspective to absolute path, BUT the import was written from the OLD path perspective!
// Ah! If we read the file AFTER moving, the `import` strings are still based on the OLD path!
// So `currentDir` should be the OLD directory.
// Let's iterate using old paths mapping.

const fileMappings = [];
for (const [oldRel, newRel] of Object.entries(moveMap)) {
    fileMappings.push({
        oldRel,
        newRel,
        newAbs: path.join(libDir, newRel),
        oldDir: path.dirname(path.join(libDir, oldRel))
    });
}

fileMappings.forEach(mapping => {
  if (!fs.existsSync(mapping.newAbs)) return;

  let content = fs.readFileSync(mapping.newAbs, 'utf8');
  let changed = false;

  content = content.replace(importRegex, (match, importPath) => {
    if (importPath.startsWith('package:flutter/') || importPath.startsWith('dart:')) {
      return match;
    }

    let absoluteOldImportPath;
    if (importPath.startsWith('package:frontend/')) {
        absoluteOldImportPath = importPath.replace('package:frontend/', '');
    } else {
        const resolvedPath = path.resolve(mapping.oldDir, importPath);
        absoluteOldImportPath = path.relative(libDir, resolvedPath).replace(/\\/g, '/');
    }

    let newPathRelative = moveMap[absoluteOldImportPath];
    if (!newPathRelative) {
        // Just in case it points to a file that hasn't moved or is external
        return match;
    }

    changed = true;
    return `import 'package:frontend/${newPathRelative}';`;
  });

  if (changed) {
    fs.writeFileSync(mapping.newAbs, content);
    console.log(`Updated imports in: ${mapping.newRel}`);
  }
});

// Remove old empty directories
function removeEmptyDirs(dir) {
    if (!fs.existsSync(dir)) return;
    const files = fs.readdirSync(dir);
    if (files.length > 0) {
        files.forEach(file => {
            const fullPath = path.join(dir, file);
            if (fs.statSync(fullPath).isDirectory()) {
                removeEmptyDirs(fullPath);
            }
        });
    }
    const remainingFiles = fs.readdirSync(dir);
    if (remainingFiles.length === 0) {
        fs.rmdirSync(dir);
    }
}
removeEmptyDirs(path.join(libDir, 'screens'));
removeEmptyDirs(path.join(libDir, 'themes'));
