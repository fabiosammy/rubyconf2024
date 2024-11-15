require "pycall/import"

class OpenCV
  include PyCall::Import

  attr_reader :image_heigh, :image_width,
    :red_channel, :green_channel, :blue_channel,
    :resided_image, :detected_objects

  attr_accessor :image, :exg_index

  RED_COLOR = [0, 0, 255]
  GREEN_COLOR = [0, 255, 0]
  BLUE_COLOR = [255, 0, 0]

  def initialize(image_path)
    pyimport :cv2
    @image = cv2.imread(image_path)
    @image_height, @image_width = @image.shape
    @blue_channel, @green_channel, @red_channel = cv2.split(@image)
  end

  def gray_image()
    @gray_image ||= cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
  end

  def resize_image(height, width)
    @resized_image = cv2.resize(image, [height, width])
  end

  def exg_index()
    @exg_index ||= (2 * green_channel) - red_channel - blue_channel
  end

  def apply_colormap!(with_one = "image")
    self.send("#{with_one}=", cv2.applyColorMap(self.send(with_one), cv2.COLORMAP_WINTER))
  end

  def detect_objects!(with_one = "image")
    with_image = self.send(with_one)
    input_image = cv2.cvtColor(with_image, cv2.COLOR_BGR2GRAY)
    _, thresh_img = cv2.threshold(input_image, 127, 255, cv2.THRESH_BINARY)
    @detected_objects, _ = cv2.findContours(thresh_img, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    image_with_objects = cv2.drawContours(with_image, @detected_objects, -1, BLUE_COLOR, 2)
    cv2.imwrite("processed_images/#{self.object_id}_#{with_one}_with_objects.png", image_with_objects)
  end

  def save_image(with_one = "image", filename_to_save = nil)
    unless filename_to_save
      filename_to_save = "processed_images/#{self.object_id}_#{with_one}.png"
    end
    cv2.imwrite(filename_to_save, self.send(with_one))
  end

  def sliding_window!(window_size = 32, step_size = 16)
    counter = 0
    (0...@image_height - window_size + 1).step(step_size) do |y|
      (0...@image_width - window_size + 1).step(step_size) do |x|
        window = image[y...(y + window_size), x...(x + window_size)]
        window_filename = File.join("sliding_window", "window_#{counter}.jpeg")
        cv2.imwrite(window_filename, window)
        counter += 1
      end
    end
  end

  def selective_search!(with_one = "image")
    ss = cv2.ximgproc.segmentation.createSelectiveSearchSegmentation()
    ss.setBaseImage(self.send(with_one))
    ss.switchToSelectiveSearchFast()
    rects = ss.process()
    color = RED_COLOR
    PyCall::IterableWrapper.new(rects).each do |rect|
      x = rect[0]
      y = rect[1]
      w = rect[2]
      h = rect[3]
      cv2.rectangle(self.send(with_one), [x, y], [x + w, y + h], color, 1)
    end
  end
end
