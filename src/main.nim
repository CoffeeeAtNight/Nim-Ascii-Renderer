import external/stb_image/read as stbi
import external/stb_image/write as stbiw
import internal/graphics

var
    width, height, channels_main, channels_ascii, ascii_sprite_w, ascii_sprite_h: int
    image_data: seq[uint8]
    ascii_texture_data: seq[uint8]

proc main() =
    # Load the main image
    image_data = stbi.load("../images/test-80-40.jpg", width, height, channels_main, stbi.Default)
    if image_data.len == 0:
        echo "Failed to load main image!"
        return

    # Load the ASCII sprite sheet
    ascii_texture_data = stbi.load("../images/ascii_sprite_black.png", ascii_sprite_w, ascii_sprite_h, channels_ascii, stbi.Default)
    if ascii_texture_data.len == 0:
        echo "Failed to load ASCII sprite sheet!"
        return

    echo "Main image - width: ", width, ", height: ", height, ", channels: ", channels_main
    echo "ASCII sprite - width: ", ascii_sprite_w, ", height: ", ascii_sprite_h, ", channels: ", channels_ascii
    echo image_data

    # Call render function to display the ASCII rendering
    render(image_data, width, height, ascii_texture_data, ascii_sprite_w, ascii_sprite_h)

main()
