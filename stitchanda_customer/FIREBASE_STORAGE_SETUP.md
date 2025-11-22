# Firebase Storage Setup Instructions

## The Error You're Getting

Error code `-13040` with "operation cancelled" means Firebase Storage is blocking your upload. This is almost always due to security rules.

## Quick Fix - Enable Firebase Storage First

### Step 1: Enable/Upgrade Firebase Storage

1. **Go to Firebase Console**: https://console.firebase.google.com/
2. **Select your project**: `stichanda-1cacd`
3. **Click "Storage"** in the left menu
4. **If you see "Get Started" or "Upgrade"**: Click it
5. **Choose "Start in production mode"** (we'll add secure rules next)
6. **Select a location**: Choose the closest location to your users (e.g., `asia-south1` for India)
7. **Click "Done"**
8. Wait for Storage to be provisioned (30 seconds - 1 minute)

### Step 2: Set Up Security Rules

Once Storage is enabled:

1. **Click "Rules"** tab at the top
2. **Replace the default rules** with this:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    
    // Allow anyone to read customer profile images
    match /customer_profiles/{imageId} {
      allow read: if true;
      
      // Only allow authenticated users to write/update/delete
      allow write: if request.auth != null;
    }
    
    // Deny all other paths by default
    match /{allPaths=**} {
      allow read, write: if false;
    }
  }
}
```

6. **Click "Publish"**
7. **Try uploading the image again**

### Alternative: Using Firebase CLI

If you have Firebase CLI installed:

```bash
cd "C:\Users\PMLS\Desktop\cloned repository\Stichanda_Customer"
firebase deploy --only storage
```

This will deploy the `storage.rules` file I created.

## What These Rules Do

- ✅ **Allow READ**: Anyone can view profile images (needed for displaying them)
- ✅ **Allow WRITE**: Only authenticated users can upload images
- ✅ **Path**: Images are stored in `customer_profiles/` folder
- ❌ **Deny**: All other storage locations are protected

## Test After Setup

1. Make sure you're logged in to the app
2. Go to Profile page
3. Click the camera icon
4. Select an image
5. It should upload successfully!

## Common Issues

### Still Getting Errors?

1. **Check Authentication**: Make sure you're logged in
2. **Check Internet**: Ensure you have a stable connection
3. **Check Storage Quota**: Make sure Firebase Storage has space
4. **Restart App**: Do a full rebuild after changing rules

### If Rules Don't Work

Try this temporary rule (for testing only - NOT SECURE):

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

This allows any authenticated user to upload anywhere. Once it works, switch back to the secure rules above.

## Verify Rules Are Active

After publishing rules:
1. Go to Firebase Console > Storage > Rules
2. You should see your new rules there
3. The status should be "Published"
4. It may take 1-2 minutes to propagate

## Need Help?

If the error persists after setting up rules:
- Check the Firebase Console for any error messages
- Verify your storage bucket name is correct: `stichanda-1cacd.firebasestorage.app`
- Make sure Firebase Storage is enabled in your project

