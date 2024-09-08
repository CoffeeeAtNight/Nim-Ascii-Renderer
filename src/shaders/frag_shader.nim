proc getFragShader*(): cstring =
    return cstring("""
        #version 330 core

        uniform sampler2D textureSampler;  // Original texture
        out vec4 color;
        in vec2 TexCoord;

        const float RED = 0.299;
        const float GREEN = 0.587;
        const float BLUE = 0.114;

        void main() {
            // Sample the texture at the given texture coordinates
            vec3 sampledColor = texture(textureSampler, TexCoord).rgb;

            // Convert the color to grayscale brightness
            float brightness = RED * sampledColor.r + GREEN * sampledColor.g + BLUE * sampledColor.b;

            // Map brightness to an index for ASCII mapping (0 to 15 for 16 levels)
            int asciiIndex = int(brightness * 15.0);  // Map to 16 levels

            // Map asciiIndex back to a normalized grayscale value for visualization
            float grayscaleValue = float(asciiIndex) / 15.0;

            // Output the grayscale color based on the brightness
            color = vec4(grayscaleValue, grayscaleValue, grayscaleValue, 1.0);
        }
    """)
