import stb_image/read as stbi
import stb_image/write as stbiw
import std/os

# ITU-R BT.601 standards for luminance equations
const RED: float = 0.299
const GREEN: float = 0.587
const BLUE: float = 0.114

var
    width, height, channels: int
    image_data: seq[uint8]
    counter: int = 0
    ascii_set: string = " .:-=+*#%@"
    ascii_art: string

proc convertToAscii(brightness_value: uint8): char =
    return case brightness_value:
        of 0 .. 27:
            ascii_set[0]
        of 28 .. 55:
            ascii_set[1]
        of 56 .. 84:
            ascii_set[2]
        of 85 .. 112:
            ascii_set[3]
        of 113 .. 140:
            ascii_set[4]
        of 141 .. 169:
            ascii_set[5]
        of 170 .. 197:
            ascii_set[6]
        of 198 .. 225:
            ascii_set[7]
        of 226 .. 254:
            ascii_set[8]
        of 255:
            ascii_set[9]


proc main() =
    image_data = stbi.load("../images/test.jpg", width, height, channels, stbi.Default)

    for index, pixel in image_data:
        if counter != 2:
            inc(counter)
            continue

        if (index + 1) mod 80 == 0:
            ascii_art.add('\n')


        var bluePxl = cast[float](image_data[index]) * BLUE
        var greenPxl = cast[float](image_data[index - 1]) * GREEN
        var redPxl = cast[float](image_data[index] - 2) * RED
        var brightness_value: uint8 = cast[uint8](redPxl + greenPxl + bluePxl)

        var ascii_char: char = convertToAscii(brightness_value)
        ascii_art.add(ascii_char)
        counter = 0

    echo ascii_art
    sleep(1000000)

main()
