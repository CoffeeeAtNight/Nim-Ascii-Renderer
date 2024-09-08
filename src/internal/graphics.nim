import ../external/nimgl/[opengl, glfw]

proc setupShaders(): GLuint =
    let vertexShaderSrc = cstring("""
        #version 330 core
        layout (location = 0) in vec3 position;
        void main() {
            gl_Position = vec4(position, 1.0);
        }
        """)
    let fragmentShaderSrc = cstring("""
        #version 330 core
        out vec4 color;
        void main() {
            color = vec4(1.0, 0.0, 0.0, 1.0);
        }
        """)

    # Compile Vertex Shader
    let vertexShader = glCreateShader(GL_VERTEX_SHADER)
    glShaderSource(vertexShader, 1, addr vertexShaderSrc, nil)
    glCompileShader(vertexShader)

    # Compile Fragment Shader
    let fragmentShader = glCreateShader(GL_FRAGMENT_SHADER)
    glShaderSource(fragmentShader, 1, addr fragmentShaderSrc, nil)
    glCompileShader(fragmentShader)

    # Link Shaders to Program
    let shaderProgram = glCreateProgram()
    glAttachShader(shaderProgram, vertexShader)
    glAttachShader(shaderProgram, fragmentShader)
    glLinkProgram(shaderProgram)

    # Clean up
    glDeleteShader(vertexShader)
    glDeleteShader(fragmentShader)

    return shaderProgram

proc setupVertices(): GLuint =
    let vertices: array[12, float32] = [
        -0.5f, -0.5f, 0.0f, # Bottom-left
        0.5f, -0.5f, 0.0f,  # Bottom-right
        0.5f, 0.5f, 0.0f,   # Top-right
        -0.5f, 0.5f, 0.0f   # Top-left
    ]

    var VBO, VAO: GLuint
    glGenVertexArrays(1, addr VAO)
    glGenBuffers(1, addr VBO)

    glBindVertexArray(VAO)

    # Bind VBO
    glBindBuffer(GL_ARRAY_BUFFER, VBO)
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), addr vertices[0], GL_STATIC_DRAW)

    # Set vertex attributes
    glVertexAttribPointer(
        0,
        3,
        GL_FLOAT, GL_FALSE,
        3 * sizeof(float32),
        cast[pointer](0)
    )

    glEnableVertexAttribArray(0)

    return VAO

proc render*() =
    doAssert glfwInit()

    glfwWindowHint(GLFWContextVersionMajor, 3)
    glfwWindowHint(GLFWContextVersionMinor, 3)
    glfwWindowHint(GLFWOpenglForwardCompat, GLFW_TRUE)
    glfwWindowHint(GLFWOpenglProfile, GLFW_OPENGL_CORE_PROFILE)
    glfwWindowHint(GLFWResizable, GLFW_FALSE)

    var w: GLFWWindow = glfwCreateWindow(1280, 720)
    if w == nil:
        quit(1)

    w.makeContextCurrent()
    doAssert glInit()

    # Set up shaders and vertices
    let shaderProgram = setupShaders()
    let VAO = setupVertices()

    # Main render loop
    while not w.windowShouldClose:
        glfwPollEvents()

        glClearColor(0.2f, 0.3f, 0.3f, 1.0f)
        glClear(GL_COLOR_BUFFER_BIT)

        glUseProgram(shaderProgram)
        glBindVertexArray(VAO)
        glDrawArrays(GL_QUADS, 0, 4)

        w.swapBuffers()

    w.destroyWindow()
    glfwTerminate()
