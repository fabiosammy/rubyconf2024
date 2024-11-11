require 'pycall/import'
include PyCall::Import

pyimport :cv2
pyimport :numpy, as: :np


image_path = "sliding_window/window_143.jpeg"


image = cv2.imread(image_path)

blue, green, red = cv2.split(image)

blue = blue.astype(np.float32)
green = green.astype(np.float32)
red = red.astype(np.float32)


# 1. Green Leaf Index (GLI)
gli = (2 * green - red - blue) / (2 * green + red + blue + 1e-5)
# 2. Excess Green Index (ExG)
exg = 2 * green - red - blue
# 3. Visible Atmospherically Resistant Index (VARI)
vari = (green - red) / (green + red - blue + 1e-5)
# 4. Normalized Green-Red Difference Index (NGRDI)
ngrdi = (green - red) / (green + red + 1e-5)
# 5. Excess Red Index (ExR)
exr = 1.4 * red - green
# 6. Combined Greenness Index (COM)
com = exg - exr
# 7. Triangular Greenness Index (TGI)
tgi = -0.5 * (190 * (red - green) - 120 * (red - blue))
# 8. Color Index of Vegetation Extraction (CIVE)
cive = 0.441 * red - 0.811 * green + 0.385 * blue + 18.787
# 9. Vegetative Index (VEG)
veg = green / ((red ** 0.667) * (blue ** 0.333) + 1e-5)

# Function to normalize and save each index
def normalize_and_save(index, name)
  normalized = cv2.normalize(index, nil, 0, 255, cv2.NORM_MINMAX)
  normalized = normalized.astype(np.uint8)
  normalized = cv2.applyColorMap(normalized, cv2.COLORMAP_JET)
  cv2.imwrite("processed_images/#{name}.jpeg", normalized)
  puts "#{name} index saved as processed_images/#{name}.jpeg"
end

# Normalize and save each vegetation index
normalize_and_save(gli, "GLI")
normalize_and_save(exg, "ExG")
normalize_and_save(vari, "VARI")
normalize_and_save(ngrdi, "NGRDI")
normalize_and_save(exr, "ExR")
normalize_and_save(com, "COM")
normalize_and_save(tgi, "TGI")
normalize_and_save(cive, "CIVE")
normalize_and_save(veg, "VEG")

puts "All vegetation indices have been calculated and saved."
