require "pycall/import"

class HelloWorld
  include PyCall::Import

  def initialize()
    pyimport :builtins, as: :python
  end

  def say_hello
    python.print("Hello Ruby World!")
  end
end
