import ../external/nimgl/[opengl, glfw]
import ../shaders/[frag_shader, vert_shader]

proc keyProc(window: GLFWWindow, key: int32, scancode: int32, action: int32,
    mods: int32): void {.cdecl.} =
  if key == GLFWKey.Escape and action == GLFWPress:
    window.setWindowShouldClose(true)
  if key == GLFWKey.Space:
    glPolygonMode(GL_FRONT_AND_BACK, if action !=
        GLFWRelease: GL_LINE else: GL_FILL)

proc setupShaders(): GLuint =
  let vertexShaderSrc = getVertShader()
  let fragmentShaderSrc = getFragShader()

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


proc setupVertices(): tuple[VBO, VAO, EBO: GLuint] =
  var mesh: tuple[VBO, VAO, EBO: GLuint]

  var vertices = @[ 
    # Pos (X, Y)       # Texture (U, V)
    -0.5f, -0.5f,      0.0f, 0.0f,     # Bottom-left
     0.5f, -0.5f,      1.0f, 0.0f,     # Bottom-right
     0.5f,  0.5f,      1.0f, 1.0f,     # Top-right
    -0.5f,  0.5f,      0.0f, 1.0f,     # Top-left
  ]

  # Render Order of Vertices
  var ind = @[
      0'u32, 1'u32, 3'u32,
      1'u32, 2'u32, 3'u32
  ]

  # Generate Buffers
  glGenBuffers(1, addr mesh.VBO)
  glGenBuffers(1, addr mesh.EBO)
  glGenVertexArrays(1, addr mesh.VAO)
  glBindVertexArray(mesh.VAO)

  # Bind VBO and EBO
  glBindBuffer(GL_ARRAY_BUFFER, mesh.VBO)
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, mesh.EBO)

  # Compute VBO and EBO
  glBufferData(GL_ARRAY_BUFFER, cint(cfloat.sizeof * vertices.len), vertices[0].addr, GL_STATIC_DRAW)
  glBufferData(GL_ELEMENT_ARRAY_BUFFER, cint(cfloat.sizeof * ind.len), ind[0].addr, GL_STATIC_DRAW)

  # Set vertex attributes
  glEnableVertexAttribArray(0)
  glVertexAttribPointer(
    0,                                  # Attribute index 0 (Position)
    2,                                  # 2 components per vertex (X, Y)
    EGL_FLOAT,                          # Type is EGL_FLOAT
    false,                              # Not normalized
    cfloat.sizeof * 4,                  # Stride (4 floats per vertex: X, Y, U, V)
    nil                                 # Offset is 0 for position
  )

  glEnableVertexAttribArray(1)
  glVertexAttribPointer(
    1,                                  # Attribute index 1 (TexCoord)
    2,                                  # 2 components per vertex (U, V)
    EGL_FLOAT,                          # Type is EGL_FLOAT
    false,                              # Not normalized
    cfloat.sizeof * 4,                  # Stride (4 floats per vertex: X, Y, U, V)
    cast[ptr GLvoid](cfloat.sizeof * 2) # Offset: Start after X, Y (2 floats)
  )

  return mesh

proc loadTexture*(imgBytes: seq[uint8], width: int, height: int): GLuint = 
  var glWidth = cast[GLsizei](width)
  var glHeight = cast[GLsizei](height)

  var texture: GLuint = 0
  glGenTextures(1, addr(texture))
  glActiveTexture(GL_TEXTURE0)
  glBindTexture(GL_TEXTURE_2D, texture)

  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, cast[GLint](GL_NEAREST))
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, cast[GLint](GL_NEAREST))

  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, cast[GLint](GL_CLAMP_TO_EDGE))
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, cast[GLint](GL_CLAMP_TO_EDGE))

  glTexImage2D(
    GL_TEXTURE_2D,
    cast[GLint](0),
    cast[GLint](GL_RGBA),
    glWidth,
    glHeight,
    cast[GLint](0),
    GL_RGBA,
    GL_UNSIGNED_BYTE,
    imgBytes[0].addr
  )

  glGenerateMipmap(GL_TEXTURE_2D)
  glBindTexture(GL_TEXTURE_2D, 0)

  return texture



proc render*(imgBytes: seq[uint8], width: int, height: int) =
  doAssert glfwInit()

  glfwWindowHint(GLFWContextVersionMajor, 3)
  glfwWindowHint(GLFWContextVersionMinor, 3)
  glfwWindowHint(GLFWOpenglForwardCompat, GLFW_TRUE)
  glfwWindowHint(GLFWOpenglProfile, GLFW_OPENGL_CORE_PROFILE)
  glfwWindowHint(GLFWResizable, GLFW_FALSE)

  # Create Window
  var window: GLFWWindow = glfwCreateWindow(1280, 720, "Ascii Renderer", nil, nil)
  doAssert window != nil

  # Register Key Callbacks
  discard window.setKeyCallback(keyProc)
  makeContextCurrent(window)

  # Init OpenGL
  doAssert glInit()

  # Set up shaders and vertices
  let mesh = setupVertices()
  let shaderProgram = setupShaders()

  var texture = loadTexture(imgBytes, width, height)

  # Main render loop
  while not window.windowShouldClose:
    # Draw colour to background
    glClearColor(0.2f, 0.3f, 0.3f, 1.0f)
    glClear(GL_COLOR_BUFFER_BIT)

    # Use VAO to draw vertices
    glUseProgram(shaderProgram)
    glUniform1i(glGetUniformLocation(shaderProgram, "textureSampler"), 0)
    glBindVertexArray(mesh.VAO)

    glActiveTexture(GL_TEXTURE0)
    glBindTexture(GL_TEXTURE_2D, texture)

    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, nil)

    swapBuffers(window)
    glfwPollEvents()


  window.destroyWindow()
  glfwTerminate()

  glBindVertexArray(0)
  glBindTexture(GL_TEXTURE_2D, 0)
  glDeleteBuffers(1, mesh.VAO.addr)
  glDeleteBuffers(1, mesh.VBO.addr)
  glDeleteBuffers(1, mesh.EBO.addr)
  glDeleteTextures(1, texture.addr)
