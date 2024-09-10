proc getFragShader*(): cstring =
    return cstring("""
        #version 330 core
        out vec4 FragColor;

        in vec3 ourColor;
        in vec2 TexCoord;

        uniform sampler2D mainTexture;      // The main image texture
        uniform sampler2D asciiTexture;     // The ASCII sprite texture

        uniform int asciiGridSizeX;         // Number of characters per row in ASCII texture (10)
        uniform float charWidth;            // Width of each character in pixels (8)
        uniform float charHeight;           // Height of each character in pixels (12)
        uniform vec2 textureSize;           // Total size of the ascii texture (width, height)

        void main()
        {
            // Sample the main texture (image)
            vec4 texColor = texture(mainTexture, TexCoord);

            // Convert the main texture color to grayscale (brightness)
            float brightness = 0.299 * texColor.r + 0.587 * texColor.g + 0.114 * texColor.b;

            // Use brightness to select ASCII character from asciiTexture
            // Map brightness to an ASCII character index (0 to 9, as there are 10 characters per row)
            float index = brightness * (float(asciiGridSizeX) - 1.0);  // Map brightness to ASCII character index (0-9)

            // Calculate the texture coordinates in the ASCII sprite sheet
            float xIndex = mod(index, float(asciiGridSizeX));  // Horizontal index in the grid (0 to 9)
            float yIndex = 0.0;  // Only one row in the ASCII sprite sheet

            // Compute the top-left coordinate of the cell in the sprite sheet
            vec2 asciiTexCoord = vec2(
                (xIndex * charWidth) / textureSize.x,     // Scale xIndex to the size of the texture
                (yIndex * charHeight) / textureSize.y     // yIndex is always 0 since there's only one row
            );

            // Adjust the tex coord based on the current pixel position within the cell (relative to the 8x12 grid)
            vec2 cellOffset = vec2(
                mod(TexCoord.x * textureSize.x, charWidth) / textureSize.x,  // Horizontal position within the cell
                mod(TexCoord.y * textureSize.y, charHeight) / textureSize.y  // Vertical position within the cell
            );

            // Final texture coordinate within the sprite sheet
            asciiTexCoord += cellOffset;

            // Sample the ASCII texture
            vec4 asciiColor = texture(asciiTexture, asciiTexCoord);

            // Output the sampled ASCII character color
            FragColor = asciiColor;
        }

    """)
