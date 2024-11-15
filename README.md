
# RubyConf 2024

Hey :wave:, it's me, a Fabio! :D (Fun fact: my father's name is indeed, Mario)

* Slides: [https://docs.google.com/presentation/d/10uMgsRnllndUjkbcRL1O-qNEcy49UW3MlE2SZdqUGAo/edit?usp=sharing](https://docs.google.com/presentation/d/10uMgsRnllndUjkbcRL1O-qNEcy49UW3MlE2SZdqUGAo/edit?usp=sharing)
* Record: TODO

Here is all the examples that we did on the slides.

## Building

```bash
docker compose build app
```

## Dowload the model and extract here:

```
```

### Hello world

```bash
docker compose run --rm app bash
bundle install
bundle exec irb

require_relative "hello_world"
world = HelloWorld.new
world.say_hello
```

### OpenCV

```ruby
require_relative "open_cv"
open_cv = OpenCV.new("images/rubyconf2024.png")
open_cv.gray_image
open_cv.save_image("gray_image")
open_cv.sliding_window!
open_cv.selective_search!
open_cv.save_image
open_cv.exg_index
open_cv.detect_objects!("exg_index")
open_cv.save_image("exg_index", "processed_images/#{open_cv.object_id}_exg_index.png")
```

### Caffe Classificator

First you need to download the caffe models, you can use the alexnet for example: https://github.com/BVLC/caffe/tree/master/models/bvlc_alexnet
After that, you move the file to the caffe_models folder, and then run the code below.
You need these files:
```
caffe_model/deploy.prototxt
caffe_model/snapshot_iter_14435.caffemodel
```

Feel free to reach me or create a issue in the repo to more guidance about this step.

```ruby
require_relative "caffe_classificator"
caffe = CaffeClassificator.new()
caffe.classify_image("sliding_window/window_0.jpeg")
caffe.classify_images([
  "sliding_window/window_0.jpeg",
  "sliding_window/window_1.jpeg",
  "sliding_window/window_2.jpeg",
  "sliding_window/window_3.jpeg"
])
```

### Troubleshooting

* TODO

Feel free to reach me or create a issue any time to ask anything.

### More information

You can learn more the pycall on action checking:
https://github.com/mrkn/pycall.rb/blob/master/examples/datascience_rb_20170519.ipynb
