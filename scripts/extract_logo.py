import PIL.Image as Image
import os

def crop_logo(img_path, output_path):
    img = Image.open(img_path)
    # The logo is roughly on the left side
    # Based on the image, the logo occupies the first ~200 pixels of width
    # and the full height.
    # Let's be safe and crop a square area.
    width, height = img.size
    
    # logo_banner.png size from previous view_file was around 187KB, 
    # but I didn't get dimensions. Usually banners are wide.
    # Let's find the bounding box of non-transparent pixels on the left.
    
    # img is RGBA
    bbox = img.getbbox() # (left, top, right, bottom)
    
    # We want the left part. Let's look for where the first gap of vertical transparency is.
    # Or just use a fixed ratio for now if we can't see it.
    
    # Actually, let's just find the logo by looking at columns.
    data = img.getdata()
    
    def is_col_empty(x):
        for y in range(height):
            if data[y * width + x][3] > 0:
                return False
        return True

    # Find the right edge of the logo part
    logo_end_x = 0
    in_logo = False
    for x in range(width):
        empty = is_col_empty(x)
        if not empty:
            in_logo = True
        elif in_logo and empty:
            # Found a gap after some non-empty columns
            # Check if this gap is wide enough to be the separator
            is_separator = True
            for check_x in range(x, min(x + 10, width)):
                if not is_col_empty(check_x):
                    is_separator = False
                    break
            if is_separator:
                logo_end_x = x
                break
    
    if logo_end_x == 0:
        logo_end_x = int(width * 0.4) # Fallback
        
    logo = img.crop((0, 0, logo_end_x, height))
    
    # Now trim the transparency around the logo
    logo_bbox = logo.getbbox()
    if logo_bbox:
        logo = logo.crop(logo_bbox)
        
    # Make it a square for app icon
    l_w, l_h = logo.size
    size = max(l_w, l_h)
    new_img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    new_img.paste(logo, ((size - l_w) // 2, (size - l_h) // 2))
    
    # Add some padding
    padding = int(size * 0.1)
    final_size = size + 2 * padding
    padded_img = Image.new("RGBA", (final_size, final_size), (0, 0, 0, 0))
    padded_img.paste(new_img, (padding, padding))
    
    padded_img.save(output_path, "PNG")

if __name__ == "__main__":
    crop_logo("assets/images/logo_banner.png", "assets/icon/app_icon.png")
