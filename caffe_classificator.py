import caffe
import numpy as np

def create_caffe_net():
    deploy_prototxt_path = "caffe_model/deploy.prototxt"
    caffe_model_path = "caffe_model/snapshot_iter_14435.caffemodel"

    caffe.set_mode_cpu()

    net = caffe.Net(deploy_prototxt_path, caffe_model_path, caffe.TEST)

    return net


def create_caffe_transformer(net):
    transformer = caffe.io.Transformer({'data': net.blobs['data'].data.shape})
    transformer.set_transpose('data', (2,0,1))
    transformer.set_channel_swap('data', (2,1,0))
    transformer.set_raw_scale('data', 255.0)

    return transformer


def classify_image(image_path):
    img = caffe.io.load_image(image_path)
    window_size = 227

    net = create_caffe_net()
    net.blobs['data'].reshape(1, 3, window_size, window_size)
    transformer = create_caffe_transformer(net)

    net.blobs['data'].data[...] = transformer.preprocess('data', img)
    output = net.forward()
    
    return output

def classify_images(images_paths):
    imgs = []
    net = create_caffe_net()
    window_size = 227
    net.blobs['data'].reshape(len(images_paths), 3, window_size, window_size)
    transformer = create_caffe_transformer(net)

    for image in images_paths:
        img = caffe.io.load_image(image)
        imgs.append(transformer.preprocess('data', img))

    net.blobs['data'].data[...] = imgs
    output = net.forward()

    return output
