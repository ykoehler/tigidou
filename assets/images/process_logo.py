import PIL.Image as Image
import sys

def black_to_alpha(img_path, output_path):
    img = Image.open(img_path)
    img = img.convert("RGBA")
    
    datas = img.getdata()
    
    newData = []
    for item in datas:
        # If the pixel is very dark (black or near-black), make it transparent
        if item[0] < 20 and item[1] < 20 and item[2] < 20: 
            newData.append((0, 0, 0, 0))
        else:
            newData.append(item)
            
    img.putdata(newData)
    img.save(output_path, "PNG")

if __name__ == "__main__":
    black_to_alpha(sys.argv[1], sys.argv[2])
