require "pycall/import"

class CaffeClassificator
  include PyCall::Import

  attr_reader :net

  def initialize(window_size = 227)
    pyimport :sys
    sys.path.append('.')
    pyimport :caffe_classificator
  end

  def classify_image(image_path)
    caffe_classificator.classify_image(image_path)
  end

  def classify_images(images_paths)
    caffe_classificator.classify_images(images_paths)
  end
end
