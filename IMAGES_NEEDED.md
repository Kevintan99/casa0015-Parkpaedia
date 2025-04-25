# Required Images for Parkpaedia

Please add the following images to the `assets/images/` directory:

1. `park_background.jpg` or `park_background.webp`
   - Used for: Landing page background
   - Suggested content: A beautiful park pathway with trees
   - Recommended size: 1080x1920 pixels
   - Format: JPG or WebP (WebP preferred for better compression)

2. `ladybug.jpg` or `ladybug.webp`
   - Used for: Species list thumbnail
   - Suggested content: Close-up shot of a ladybug
   - Recommended size: 300x300 pixels
   - Format: JPG or WebP (WebP preferred for better compression)

3. `ladybug_detail.jpg` or `ladybug_detail.webp`
   - Used for: Species detail view header
   - Suggested content: High-quality photo of a ladybug in its natural habitat
   - Recommended size: 1080x720 pixels
   - Format: JPG or WebP (WebP preferred for better compression)

4. `photo_placeholder.jpg` or `photo_placeholder.webp`
   - Used for: Empty photo states
   - Suggested content: Generic camera or photo icon
   - Recommended size: 300x300 pixels
   - Format: JPG or WebP (WebP preferred for better compression)

## Instructions

1. Place all images in the `assets/images/` directory
2. Make sure the filenames match exactly as listed above (choose either .jpg or .webp extension)
3. After adding the images, run `flutter pub get` to update the asset bundle

Note: 
- The app will show errors or blank spaces where these images should appear until they are added to the project
- WebP format is recommended as it provides better compression while maintaining quality
- If using WebP, make sure to update the image references in the code to use the .webp extension 