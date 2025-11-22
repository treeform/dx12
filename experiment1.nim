import opengl, windy

let window = newWindow("Windy Basic", ivec2(1280, 800))

window.makeContextCurrent()
loadExtensions()

proc display() =
  glViewport(0, 0, window.size.x, window.size.y)
  glClearColor(1.0f, 0.0f, 0.0f, 1.0f)
  glClear(GL_COLOR_BUFFER_BIT)
  # Your OpenGL display code here
  window.swapBuffers()

while not window.closeRequested:
  display()
  pollEvents()
